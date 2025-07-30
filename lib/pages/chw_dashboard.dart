// lib/pages/chw_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/services/data_manager.dart';
import 'package:mamasave/models/vitals_entry.dart';
import 'package:mamasave/models/health_visit.dart';
import 'package:mamasave/models/user_profile.dart'; // Import UserProfile
import 'package:mamasave/widgets/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

class ChwDashboard extends StatefulWidget {
  const ChwDashboard({super.key});

  @override
  State<ChwDashboard> createState() => _ChwDashboardState();
}

class _ChwDashboardState extends State<ChwDashboard> {
  final String _currentChwId = 'chw_mock'; // Mock CHW ID

  // Controllers for text fields
  final TextEditingController _spo2Controller = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _hrController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _recommendationsController = TextEditingController();

  String? _selectedMotherId;
  final List<String> _selectedDangerSigns = [];

  @override
  void dispose() {
    _spo2Controller.dispose();
    _tempController.dispose();
    _hrController.dispose();
    _bpController.dispose();
    _notesController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }

  // Function to handle adding a new vitals entry
  Future<void> _addVitalsEntry(BuildContext context) async {
    if (_selectedMotherId == null) {
      CustomSnackBar.showError(context, 'Please select a mother.');
      return;
    }

    final dataManager = Provider.of<DataManager>(context, listen: false);
    final Uuid uuid = Uuid();

    final newVitals = VitalsEntry(
      id: uuid.v4(),
      motherId: _selectedMotherId!,
      timestamp: DateTime.now(),
      spo2: double.tryParse(_spo2Controller.text),
      temperature: double.tryParse(_tempController.text),
      heartRate: double.tryParse(_hrController.text), // FIX: Changed to double.tryParse
      bloodPressure: _bpController.text.isNotEmpty ? _bpController.text : null,
      pressureKPa: null, // Not from manual entry here
      pressureVoltage: null, // Not from manual entry here
    );

    await dataManager.addVitalsEntry(newVitals);

    CustomSnackBar.showSuccess(context, 'Vitals entry added successfully!');
    _clearVitalsFields();
  }

  // Function to handle adding a new health visit
  Future<void> _addHealthVisit(BuildContext context) async {
    if (_selectedMotherId == null) {
      CustomSnackBar.showError(context, 'Please select a mother.');
      return;
    }

    final dataManager = Provider.of<DataManager>(context, listen: false);
    final Uuid uuid = Uuid();

    final newVisit = HealthVisit(
      id: uuid.v4(),
      motherId: _selectedMotherId!,
      visitDate: DateTime.now(),
      visitorRole: 'CHW', // Assuming CHW is adding this
      visitorId: _currentChwId,
      notes: _notesController.text, // FIX: Removed .isNotEmpty ? ... : null, notes is non-nullable
      dangerSigns: List.from(_selectedDangerSigns), // Create a new list
      recommendations: _recommendationsController.text.isNotEmpty ? _recommendationsController.text : null,
      vitals: null, // Vitals added separately
    );

    await dataManager.addHealthVisit(newVisit);

    CustomSnackBar.showSuccess(context, 'Health visit added successfully!');
    _clearVisitFields();
  }

  void _clearVitalsFields() {
    _spo2Controller.clear();
    _tempController.clear();
    _hrController.clear();
    _bpController.clear();
    setState(() {
      _selectedMotherId = null;
    });
  }

