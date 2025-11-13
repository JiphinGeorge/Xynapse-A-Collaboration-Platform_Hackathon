import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/project_provider.dart';
import '../providers/theme_provider.dart';
import '../models/project_model.dart';
import 'add_edit_project_screen.dart';

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
    "Others",
  ];

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProjectProvider>(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Safe loading state
    if (prov.users.isEmpty || prov.currentUserId == 0) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    // Filter lists
    final publicList = prov.getPublicFiltered(_query, _selectedCategory);
    final myList = prov.getMyFiltered(_query, _selectedCategory);
    final collabList = prov.getCollabFiltered(_query, _selectedCategory);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              _header(prov),
              const SizedBox(height: 20),
              _searchBar(theme),
              const SizedBox(height: 15),
              _categoryChips(theme, isDark),
              const SizedBox(height: 20),

              if (myList.isNotEmpty) _sectionTitle("My Projects", theme),
              if (myList.isNotEmpty) _projectList(myList, prov, theme, isDark),

              const SizedBox(height: 10),

              if (collabList.isNotEmpty)
                _sectionTitle("Collaborative Projects", theme),
              if (collabList.isNotEmpty)
                _projectList(collabList, prov, theme, isDark),

              const SizedBox(height: 10),

              _sectionTitle("Explore Public Projects", theme),
              _projectList(publicList, prov, theme, isDark),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProjectScreen()),
          );
        },

        child: const Icon(Icons.add),
      ),
    );
  }

  /// --------------------------- HEADER ---------------------------
  Widget _header(ProjectProvider prov) {
    final user = prov.users.firstWhere(
      (u) => u.id == prov.currentUserId,
      orElse: () => prov.users.first,
    );

    final themeProv = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello,", style: GoogleFonts.poppins(fontSize: 22)),
            Text(
              user.name,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        Row(
          children: [
            IconButton(
              icon: Icon(
                themeProv.isDark ? Icons.light_mode : Icons.dark_mode,
                color: Colors.amber,
                size: 28,
              ),
              onPressed: themeProv.toggleTheme,
            ),

            const SizedBox(width: 6),

            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.blueAccent,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ------------------------- SEARCH BAR -------------------------
  Widget _searchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        style: TextStyle(color: theme.textTheme.bodyLarge!.color),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Search projects...",
          hintStyle: TextStyle(color: theme.hintColor),
          icon: Icon(Icons.search, color: theme.iconTheme.color),
        ),
        onChanged: (value) => setState(() => _query = value),
      ),
    );
  }

  /// ----------------------- CATEGORY CHIPS -----------------------
  Widget _categoryChips(ThemeData theme, bool isDark) {
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
                color: selected
                    ? Colors.black
                    : theme.textTheme.bodyLarge!.color,
              ),
              selectedColor: Colors.amber,
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
              onSelected: (_) => setState(() => _selectedCategory = cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ----------------------- SECTION TITLE -----------------------
  Widget _sectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// ------------------------- PROJECT LIST -----------------------
  Widget _projectList(
    List<Project> list,
    ProjectProvider prov,
    ThemeData theme,
    bool isDark,
  ) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          "No projects available",
          style: TextStyle(color: theme.hintColor),
        ),
      );
    }

    return Column(
      children: list.map((p) => _projectCard(p, prov, theme, isDark)).toList(),
    );
  }

  /// ------------------------ PROJECT CARD ------------------------
  Widget _projectCard(
    Project p,
    ProjectProvider prov,
    ThemeData theme,
    bool isDark,
  ) {
    final isMine = p.creatorId == prov.currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(isDark ? 0.4 : 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (isMine)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditProjectScreen(project: p),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => prov.deleteProject(p.id!),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 4),

          /// Category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.amber,
            ),
            child: Text(
              p.category,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// Description
          Text(
            p.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.hintColor),
          ),

          const SizedBox(height: 10),

          /// Join Button
          if (!isMine && p.isPublic == 1)
            ElevatedButton(
              onPressed: () => prov.joinProject(p.id!),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              child: const Text("Join Project"),
            ),
        ],
      ),
    );
  }

  /// ------------------------- FILTER LOGIC ------------------------
  bool _filterProject(Project p) {
    bool matchTitle = p.title.toLowerCase().contains(_query.toLowerCase());
    bool matchCategory =
        _selectedCategory == "All" ||
        p.category.toLowerCase() == _selectedCategory.toLowerCase();
    return matchTitle && matchCategory;
  }
}
