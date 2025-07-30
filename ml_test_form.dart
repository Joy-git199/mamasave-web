import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MLTestFormPage extends StatefulWidget {
  @override
  _MLTestFormPageState createState() => _MLTestFormPageState();
}

class _MLTestFormPageState extends State<MLTestFormPage> {
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController bodyTempController = TextEditingController();
  final TextEditingController oxygenController = TextEditingController();
  final TextEditingController contractionFreqController = TextEditingController();
  final TextEditingController contractionIntensityController = TextEditingController();

  String result = "";

  Future<void> sendData() async {
    final url = Uri.parse("http://YOUR_IP:8000/predict"); // Replace with your FastAPI address

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "HeartRate": int.parse(heartRateController.text),
        "BodyTemp": double.parse(bodyTempController.text),
        "BloodOxygen": int.parse(oxygenController.text),
        "ContractionFreq": int.parse(contractionFreqController.text),
        "ContractionIntensity": int.parse(contractionIntensityController.text),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        result = "Prediction: ${data['prediction']}";
      });
    } else {
      setState(() {
        result = "Error: ${response.statusCode}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test ML Backend")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: heartRateController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Heart Rate")),
            TextField(controller: bodyTempController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Body Temp")),
            TextField(controller: oxygenController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Blood Oxygen")),
            TextField(controller: contractionFreqController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Contraction Freq")),
            TextField(controller: contractionIntensityController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Contraction Intensity")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: sendData, child: Text("Send to Backend")),
            SizedBox(height: 20),
            Text(result, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