  void _clearVisitFields() {
    _notesController.clear();
    _recommendationsController.clear();
    setState(() {
      _selectedDangerSigns.clear();
      _selectedMotherId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final theme = Theme.of(context);

    final UserProfile? currentUser = dataManager.getUserById(_currentChwId); // FIX: Changed type to UserProfile?
    final String chwName = currentUser?.name ?? 'CHW User'; // FIX: Access with dot notation

    final List<UserProfile> allMothers = dataManager.getAllMothers();
    final List<String> allMotherIds = dataManager.getAllMotherIds();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('CHW Dashboard', style: AppStyles.headline2.copyWith(color: AppColors.whiteTextColor)),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $chwName!',
              style: AppStyles.headline2.copyWith(color: theme.textTheme.displayMedium?.color),
            ),
            const SizedBox(height: 8),
            Text(
              'Community Health Worker',
              style: AppStyles.subTitle.copyWith(color: theme.textTheme.titleLarge?.color),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Record Vitals', Icons.monitor_heart, context),
            const SizedBox(height: 16),
            _buildVitalsRecordingCard(context, dataManager, allMotherIds),
            const SizedBox(height: 24),

            _buildSectionTitle('Record Health Visit', Icons.local_hospital, context),
            const SizedBox(height: 16),
            _buildHealthVisitRecordingCard(context, dataManager, allMotherIds),
            const SizedBox(height: 24),

            _buildSectionTitle('Recent Emergency Reports', Icons.warning_amber, context),
            const SizedBox(height: 16),
            _buildRecentEmergencyReports(dataManager.getRecentEmergencyReports(), context),
            const SizedBox(height: 24),

            _buildSectionTitle('All Mothers', Icons.people, context),
            const SizedBox(height: 16),
            _buildAllMothersList(allMothers, context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppStyles.headline3.copyWith(color: Theme.of(context).textTheme.displaySmall?.color),
        ),
      ],
    );
  }

