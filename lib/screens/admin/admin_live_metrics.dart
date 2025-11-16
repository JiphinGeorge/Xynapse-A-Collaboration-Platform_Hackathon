import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../db/db_helper.dart';

class AdminLiveMetricsScreen extends StatefulWidget {
  const AdminLiveMetricsScreen({super.key});

  @override
  State<AdminLiveMetricsScreen> createState() => _AdminLiveMetricsScreenState();
}

class _AdminLiveMetricsScreenState extends State<AdminLiveMetricsScreen> {
  int usersToday = 0;
  int projectsToday = 0;
  int feedbackToday = 0;
  int activityToday = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadMetrics();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _loadMetrics();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    final db = DBHelper();
    usersToday = await db.countNewUsersToday();
    projectsToday = await db.countNewProjectsToday();
    feedbackToday = await db.countFeedbackToday();
    activityToday = await db.countActivityToday();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),

      appBar: AppBar(
        backgroundColor: const Color(0xFF151518),
        elevation: 0,
        title: Text(
          "Live Metrics",
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Real-time Activity",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            _metricTile("New Users Today", usersToday),
            _metricTile("Projects Created Today", projectsToday),
            _metricTile("Feedback Submitted Today", feedbackToday),
            _metricTile("Activity Log Entries Today", activityToday),

            const Spacer(),

            Center(
              child: Text(
                "Auto-updating every 5 seconds",
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String label, int value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1F22), Color(0xFF141417)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.amberAccent.withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amberAccent.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 15),
          ),
          Text(
            value.toString(),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
