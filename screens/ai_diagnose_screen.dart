import 'package:flutter/material.dart';
import 'brain_tumor_detector.dart';
import 'alzheimer_detector.dart';
import 'multiple_sclerosis_detector.dart';

class AIDiagnoseScreen extends StatelessWidget {
  final String patientId;
  final String doctorId;
  const AIDiagnoseScreen(
      {Key? key, required this.patientId, required this.doctorId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Diagnose',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _aiOptionCard(
              context,
              icon: Icons.lightbulb_outline,
              title: 'Brain Tumor',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BrainTumorDetector(
                      patientId: patientId,
                      doctorId: doctorId,
                    ),
                  ),
                );
              },
            ),
            _aiOptionCard(
              context,
              icon: Icons.memory,
              title: "Alzheimer's",
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlzheimerDetector(
                      patientId: patientId,
                      doctorId: doctorId,
                    ),
                  ),
                );
              },
            ),
            _aiOptionCard(
              context,
              icon: Icons.scatter_plot,
              title: 'Multiple Sclerosis',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultipleSclerosisDetector(
                      patientId: patientId,
                      doctorId: doctorId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiOptionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.only(bottom: 24),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueGrey),
        onTap: onTap,
      ),
    );
  }
}