  Widget _buildVitalsRecordingCard(BuildContext context, DataManager dataManager, List<String> allMotherIds) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: AppStyles.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            // FIX: Use InputDecoration directly and apply theme defaults
            decoration: InputDecoration(
              labelText: 'Select Mother',
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
            value: _selectedMotherId,
            items: allMotherIds.map((id) {
              final motherName = dataManager.getMotherNameById(id);
              return DropdownMenuItem(
                value: id,
                child: Text('$motherName (ID: $id)', style: AppStyles.bodyText1.copyWith(color: isDarkMode ? AppColors.textColorDark : AppColors.textColor)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMotherId = value;
              });
            },
            dropdownColor: isDarkMode ? AppColors.surfaceColorDark : AppColors.surfaceColor,
            style: AppStyles.bodyText1.copyWith(color: isDarkMode ? AppColors.textColorDark : AppColors.textColor),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _spo2Controller,
            keyboardType: TextInputType.number,
            // FIX: Use InputDecoration directly and apply theme defaults
            decoration: InputDecoration(
              labelText: 'SpO2 (%)',
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
            style: AppStyles.bodyText1.copyWith(color: isDarkMode ? AppColors.textColorDark : AppColors.textColor),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tempController,
            keyboardType: TextInputType.number,
            // FIX: Use InputDecoration directly and apply theme defaults
            decoration: InputDecoration(
              labelText: 'Temperature (°C)',
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
            style: AppStyles.bodyText1.copyWith(color: isDarkMode ? AppColors.textColorDark : AppColors.textColor),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hrController,
            keyboardType: TextInputType.number,
            // FIX: Use InputDecoration directly and apply theme defaults
            decoration: InputDecoration(
              labelText: 'Heart Rate (bpm)',
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
            style: AppStyles.bodyText1.copyWith(color: isDarkMode ? AppColors.textColorDark : AppColors.textColor),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bpController,
            keyboardType: TextInputType.text,
            // FIX: Use InputDecoration directly and apply theme defaults
            decoration: InputDecoration(
              labelText: 'Blood Pressure (e.g., 120/80)',
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
            style: AppStyles.bodyText1.copyWith(color: isDarkMode ? AppColors.textColorDark : AppColors.textColor),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => _addVitalsEntry(context),
              style: Theme.of(context).elevatedButtonTheme.style, // Use theme's button style
              child: Text('Add Vitals Entry', style: AppStyles.buttonTextStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthVisitRecordingCard(BuildContext context, DataManager dataManager, List<String> allMotherIds) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: AppStyles.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            // FIX: Use InputDecoration directly and apply theme defaults
            decoration: InputDecoration(
              labelText: 'Select Mother',
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
            value: _selectedMotherId,
            items: allMotherIds.map((id) {
              final motherName = dataManager.getMotherNameById(id);
              return DropdownMenuItem(
                value: id,
                child: Text('$motherName (ID: $id)', style: AppStyles.bodyText1.copyWith(color: isDarkMode ? AppColors.textColorDark : AppColors.textColor)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMotherId = value;
              });
            },
            dropdownColor: isDarkMode ? AppColors.surfaceColorDark : AppColors.surfaceColor,
            style: AppStyles.bodyText1.copyWith(color: isDarkMode ? AppColors.textColorDark : AppColors.textColor),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            // FIX: Use InputDecoration directly and apply theme defaults
            decoration: InputDecoration(
              labelText: 'Notes about the visit',
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
            style: AppStyles.bodyText1.copyWith(color: isDarkMode ? AppColors.textColorDark : AppColors.textColor),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _recommendationsController,
            maxLines: 2,
            // FIX: Use InputDecoration directly and apply theme defaults
            decoration: InputDecoration(
              labelText: 'Recommendations',
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
            style: AppStyles.bodyText1.copyWith(color: isDarkMode ? AppColors.textColorDark : AppColors.textColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Danger Signs (Select all that apply):',
            style: AppStyles.bodyText1.copyWith(color: isDarkMode ? AppColors.textColorDark : AppColors.textColor),
          ),
          Wrap(
            spacing: 8.0,
            children: [
              'Fever', 'Swelling', 'Headache', 'Blurred Vision', 'Abdominal Pain', 'Vaginal Bleeding', 'Reduced Fetal Movement'
            ].map((sign) {
              return FilterChip(
                label: Text(sign),
                selected: _selectedDangerSigns.contains(sign),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDangerSigns.add(sign);
                    } else {
                      _selectedDangerSigns.remove(sign);
                    }
                  });
                },
                selectedColor: AppColors.dangerColor.withOpacity(0.3),
                checkmarkColor: AppColors.dangerColor,
                labelStyle: AppStyles.bodyText2.copyWith(color: _selectedDangerSigns.contains(sign) ? AppColors.dangerColor : (isDarkMode ? AppColors.textColorDark : AppColors.textColor)),
                backgroundColor: isDarkMode ? AppColors.surfaceColorDark : AppColors.surfaceColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => _addHealthVisit(context),
              style: Theme.of(context).elevatedButtonTheme.style, // Use theme's button style
              child: Text('Add Health Visit', style: AppStyles.buttonTextStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEmergencyReports(List<HealthVisit> reports, BuildContext context) {
    if (reports.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: AppStyles.cardDecoration(context),
        child: Center(
          child: Text(
            'No recent emergency reports.',
            style: AppStyles.bodyText2.copyWith(fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      );
    }

    return Container(
      decoration: AppStyles.cardDecoration(context),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: reports.length > 3 ? 3 : reports.length, // Show top 3
        itemBuilder: (context, index) {
          final report = reports[index];
          final motherName = Provider.of<DataManager>(context, listen: false).getMotherNameById(report.motherId);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mother: $motherName',
                    style: AppStyles.subTitle.copyWith(color: AppColors.dangerColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reported on: ${report.visitDate.toLocal().toString().split(' ')[0]}',
                    style: AppStyles.bodyText2.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Danger Signs: ${report.dangerSigns.join(', ')}',
                    style: AppStyles.bodyText2.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  if (report.notes.isNotEmpty)
                    Text(
                      'Notes: ${report.notes}',
                      style: AppStyles.bodyText2.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllMothersList(List<UserProfile> mothers, BuildContext context) {
    if (mothers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: AppStyles.cardDecoration(context),
        child: Center(
          child: Text(
            'No mothers registered yet.',
            style: AppStyles.bodyText2.copyWith(fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      );
    }

    return Container(
      decoration: AppStyles.cardDecoration(context),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mothers.length,
        itemBuilder: (context, index) {
          final mother = mothers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                child: Text(mother.name[0], style: AppStyles.headline3.copyWith(color: AppColors.primaryColor)),
              ),
              title: Text(mother.name, style: AppStyles.bodyText1.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
              subtitle: Text(
                'Status: ${mother.pregnancyStatus ?? 'N/A'}',
                style: AppStyles.bodyText2.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).hintColor, size: 18),
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/mother_profile',
                  arguments: {'motherId': mother.firebaseUid, 'role': 'CHW'},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
