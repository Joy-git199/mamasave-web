// Load environment variables from .env file
require('dotenv').config();

// Import required modules
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const path = require('path');
const nodemailer = require('nodemailer'); // For sending emails

// Initialize Express app
const app = express();
app.use(cors()); // Enable CORS for all routes
app.use(express.json()); // Parse JSON bodies

// Initialize Firebase Admin SDK
// Make sure 'serviceAccountKey.json' is in the same directory as this index.js file
const serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // Optionally, add databaseURL or storageBucket if needed
});

console.log('Firebase Admin SDK initialized.');

// =====================
// Firestore Initialization
// =====================
const db = admin.firestore();

// =====================
// Nodemailer Transporter Setup
// Configure your email service here.
const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: parseInt(process.env.EMAIL_PORT || '587'),
  secure: process.env.EMAIL_SECURE === 'true',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Verify transporter configuration
transporter.verify(function (error, success) {
  if (error) {
    console.error("Nodemailer transporter verification failed:", error);
  } else {
    console.log("Nodemailer transporter is ready to send emails.");
  }
});


// =====================
// Authentication Middleware
// =====================
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    console.warn('Authentication: No Authorization header or malformed.');
    return res.status(401).json({ error: 'Authorization header missing or malformed.' });
  }
  const idToken = authHeader.split(' ')[1];
  admin.auth().verifyIdToken(idToken)
    .then((decodedToken) => {
      req.user = decodedToken;
      next();
    })
    .catch((error) => {
      console.error('Firebase ID token verification error:', error.message);
      return res.status(401).json({ error: 'Invalid or expired ID token.', details: error.message });
    });
}

// =====================
// API Routes Grouping
// =====================
const apiRouter = express.Router();
app.use('/api', apiRouter);

// =====================
// User Authentication Endpoints
// =====================

apiRouter.post('/users/signup', async (req, res) => {
  const { email, password, name, role } = req.body;
  if (!email || !password || !name || !role) {
    return res.status(400).json({ error: 'Email, password, name, and role are required.' });
  }
  try {
    const userRecord = await admin.auth().createUser({ email, password });
    const userProfile = {
      firebaseUid: userRecord.uid,
      email: userRecord.email,
      name: name,
      role: role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      appTheme: 'default',
    };
    await db.collection('users').doc(userRecord.uid).set(userProfile);
    return res.status(201).json({ firebaseUid: userRecord.uid, email: userRecord.email, name: name, role: role });
  } catch (error) {
    console.error('Error during user signup:', error);
    let message = 'Failed to create user.';
    if (error.code === 'auth/email-already-exists') {
      message = 'Email already in use.';
    } else if (error.code === 'auth/weak-password') {
      message = 'Password is too weak.';
    } else if (error.code === 'auth/invalid-email') {
      message = 'Invalid email address.';
    }
    return res.status(400).json({ error: message, details: error.message });
  }
});

apiRouter.post('/users/signin', authenticateToken, async (req, res) => {
  const uid = req.user.uid;
  try {
    const userDoc = await db.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User profile not found. Please ensure you have signed up.' });
    }
    return res.status(200).json(userDoc.data());
  } catch (error) {
    console.error('Error during user signin/profile fetch:', error);
    return res.status(500).json({ error: 'Failed to verify sign-in or fetch user profile.', details: error.message });
  }
});

// =====================
// User Profile Endpoints
// =====================

apiRouter.get('/users/:firebaseUid', async (req, res) => {
  const targetUid = req.params.firebaseUid;
  try {
    const userDoc = await db.collection('users').doc(targetUid).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User profile not found.' });
    }
    return res.status(200).json(userDoc.data());
  } catch (error) {
    console.error('Error fetching user profile:', error);
    return res.status(500).json({ error: 'Failed to fetch user profile.', details: error.message });
  }
});

