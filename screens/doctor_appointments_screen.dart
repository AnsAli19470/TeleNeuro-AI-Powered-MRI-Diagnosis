import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'chat_screen.dart';
import 'video_call_screen.dart';
import 'chat_service.dart';
import 'doctor_chat_screen.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorAppointmentsScreen({super.key, required this.doctorId});

  @override
  _DoctorAppointmentsScreenState createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();
  DateTime selectedDate = DateTime.now();
  bool isDarkMode = false;
  bool showAllAppointments = false;
  String _doctorName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchDoctorName();
  }

  void _toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void _toggleAppointmentsView() {
    setState(() {
      showAllAppointments = !showAllAppointments;
    });
  }

  void _changeDate(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
    });
  }

  Future<void> _fetchDoctorName() async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('doctors').doc(widget.doctorId).get();
      if (doc.exists && mounted) {
        setState(() {
          _doctorName = doc['name'] ?? "Unknown Doctor";
        });
      }
    } catch (e) {
      print("Error fetching doctor name: $e");
      if (mounted) {
        setState(() {
          _doctorName = "Unknown Doctor";
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    QuerySnapshot snapshot = await firestore
        .collection("appointments")
        .where("doctor_id", isEqualTo: widget.doctorId)
        .orderBy("date_time", descending: true)
        .get();

    List<Map<String, dynamic>> appointments = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Get client name from client_name field or from clients collection
      if (!data.containsKey('client_name') && data.containsKey('client_id')) {
        try {
          DocumentSnapshot clientSnapshot = await firestore
              .collection("clients")
              .doc(data['client_id'])
              .get();

          var clientData = clientSnapshot.data() as Map<String, dynamic>?;
          if (clientData != null && clientData.containsKey('name')) {
            data['client_name'] = clientData['name'];
          }
        } catch (e) {
          print("Error fetching client data: $e");
        }
      }

      // If no client name was found, use a default
      if (!data.containsKey('client_name')) {
        data['client_name'] = "Unknown Patient";
      }

      // Format time if available
      DateTime? appointmentDate;
      if (data['date_time'] != null) {
        if (data['date_time'] is Timestamp) {
          appointmentDate = (data['date_time'] as Timestamp).toDate();
        } else if (data['date_time'] is String) {
          try {
            appointmentDate = DateTime.parse(data['date_time'] as String);
          } catch (e) {
            print("Error parsing date_time string: $e");
            // Handle parsing error, leave appointmentDate as null
          }
        }
      }

      if (appointmentDate != null) {
        data['formatted_time'] =
            DateFormat('dd MMM yyyy, hh:mm a').format(appointmentDate);
      } else {
        data['formatted_time'] = "Time not specified";
      }

      data['appointment_id'] = doc.id;
      appointments.add(data);
    }
    return appointments;
  }

  Future<void> _updateAppointmentStatus(
      String appointmentId, String clientId, String status) async {
    try {
      // Update appointment status in Firestore
      await firestore
          .collection("appointments")
          .doc(appointmentId)
          .update({"status": status});

      // Send notification to client about the status update
      await _storeNotification(clientId, status, appointmentId);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment $status successfully")),
      );

      // Refresh the UI
      setState(() {});
    } catch (e) {
      print("Error updating appointment status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Failed to update appointment status")),
      );
    }
  }

  Future<void> _storeNotification(
      String clientId, String status, String appointmentId) async {
    try {
      await firestore.collection("notifications").add({
        "receiver_id": clientId,
        "title": "Appointment Update",
        "message": "Your appointment has been $status by the doctor.",
        "timestamp": FieldValue.serverTimestamp(),
        "read": false,
        "type": "appointment_status",
        "appointment_id": appointmentId
      });
    } catch (e) {
      print("Error storing notification: $e");
    }
  }

  Future<void> _initiateChat(String doctorId, String patientId) async {
    try {
      String chatId = await _chatService.getChatId(doctorId, patientId);
      if (chatId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorChatScreen(
              chatId: chatId,
              doctorId: doctorId,
              patientId: patientId,
              doctorName: _doctorName,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to initiate chat")),
        );
      }
    } catch (e) {
      print("Error starting chat: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _initiateVideoCall(String doctorId, String patientId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          doctorId: doctorId,
          patientId: patientId,
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
        icon: Icon(Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.teal[800]),
        onPressed: () {
          setState(() {
            selectedDate = selectedDate.subtract(Duration(days: 7));
          });
        },
      ),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            DateTime date = selectedDate
                .subtract(Duration(days: selectedDate.weekday - 1 - index));
            bool isSelected = date.day == selectedDate.day;

            return GestureDetector(
              onTap: () => _changeDate(date),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal[300] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      DateFormat.E().format(date),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${date.day}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      IconButton(
        icon: Icon(Icons.arrow_forward,
            color: isDarkMode ? Colors.white : Colors.teal[800]),
        onPressed: () {
          setState(() {
            selectedDate = selectedDate.add(Duration(days: 7));
          });
        },
      ),
    ]);
  }

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.teal[50],
      appBar: AppBar(
        title: const Text("Appointments"),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.teal[700],
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: _toggleDarkMode,
          ),
          IconButton(
            icon:
                Icon(showAllAppointments ? Icons.filter_list : Icons.list_alt),
            onPressed: _toggleAppointmentsView,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWeekBar(),
          Expanded(
            child: FutureBuilder(
              future: _fetchAppointments(),
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerEffect();
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No appointments found"));
                }

                return ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: snapshot.data!.map((data) {
                    final status = data['status'] ?? "pending";
                    final clientId = data['client_id'] ?? "";
                    final appointmentId = data['appointment_id'] ?? "";
                    final appointmentType =
                        data['appointment_type'] ?? "Unknown";
                    final clientName = data['client_name'] ?? "Unknown Patient";
                    final formattedTime =
                        data['formatted_time'] ?? "Time not specified";

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        clientName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.teal[900],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Type: $appointmentType",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode
                                              ? Colors.grey[300]
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _getStatusColor(status),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (status == "pending")
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _updateAppointmentStatus(
                                        appointmentId, clientId, "rejected"),
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    label: const Text("Reject",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _updateAppointmentStatus(
                                        appointmentId, clientId, "accepted"),
                                    icon: const Icon(Icons.check,
                                        color: Colors.white),
                                    label: const Text("Accept",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              )
                            else if (status == "accepted")
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _initiateChat(
                                        widget.doctorId, clientId),
                                    icon: const Icon(Icons.chat,
                                        color: Colors.white),
                                    label: const Text("Chat",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _initiateVideoCall(
                                        widget.doctorId, clientId),
                                    icon: const Icon(Icons.video_call,
                                        color: Colors.white),
                                    label: const Text("Video Call",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
