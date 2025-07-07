import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'booking_confirmation_screen.dart';
import 'patient_chat_screen.dart';
import 'chat_service.dart';
import 'video_call_screen.dart';
import 'brain_tumor_detector.dart';
import 'alzheimer_detector.dart';
import 'multiple_sclerosis_detector.dart';
import 'firestore_service.dart';
import 'ai_diagnose_screen.dart';

class AppointmentTypeScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String specialization;
  final String channelName;

  const AppointmentTypeScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.channelName,
  });

  @override
  State<AppointmentTypeScreen> createState() => _AppointmentTypeScreenState();
}

class _AppointmentTypeScreenState extends State<AppointmentTypeScreen> {
  final ChatService _chatService = ChatService();
  final FirestoreService _firestoreService = FirestoreService();
  String? chatId;
  bool _isLoading = false;
  String _consultationAppointmentStatus =
      'none'; // Tracks status in appointments collection

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _checkConsultationAppointmentStatus(); // Check status of the consultation appointment
  }

  Future<void> _checkConsultationAppointmentStatus() async {
    setState(() => _isLoading = true);
    try {
      final appointmentSnapshot = await FirebaseFirestore.instance
          .collection("appointments")
          .where("client_id", isEqualTo: widget.patientId)
          .where("doctor_id", isEqualTo: widget.doctorId)
          .where("appointment_type", isEqualTo: "Consultation Request")
          .limit(1)
          .get();

      if (appointmentSnapshot.docs.isNotEmpty) {
        final data =
            appointmentSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _consultationAppointmentStatus = data['status'] ?? 'none';
        });
      } else {
        setState(() {
          _consultationAppointmentStatus = 'none';
        });
      }
    } catch (e) {
      print("Error checking consultation appointment status: $e");
      setState(() {
        _consultationAppointmentStatus =
            'error'; // Handle error state if needed
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendConsultationAppointmentRequest() async {
    setState(() => _isLoading = true);
    try {
      // Use the bookAppointment method to create an appointment with type 'Consultation Request'
      await _firestoreService.bookAppointment(
        widget.patientId,
        widget.doctorId,
        appointmentType: "Consultation Request",
      );

      // Refresh the status after sending the request
      await _checkConsultationAppointmentStatus();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Consultation request sent! Please wait for doctor to accept."),
        backgroundColor: Colors.orangeAccent,
      ));
    } catch (e) {
      print("Error sending consultation appointment request: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending request: $e")),
      );
    }
  }

  Future<void> _initializeChat() async {
    try {
      String id =
          await _chatService.getChatId(widget.doctorId, widget.patientId);
      if (id.isNotEmpty) {
        setState(() => chatId = id);
      }
    } catch (e) {
      print("Error initializing chat: $e");
    }
  }

  void _navigateToChat(String chatId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientChatScreen(
          chatId: chatId,
          doctorId: widget.doctorId,
          patientId: widget.patientId,
          patientName: widget.patientName,
        ),
      ),
    );
  }

  void _startVideoCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          doctorId: widget.doctorId,
          patientId: widget.patientId,
        ),
      ),
    );
  }

  void _navigateToBrainTumorDetector() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrainTumorDetector(
          patientId: widget.patientId,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  void _navigateToAlzheimerDetector() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlzheimerDetector(
          patientId: widget.patientId,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  void _navigateToMultipleSclerosisDetector() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultipleSclerosisDetector(
          patientId: widget.patientId,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = Colors.teal,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Appointment"),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildOptionCard(
                    icon: Icons.message,
                    title: "Message",
                    subtitle: "Send a message to the doctor",
                    onTap: _sendConsultationAppointmentRequest,
                    color: Colors.blueGrey,
                  ),
                  _buildOptionCard(
                    icon: Icons.call,
                    title: "Call",
                    subtitle: "Start a call with the doctor",
                    onTap: _startVideoCall,
                    color: Colors.blueGrey,
                  ),
                  _buildOptionCard(
                    icon: Icons.lightbulb_outline,
                    title: "AI Diagnose",
                    subtitle: "Use AI to analyze for diseases",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AIDiagnoseScreen(
                            patientId: widget.patientId,
                            doctorId: widget.doctorId,
                          ),
                        ),
                      );
                    },
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            ),
    );
  }
}
