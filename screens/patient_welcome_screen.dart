import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'profile_selection_screen.dart';
import 'find_doctor_screen.dart';
import 'patient_profile_display_screen.dart';
import 'patient_chats_list_screen.dart';
import 'chat_screen.dart';
import 'patient_profile_completion_screen.dart';
import 'patient_prescription_screen.dart';
import 'appointment_status_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String patientName;
  final String patientId;

  const WelcomeScreen({
    super.key,
    required this.patientName,
    required this.patientId,
  });

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _time = '';
  late Timer _timer;
  int unreadNotifications = 0;
  List<Map<String, dynamic>> notifications = [];
  bool showDropdown = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    _setupNotificationsStream();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final newTime = _formatTime();
    if (mounted && newTime != _time) {
      setState(() {
        _time = newTime;
      });
    }
  }

  String _formatTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _setupNotificationsStream() {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('receiver_id', isEqualTo: widget.patientId)
        .where('read', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          notifications = snapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
      }
    });
  }

  void _handleNotificationClick(Map<String, dynamic> notification) {
    String type = notification['type'] ?? '';
    switch (type) {
      case 'message':
        if (notification['chat_id'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: notification['chat_id'],
                doctorId: notification['sender_id'],
                patientId: widget.patientId,
              ),
            ),
          );
        }
        break;
      case 'appointment':
        setState(() {
          _selectedIndex = 1;
        });
        break;
      case 'prescription':
        setState(() {
          _selectedIndex = 2;
        });
        break;
      case 'report':
        setState(() {
          _selectedIndex = 3;
        });
        break;
    }
  }

  void _toggleDropdown() {
    if (mounted) {
      setState(() {
        showDropdown = !showDropdown;
      });
    }
  }

  void _markAsRead(String notificationId) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId) // Use document ID
        .update({'status': 'read'});
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ProfileSelectionScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80), // space for nav bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with greeting and avatar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, ${widget.patientName}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          const Text('Find your doctor',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.person,
                            size: 28, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search doctor...',
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Banner card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Your Health is\nOur Priority',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FindDoctorScreen(
                                            patientId: widget.patientId),
                                      ),
                                    );
                                  },
                                  child: const Text('Connect to Doctor'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            height: 90,
                            width: 90,
                            child: Icon(Icons.medical_services,
                                size: 70,
                                color: Colors
                                    .blue.shade200), // Placeholder illustration
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Real dashboard cards (restored functionality)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text('What do you need?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: [
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width - 20 * 2 - 18) /
                                2,
                        child: _beautifulDashboardCard(
                          icon: Icons.dashboard,
                          title: "Patient Profile Display",
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PatientProfileDisplayScreen(
                                        patientId: widget.patientId),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width - 20 * 2 - 18) /
                                2,
                        child: _beautifulDashboardCard(
                          icon: Icons.account_circle,
                          title: "Patient Profile",
                          color: Colors.indigo,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PatientProfileCompletionScreen(
                                        patientId: widget.patientId),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width - 20 * 2 - 18) /
                                2,
                        child: _beautifulDashboardCard(
                          icon: Icons.local_hospital,
                          title: "Consult a Doctor",
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FindDoctorScreen(
                                    patientId: widget.patientId),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width - 20 * 2 - 18) /
                                2,
                        child: _beautifulDashboardCard(
                          icon: Icons.medical_information,
                          title: "Reports",
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientPrescriptionScreen(
                                    patientId: widget.patientId),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Top Doctor section with real data
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Top Doctor',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FindDoctorScreen(patientId: widget.patientId),
                            ),
                          );
                        },
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('doctors')
                        .limit(5)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('No doctors found.');
                      }
                      final docs = snapshot.data!.docs;
                      return SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.10),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      (data['name'] ?? '?')
                                              .toString()
                                              .isNotEmpty
                                          ? data['name'][0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(data['name'] ?? 'Unknown',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                        Text(
                                            data['specialization'] ??
                                                'Specialist',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey)),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.amber, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                                (data['rating']?.toString() ??
                                                    '5.0'),
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                            const SizedBox(width: 6),
                                            Text('(reviews)',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24), // Space above bottom nav bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _categoryCard(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _doctorCard(
      String name, String specialty, double rating, int reviews) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.person, size: 32, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(specialty,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(rating.toString(),
                        style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text('($reviews)',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavBar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            color: Colors.blue,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            color: Colors.blueGrey,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            color: Colors.blueGrey,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.blueGrey,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal.shade600),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    String notifType = notification['type'] ?? 'general';
    IconData iconData;
    Color iconColor;

    switch (notifType) {
      case 'appointment':
        iconData = Icons.calendar_today;
        iconColor = Colors.orange;
        break;
      case 'message':
        iconData = Icons.chat;
        iconColor = Colors.green;
        break;
      case 'prescription':
        iconData = Icons.medication;
        iconColor = Colors.blue;
        break;
      case 'report':
        iconData = Icons.assessment;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.green;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.2),
        child: Icon(iconData, color: iconColor),
      ),
      title: Text(
        notification['title'] ?? 'Notification',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification['message'] ?? ''),
          if (notification['timestamp'] != null)
            Text(
              DateFormat('MMM d, h:mm a').format(
                (notification['timestamp'] as Timestamp).toDate(),
              ),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
        ],
      ),
      onTap: () {
        _markAsRead(notification['id']);
        _handleNotificationClick(notification);
        setState(() => showDropdown = false);
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade200]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.patientName,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(_time,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _beautifulDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
