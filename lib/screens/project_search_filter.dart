import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final void Function(String) onCategoryChanged;
  final void Function(String) onSearchChanged;

  const ProjectSearchFilter({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔍 Search Bar
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search projects...",
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 🏷 Category Filter Chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildChip("All"),
              _buildChip("Web"),
              _buildChip("App"),
              _buildChip("AI"),
              _buildChip("UI/UX"),
              _buildChip("Social"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String category) {
    final bool isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.black : Colors.white,
            )),
        selected: isSelected,
        selectedColor: Colors.amber,
        backgroundColor: const Color(0xFF1A1A1A),
        onSelected: (_) => onCategoryChanged(category),
      ),
    );
  }
}
