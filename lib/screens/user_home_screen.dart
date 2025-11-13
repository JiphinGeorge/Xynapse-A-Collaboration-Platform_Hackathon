import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _query = '';
  String _selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Tech",
    "Social",
    "Research",
    "Design",
    "Event",
    "Others"
  ];

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProjectProvider>(context);

    // --- Filtered Projects ---
    List<Project> publicList =
        prov.allPublicProjects.where(_filterProject).toList();

    List<Project> myList =
        prov.myProjects.where(_filterProject).toList();

    List<Project> collabList =
        prov.collaborations.where(_filterProject).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              _header(prov),
              const SizedBox(height: 20),
              _searchBar(),
              const SizedBox(height: 15),
              _categoryChips(),
              const SizedBox(height: 20),

              // MY PROJECTS
              if (myList.isNotEmpty) _sectionTitle("My Projects"),
              if (myList.isNotEmpty) _projectList(myList, prov),

              const SizedBox(height: 10),

              // COLLABORATIONS
              if (collabList.isNotEmpty)
                _sectionTitle("Collaborative Projects"),
              if (collabList.isNotEmpty)
                _projectList(collabList, prov),

              const SizedBox(height: 10),

              // PUBLIC PROJECTS
              _sectionTitle("Explore Public Projects"),
              _projectList(publicList, prov),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.pushNamed(context, "/addProject");
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ----------------------------- UI COMPONENTS -----------------------------

  Widget _header(ProjectProvider prov) {
    final user = prov.users.firstWhere(
      (u) => u.id == prov.currentUserId,
      orElse: () => prov.users.first,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello,",
                style: GoogleFonts.poppins(
                    fontSize: 22, color: Colors.white70)),
            Text(user.name,
                style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.blueAccent,
          child: Text(
            user.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        )
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Search projects...",
          hintStyle: TextStyle(color: Colors.white54),
          icon: Icon(Icons.search, color: Colors.white70),
        ),
        onChanged: (value) => setState(() => _query = value),
      ),
    );
  }

  Widget _categoryChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((cat) {
          final selected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(cat),
              selected: selected,
              labelStyle: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: Colors.amber,
              backgroundColor: Colors.grey.shade800,
              onSelected: (_) {
                setState(() => _selectedCategory = cat);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _projectList(List<Project> list, ProjectProvider prov) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text("No projects available",
            style: TextStyle(color: Colors.white70)),
      );
    }

    return Column(
      children: list.map((p) => _projectCard(p, prov)).toList(),
    );
  }

  Widget _projectCard(Project p, ProjectProvider prov) {
    final bool isMine = p.creatorId == prov.currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p.title,
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              if (isMine)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => prov.deleteProject(p.id!),
                )
            ],
          ),

          const SizedBox(height: 4),

          // Category Badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.amber.withOpacity(0.9),
            ),
            child: Text(
              p.category,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            p.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(color: Colors.white70),
          ),

          const SizedBox(height: 10),

          // Join button (only if public & not mine)
          if (!isMine && p.isPublic == 1)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () => prov.joinProject(p.id!),
              child: const Text("Join Project"),
            ),
        ],
      ),
    );
  }

  // ---------------- FILTER FUNCTION ----------------

  bool _filterProject(Project p) {
    bool matchTitle = p.title.toLowerCase().contains(_query.toLowerCase());
    bool matchCategory = _selectedCategory == "All" ||
        p.category.toLowerCase() ==
            _selectedCategory.toLowerCase();

    return matchTitle && matchCategory;
  }
}