apiRouter.put('/users/:firebaseUid', async (req, res) => {
  const targetUid = req.params.firebaseUid;
  const updates = req.body;
  if (!updates || typeof updates !== 'object') {
    return res.status(400).json({ error: 'Invalid profile update data.' });
  }
  try {
    await db.collection('users').doc(targetUid).update(updates);
    const updatedDoc = await db.collection('users').doc(targetUid).get();
    return res.status(200).json(updatedDoc.data());
  } catch (error) {
    console.error('Error updating user profile:', error);
    let message = 'Failed to update user profile.';
    if (error.code === 5 && error.details && error.details.includes('No document to update')) {
        message = 'User profile not found for update.';
    }
    return res.status(500).json({ error: message, details: error.message });
  }
});

// =====================
// Sensor Data Endpoints (CRITICAL FIX HERE)
// =====================

/**
 * POST /api/data/sensor/:firebaseUid
 * Stores a single combined sensor reading object for the specified user.
 * This endpoint is designed to receive the FULL sensor data payload from Flutter's BackendDemoPage
 * and the ESP32, and store it as the 'latest' data.
 * Expects: { heartRate: number, spo2: number, temperature: number, pressure_kPa: number, pressure_voltage: number, timestamp: string } in request body.
 */
apiRouter.post('/data/sensor/:firebaseUid', async (req, res) => {
  const targetUid = req.params.firebaseUid;
  const combinedReading = req.body; // Expect to receive the full combined object here
  
  // Validate required fields for a combined reading
  if (
    typeof combinedReading.heartRate === 'undefined' ||
    typeof combinedReading.spo2 === 'undefined' ||
    typeof combinedReading.temperature === 'undefined' ||
    typeof combinedReading.pressure_kPa === 'undefined' ||
    typeof combinedReading.pressure_voltage === 'undefined' ||
    typeof combinedReading.timestamp !== 'string'
  ) {
    console.error('[Backend] Invalid combined sensor data received:', combinedReading);
    return res.status(400).json({ error: 'Invalid combined sensor data. Expected all sensor fields and timestamp.' });
  }

  try {
    // 1. Update the 'latest' document for this sensorId in Firestore
    // This makes the Flutter app's GET request simpler and faster
    await db.collection('sensor_live_data').doc(targetUid).set({
      heartRate: combinedReading.heartRate,
      spo2: combinedReading.spo2,
      temperature: combinedReading.temperature,
      pressure_kPa: combinedReading.pressure_kPa,
      pressure_voltage: combinedReading.pressure_voltage,
      timestamp: admin.firestore.Timestamp.fromDate(new Date(combinedReading.timestamp)), // Convert to Timestamp
      lastUpdatedServer: admin.firestore.FieldValue.serverTimestamp(), // Server-side timestamp
    }, { merge: true }); // Use merge to update existing fields or create if not exists

    // 2. Optionally, store individual readings in a subcollection for history/trends
    // This part is for historical data, not directly used by live display
    await db.collection('sensor_readings_history').doc(targetUid).collection('readings').add({
      heartRate: combinedReading.heartRate,
      spo2: combinedReading.spo2,
      temperature: combinedReading.temperature,
      pressure_kPa: combinedReading.pressure_kPa,
      pressure_voltage: combinedReading.pressure_voltage,
      timestamp: admin.firestore.Timestamp.fromDate(new Date(combinedReading.timestamp)),
      serverTimestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`[Backend] Received and stored combined data for ${targetUid}:`, combinedReading);
    return res.status(201).json({ message: 'Combined sensor data stored successfully.' });
  } catch (error) {
    console.error('Error storing combined sensor data:', error);
    return res.status(500).json({ error: 'Failed to store combined sensor data.', details: error.message });
  }
});

/**
 * GET /api/data/sensor/:sensorId/latest
 * Retrieves the latest combined sensor data for the specified sensorId.
 * NOTE: No authentication required for ESP32/Flutter live display.
 */
apiRouter.get('/data/sensor/:sensorId/latest', async (req, res) => {
    const { sensorId } = req.params;

    try {
        const docSnap = await db.collection('sensor_live_data').doc(sensorId).get();

        if (docSnap.exists) {
            const data = docSnap.data();
            // Convert Firestore Timestamp back to ISO string for Flutter
            if (data.timestamp && data.timestamp.toDate) {
                data.timestamp = data.timestamp.toDate().toISOString();
            }
            console.log(`[Backend] Serving latest data from Firestore for ${sensorId}:`, data);
            return res.status(200).json(data);
        } else {
            console.warn(`[Backend] No live data document found for sensorId: ${sensorId} in Firestore. Returning defaults.`);
            // Return 404 but with a default body to prevent Flutter from crashing
            return res.status(404).json({
                error: 'Sensor data not found or not yet available.',
                heartRate: 0.0,
                spo2: 0.0,
                temperature: 0.0,
                pressure_kPa: 0.0,
                pressure_voltage: 0.0,
                timestamp: new Date().toISOString()
            });
        }
    } catch (error) {
        console.error('[Backend] Error fetching latest sensor data from Firestore:', error);
        return res.status(500).json({
            error: 'Internal server error fetching latest sensor data.',
            heartRate: 0.0,
            spo2: 0.0,
            temperature: 0.0,
            pressure_kPa: 0.0,
            pressure_voltage: 0.0,
            timestamp: new Date().toISOString()
        });
    }
});

/**
 * GET /api/data/sensor/:firebaseUid
 * Retrieves historical sensor readings for the specified user.
 * Requires authentication.
 * Optional query params: type, limit, startTime, endTime (startTime/endTime as Unix ms timestamps).
 * Returns readings ordered by timestamp (descending).
 */
apiRouter.get('/data/sensor/:firebaseUid', authenticateToken, async (req, res) => {
  const targetUid = req.params.firebaseUid;
  const { type, limit, startTime, endTime } = req.query;

  try {
    let query = db.collection('sensor_readings_history').doc(targetUid).collection('readings'); // Query subcollection

    if (type) {
      query = query.where('type', '==', type);
    }
    if (startTime) {
      query = query.where('timestamp', '>=', admin.firestore.Timestamp.fromMillis(Number(startTime)));
    }
    if (endTime) {
      query = query.where('timestamp', '<=', admin.firestore.Timestamp.fromMillis(Number(endTime)));
    }

    query = query.orderBy('timestamp', 'desc');

    let lim = 100; // Default limit
    if (limit && !isNaN(Number(limit))) {
      lim = Math.min(Number(limit), 1000); // Cap at 1000
    }
    query = query.limit(lim);

    const snapshot = await query.get();
    const readings = snapshot.docs.map(doc => {
      const data = doc.data();
      // Convert Firestore Timestamp objects back to ISO8601 strings
      if (data.timestamp && data.timestamp.toDate) {
        data.timestamp = data.timestamp.toDate().toISOString();
      }
      if (data.serverTimestamp && data.serverTimestamp.toDate) {
        data.serverTimestamp = data.serverTimestamp.toDate().toISOString();
      }
      return data;
    });
    return res.status(200).json(readings);
  } catch (error) {
    console.error('Error fetching historical sensor readings:', error);
    return res.status(500).json({ error: 'Failed to fetch historical sensor readings.', details: error.message });
  }
});


// =====================
// Document Upload & Retrieval Endpoints
// =====================

apiRouter.post('/documents', authenticateToken, async (req, res) => {
  const uid = req.user.uid;
  const { type, content, ...otherFields } = req.body;
  if (!type || typeof type !== 'string' || typeof content === 'undefined') {
    return res.status(400).json({ error: 'Document must include type (string) and content.' });
  }
  try {
    const docData = {
      uid,
      type,
      content,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      ...otherFields,
    };
    const docRef = await db.collection('documents').add(docData);
    return res.status(201).json({ docId: docRef.id });
  } catch (error) {
    console.error('Error uploading document:', error);
    return res.status(500).json({ error: 'Failed to upload document.', details: error.message });
  }
});

apiRouter.get('/documents', authenticateToken, async (req, res) => {
  const uid = req.user.uid;
  const { type, docId } = req.query;
  try {
    let query = db.collection('documents').where('uid', '==', uid);
    if (type) {
      query = query.where('type', '==', type);
    }
    if (docId) {
      const doc = await db.collection('documents').doc(docId).get();
      if (!doc.exists || doc.data().uid !== uid) {
        return res.status(404).json({ error: 'Document not found.' });
      }
      return res.status(200).json([ { id: doc.id, ...doc.data() } ]);
    }
    query = query.orderBy('createdAt', 'desc');
    const snapshot = await query.get();
    const docs = snapshot.docs.map(doc => {
      const data = doc.data();
      if (data.createdAt && data.createdAt.toDate) {
        data.createdAt = data.createdAt.toDate().toISOString();
      }
      return { id: doc.id, ...data };
    });
    return res.status(200).json(docs);
  } catch (error) {
    console.error('Error fetching documents:', error);
    return res.status(500).json({ error: 'Failed to fetch documents.', details: error.message });
  }
});

// =====================
// User Settings Endpoints
// =====================

apiRouter.get('/settings', authenticateToken, async (req, res) => {
  const uid = req.user.uid;
  try {
    const userDoc = await db.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User profile not found.' });
    }
    const data = userDoc.data();
    return res.status(200).json(data.preferences || {});
  } catch (error) {
    console.error('Error fetching user settings:', error);
    return res.status(500).json({ error: 'Failed to fetch user settings.', details: error.message });
  }
});

