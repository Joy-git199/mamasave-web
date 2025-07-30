
import 'package:flutter/material.dart';

class HealthVisitFormPage extends StatefulWidget {
  const HealthVisitFormPage({super.key});

  @override
  State<HealthVisitFormPage> createState() => _HealthVisitFormPageState();
}

class _HealthVisitFormPageState extends State<HealthVisitFormPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime visitDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add/Edit Health Visit")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            ListTile(
              title: const Text("Date of Visit"),
              subtitle: Text("${visitDate.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: visitDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => visitDate = picked);
              },
            ),
            _buildTextField("Pregnancy Stage/Postpartum Day"),
            _buildTextField("Blood Pressure (BP)"),
            _buildTextField("Temperature (°C)"),
            _buildTextField("Bleeding Details"),
            _buildTextField("Danger Signs Observed"),
            _buildTextField("Health Advice Given"),
            _buildTextField("Medication or Referral"),
            _buildTextField("Midwife’s Notes"),
            const SizedBox(height: 12),
            const Text("Referral/Test Result Photo (optional)"),
            Container(
              height: 100,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              color: Colors.grey[300],
              child: const Center(
                child: Text("Image placeholder"),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Save logic here
                }
              },
              child: const Text("Save Visit"),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}
