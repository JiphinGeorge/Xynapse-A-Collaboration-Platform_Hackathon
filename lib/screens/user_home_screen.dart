import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xynapse/screens/project_search_filter.dart';
import '../providers/project_provider.dart';
import 'package:flutter/services.dart';

class UserHomeScreen extends StatefulWidget  {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> with TickerProviderStateMixin {
  // 🔎 Search & Category state
  final TextEditingController searchC = TextEditingController();
  String selectedCategory = "All";
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);

    // 🔥 Filter ALL 3 lists
    final explore = provider.getPublicFiltered(searchC.text, selectedCategory);
    final myProjects = provider.getMyFiltered(searchC.text, selectedCategory);
    final collaborations = provider.getCollabFiltered(
      searchC.text,
      selectedCategory,
    );

    return PopScope(
      canPop: false, // prevents default back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitDialog(context);
        }
      },
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Xynapse",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 2,
          ),
          // floatingActionButton: FloatingActionButton.extended(
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/addProject');
          //   },
          //   backgroundColor: Colors.blueAccent,
          //   icon: const Icon(Icons.add),
          //   label: const Text(
          //     "Create Project",
          //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          //   ),
          // ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () => Navigator.pushNamed(context, '/addProject'),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Project",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          body: RefreshIndicator(
            onRefresh: () async {
              await provider.refreshAll();
            },

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              child: Padding(
                padding: const EdgeInsets.all(16.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔎 Search + Filter Section
                    ProjectSearchFilter(
                      searchController: searchC,
                      selectedCategory: selectedCategory,
                      onSearchChanged: (_) => setState(() {}),
                      onCategoryChanged: (cat) {
                        setState(() => selectedCategory = cat);
                      },
                    ),

                    const SizedBox(height: 25),

                    // 🔹 EXPLORE PROJECTS
                    const Text(
                      "Explore Projects",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    explore.isEmpty
                        ? _emptyMessage("No matching public projects.")
                        : _horizontalProjectList(context, explore),

                    const SizedBox(height: 25),

                    // 🔹 MY PROJECTS
                    const Text(
                      "My Projects",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    myProjects.isEmpty
                        ? _emptyMessage("No matching projects you created.")
                        : _horizontalProjectList(context, myProjects),

                    const SizedBox(height: 25),

                    // 🔹 COLLABORATIONS
                    const Text(
                      "Collaborations",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    collaborations.isEmpty
                        ? _emptyMessage("No matching collaborations.")
                        : _horizontalProjectList(context, collaborations),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  // -----------------------------------------------------------------
  Widget _emptyMessage(String msg) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: Text(msg, style: const TextStyle(color: Colors.grey)),
    );
  }

  // -----------------------------------------------------------------
  // HORIZONTAL PROJECT LIST
  // -----------------------------------------------------------------
  Widget _horizontalProjectList(BuildContext context, List projects) {
    return SizedBox(
      height: 160,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: projects.length,

        itemBuilder: (context, index) {
          final project = projects[index];

          return Container(
            width: 230,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),

              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                Text(
                  project.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),

                const Spacer(),

                Align(
                  alignment: Alignment.bottomRight,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/projectDetails',
                        arguments: project,
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(20, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),

                    child: const Text("View"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
