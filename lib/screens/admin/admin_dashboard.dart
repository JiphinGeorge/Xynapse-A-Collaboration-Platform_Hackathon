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
  Timer? _refreshTimer; // <-- FIX #1

  int totalUsers = 0;
  int totalProjects = 0;
  int feedbackCount = 0;

  int usersToday = 0;
  int projectsToday = 0;
  int feedbackToday = 0;
  int activityToday = 0;

  List<Map<String, dynamic>> activityList = [];

  @override
  void initState() {
    super.initState();

    // FIX #2 – Prevent flashing animation replay
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1),
    )..forward();

    _loadAdminStats();
    _loadRecentActivity();

    // FIX #1 – Properly stored periodic timer
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadLiveMetrics();
      _loadRecentActivity();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // <-- FIX #1
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecentActivity() async {
    final db = DBHelper();
    activityList = await db.getRecentActivities();
    if (mounted) setState(() {});
  }

  String _timeAgo(String iso) {
    final time = DateTime.parse(iso);
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";
    return "${diff.inDays} days ago";
  }

  Future<void> _loadLiveMetrics() async {
    final db = DBHelper();
    usersToday = await db.countNewUsersToday();
    projectsToday = await db.countNewProjectsToday();
    feedbackToday = await db.countFeedbackToday();
    activityToday = await db.countActivityToday();
    if (mounted) setState(() {});
  }

  Future<void> _loadAdminStats() async {
    final db = DBHelper();
    totalUsers = await db.countUsers();
    totalProjects = await db.countProjects();
    feedbackCount = await db.countFeedback();
    _loadLiveMetrics();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog(context);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,

        backgroundColor: const Color(0xFF0E0E12),
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTitle("Dashboard Overview"),
              const SizedBox(height: 20),
              Expanded(child: _dashboardGrid(context)),
              const SizedBox(height: 12),
              _buildTitle("Recent Activity"),
              const SizedBox(height: 10),
              _recentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  // UI ELEMENTS --------------------------------------------------------------

  AppBar _buildAppBar() {
    return AppBar(
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
          child: GestureDetector(
            onTap: () => _showAdminLogoutDialog(context),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.amberAccent.withValues(alpha:  0.3),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Colors.amberAccent,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _dashboardGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _actionCard("Registered Users", Icons.people_alt_rounded, () {
          Navigator.pushNamed(context, '/admin/users');
        }),
        _actionCard("Projects Submitted", Icons.folder_copy_rounded, () {
          Navigator.pushNamed(context, '/admin/projects');
        }),
        _actionCard("Live Metrics", Icons.speed_rounded, () {
          Navigator.pushNamed(context, '/admin/liveMetrics');
        }),
        _actionCard("Feedback Messages", Icons.message_rounded, () {
          Navigator.pushNamed(context, '/admin/feedback').then((_) {
            _loadAdminStats();
            _loadRecentActivity();
          });
        }),
      ],
    );
  }

  Widget _actionCard(String title, IconData icon, VoidCallback onTap) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: _cardDecoration(),
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

  Widget _recentActivity() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amberAccent.withOpacity(0.2)),
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
            : activityList
                  .map(
                    (a) => _activityTile(a["action"], _timeAgo(a["timestamp"])),
                  )
                  .toList(),
      ),
    );
  }

  Widget _activityTile(String action, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.circle, color: Colors.amberAccent, size: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              action,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
          color: Colors.amberAccent.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------------------------

  void _showAdminLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Logout Admin?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/adminLogin",
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 100), () {
                SystemNavigator.pop();
              });
            },
            child: const Text(
              "Exit",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