apiRouter.put('/settings', authenticateToken, async (req, res) => {
  const uid = req.user.uid;
  const updates = req.body;
  if (!updates || typeof updates !== 'object') {
    return res.status(400).json({ error: 'Invalid settings update data.' });
  }
  try {
    await db.collection('users').doc(uid).set({ preferences: updates }, { merge: true });
    const updatedDoc = await db.collection('users').doc(uid).get();
    return res.status(200).json(updatedDoc.data().preferences || {});
  } catch (error) {
    console.error('Error updating user settings:', error);
    return res.status(500).json({ error: 'Failed to update user settings.', details: error.message });
  }
});

// =====================
// Alert System Endpoint
// =====================

apiRouter.post('/alerts/temperature', async (req, res) => {
  const { motherUid, temperature, sensorId, timestamp } = req.body;

  if (!motherUid || typeof temperature === 'undefined' || !sensorId || !timestamp) {
    return res.status(400).json({ error: 'Missing required alert data (motherUid, temperature, sensorId, timestamp).' });
  }

  const clientIp = req.ip || req.connection.remoteAddress;
  console.log(`[ALERT] Temperature Alert Received for Mother: ${motherUid}`);
  console.log(`[ALERT] Temperature: ${temperature}°C, Sensor ID: ${sensorId}`);
  console.log(`[ALERT] Timestamp: ${timestamp}, Client IP: ${clientIp}`);

  try {
    await db.collection('temperature_alerts').add({
      motherUid,
      temperature,
      sensorId,
      timestamp: admin.firestore.Timestamp.fromDate(new Date(timestamp)),
      clientIp,
      alertedAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'triggered',
    });

    const emergencyEmail = process.env.EMERGENCY_EMAIL || 'emergency@example.com';
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: emergencyEmail,
      subject: `URGENT: High Temperature Alert for Mother ${motherUid}`,
      html: `
        <p>Dear Emergency Services,</p>
        <p>This is an automated alert from MamaSave. A high temperature reading has been detected for a mother.</p>
        <ul>
          <li><strong>Mother ID:</strong> ${motherUid}</li>
          <li><strong>Temperature:</strong> ${temperature}°C</li>
          <li><strong>Sensor ID:</strong> ${sensorId}</li>
          <li><strong>Time of Reading:</strong> ${new Date(timestamp).toLocaleString()}</li>
          <li><strong>Approximate Location (Client IP):</strong> ${clientIp}</li>
        </ul>
        <p>Please take immediate action to check on the mother.</p>
        <p>MamaSave System</p>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log(`[ALERT] Email sent to ${emergencyEmail} for mother ${motherUid}`);
    return res.status(200).json({ message: 'Temperature alert processed and email sent.', clientIp });

  } catch (error) {
    console.error('[ALERT] Error processing temperature alert or sending email:', error);
    return res.status(500).json({ error: 'Failed to process temperature alert.', details: error.message });
  }
});


// Health check endpoint
app.get('/', (req, res) => {
  res.send('Backend server is running!');
});

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on http://0.0.0.0:${PORT}`);
});
