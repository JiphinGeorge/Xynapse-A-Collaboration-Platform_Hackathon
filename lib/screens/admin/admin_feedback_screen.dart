import 'package:flutter/material.dart';
import '../../db/db_helper.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  List<Map<String, dynamic>> feedbackList = [];
  final db = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    feedbackList = await db.getAllFeedback();
    setState(() {});
  }

  String _timeAgo(String isoTime) {
    final date = DateTime.parse(isoTime);
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";
    return "${diff.inDays} days ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),

      appBar: AppBar(
        backgroundColor: const Color(0xFF151518),
        title: const Text("Feedback Messages"),
      ),

      body: feedbackList.isEmpty
          ? const Center(
              child: Text(
                "No feedback yet",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: feedbackList.length,
              itemBuilder: (context, index) {
                final f = feedbackList[index];

                return Dismissible(
                  key: ValueKey(f["id"]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  onDismissed: (_) async {
                    await db.deleteFeedback(f["id"]);
                    _loadFeedback();
                  },

                  child: Card(
                    color: const Color(0xFF1A1C1E),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),

                    child: ListTile(
                      title: Text(
                        f["name"] ?? "Unknown User",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f["email"] ?? "",
                            style: const TextStyle(color: Colors.white54),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            f["message"],
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _timeAgo(f["created_at"]),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
