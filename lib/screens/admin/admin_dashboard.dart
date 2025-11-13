import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                  _buildDashboardCard(
                    title: "Projects Submitted",
                    value: "32",
                    icon: Icons.folder_copy_rounded,
                  ),
                  _buildDashboardCard(
                    title: "Pending Approvals",
                    value: "6",
                    icon: Icons.pending_actions_rounded,
                  ),
                  _buildDashboardCard(
                    title: "Feedback Messages",
                    value: "14",
                    icon: Icons.message_rounded,
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
                  children: [
                    _buildActivityTile("New user registered", "2 min ago"),
                    _buildActivityTile("New project submitted", "12 min ago"),
                    _buildActivityTile(
                      "Admin approved a project",
                      "25 min ago",
                    ),
                    _buildActivityTile("Feedback received", "1 hr ago"),
                  ],
                ),
              ),
            ),
          ],
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
