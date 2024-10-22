import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

final OdooClient orpc = OdooClient('https://schoology.notion-edu.com'); // Odoo URL

void main() async {
  await orpc.authenticate('Mobile', 'admin', 'P@ssw0rd885566'); // Odoo DB, username, password
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odoo Clinic Module',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ClinicHomePage(),
    );
  }
}

class ClinicHomePage extends StatefulWidget {
  const ClinicHomePage({Key? key}) : super(key: key);

  @override
  _ClinicHomePageState createState() => _ClinicHomePageState();
}

class _ClinicHomePageState extends State<ClinicHomePage> {
  List<dynamic> clinicData = [];

  @override
  void initState() {
    super.initState();
    fetchClinicData();
  }

  // Method to fetch clinic data using Odoo RPC
  Future<void> fetchClinicData() async {
    try {
      final res = await orpc.callKw({
        'model': 'clinic.notion',  // Odoo model name
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'act_name',           // Student Name
            'grade_level',        // Grade Level
            'class_name',         // Class
            'date',               // Date/time
            'inc',                // Reason for visit
            'diagnosis',          // Diagnosis
            'intervention_type',  // Intervention type
            'intervention',       // Intervention
            'recommendation',     // Recommendation
            'confirmation'        // Confirmation
          ],
          'limit': 5
        },
      });

      setState(() {
        clinicData = res;
      });
    } on OdooException catch (e) {
      setState(() {
        clinicData = [];
        print('Error: ${e.message}');
      });
    }
  }

  // Method to build the display form for each clinic entry
  Widget buildClinicDataForm(dynamic data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          BuildTextFormField(label: 'Student Name', value: data['act_name']),
          BuildTextFormField(label: 'Grade Level', value: data['grade_level']),
          BuildTextFormField(label: 'Class', value: data['class_name']),
          BuildTextFormField(label: 'Date/Time', value: data['date']),
          BuildTextFormField(label: 'Reason for Visit', value: data['inc']),
          BuildTextFormField(label: 'Diagnosis', value: data['diagnosis']),
          BuildTextFormField(label: 'Intervention Type', value: data['intervention_type']),
          BuildTextFormField(label: 'Intervention', value: data['intervention']),
          BuildTextFormField(label: 'Recommendation', value: data['recommendation']),
          BuildTextFormField(label: 'Confirmation', value: data['confirmation']),
          const Divider(thickness: 2),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odoo Clinic Module'),
      ),
      body: clinicData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: clinicData.length,
        itemBuilder: (context, index) {
          return buildClinicDataForm(clinicData[index]);
        },
      ),
    );
  }
}

// Custom TextFormField widget for displaying data
class BuildTextFormField extends StatelessWidget {
  final String label;
  final dynamic value;

  const BuildTextFormField({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: value != null ? value.toString() : 'N/A',
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
