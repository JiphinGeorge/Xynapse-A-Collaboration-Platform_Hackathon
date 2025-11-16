import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../../db/db_helper.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  int totalUsers = 0;
  int totalProjects = 0;
  int pending = 0;
  int feedbackCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadAdminStats();
    _loadRecentActivity();
    Timer.periodic(const Duration(seconds: 5), (_) {
      _loadRecentActivity();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> activityList = [];

  Future<void> _loadRecentActivity() async {
    final db = DBHelper();
    activityList = await db.getRecentActivities();
    setState(() {});
  }

  String _timeAgo(String isoTime) {
    final time = DateTime.parse(isoTime);
    final diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";
    return "${diff.inDays} days ago";
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Exit Xynapse?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to close the app?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Future.delayed(const Duration(milliseconds: 100), () {
                  SystemNavigator.pop(); // <--- REAL APP EXIT
                });
              },
              child: const Text(
                "Exit",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _loadAdminStats() async {
    final db = DBHelper();

    totalUsers = await db.countUsers();
    totalProjects = await db.countProjects();
    pending = await db.countPendingProjects();
    feedbackCount = await db.countFeedback();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _showExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0E12),

        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF151518),
          title: Text(
            "Xynapse Admin Panel",
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.amberAccent.withValues(alpha: 0.3),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.amberAccent,
                  size: 22,
                ),
              ),
            ),
          ],
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // TITLE
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Dashboard Overview",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // DASHBOARD GRID
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildDashboardActionCard(
                      title: "Registered Users",
                      icon: Icons.people_alt_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/users');
                      },
                    ),

                    _buildDashboardActionCard(
                      title: "Projects Submitted",
                      icon: Icons.folder_copy_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/projects');
                      },
                    ),

                    _buildDashboardCard(
                      title: "Pending Approvals",
                      value: pending.toString(),
                      icon: Icons.pending_actions_rounded,
                    ),

                    _buildDashboardActionCard(
                      title: "Feedback Messages",
                      icon: Icons.message_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/feedback').then((
                          _,
                        ) {
                          _loadRecentActivity(); // refresh admin screen
                          _loadAdminStats(); // update counts
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // RECENT ACTIVITY
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Activity",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                flex: 0,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1C1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amberAccent.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: activityList.isEmpty
                        ? [
                            Center(
                              child: Text(
                                "No recent activity",
                                style: GoogleFonts.inter(color: Colors.white54),
                              ),
                            ),
                          ]
                        : activityList.map((a) {
                            return _buildActivityTile(
                              a["action"],
                              _timeAgo(a["timestamp"]),
                            );
                          }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1C1E), Color(0xFF121315)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.amberAccent.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amberAccent.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.amberAccent, size: 34),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1F22), Color(0xFF141417)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.amberAccent.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amberAccent.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.amberAccent, size: 36),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.circle, color: Colors.amberAccent, size: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
