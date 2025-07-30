import 'package:flutter/material.dart';

class HealthVisitFormPage extends StatefulWidget {
  const HealthVisitFormPage({super.key});

  @override
  State<HealthVisitFormPage> createState() => _HealthVisitFormPageState();
}

class _HealthVisitFormPageState extends State<HealthVisitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  String? pregnancyStage;
  String? vitalSigns;
  String? dangerSigns;
  String? healthAdvice;
  String? medicationReferral;
  String? notes;

  @override
  void initState() {
    super.initState();
    dateController.text = DateTime.now().toString().split(' ')[0]; // auto date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add/Edit Health Visit')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date of Visit'),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'Pregnancy Stage / Postpartum Day'),
                items: [
                  'First Trimester',
                  'Second Trimester',
                  'Third Trimester',
                  'Postpartum'
                ].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => pregnancyStage = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Vital Signs (BP, Temp, etc.)'),
                onChanged: (val) => vitalSigns = val,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Observed Danger Signs'),
                onChanged: (val) => dangerSigns = val,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Health Advice Given'),
                onChanged: (val) => healthAdvice = val,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Medication or Referral'),
                onChanged: (val) => medicationReferral = val,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Midwife\'s Notes'),
                onChanged: (val) => notes = val,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Handle photo upload and signature
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Form Submitted")));
                  }
                },
                child: const Text("Submit Visit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
