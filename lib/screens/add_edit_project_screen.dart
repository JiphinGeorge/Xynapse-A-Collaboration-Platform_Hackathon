import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';
import '../providers/theme_provider.dart';
import '../models/project_model.dart';

class AddEditProjectScreen extends StatefulWidget {
  final Project? project;

  const AddEditProjectScreen({super.key, this.project});

  @override
  State<AddEditProjectScreen> createState() => _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends State<AddEditProjectScreen> {
  final _form = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String category = "General";
  bool isPublic = true;
  List<int> selectedUsers = [];

  bool get isEdit => widget.project != null;
  bool _loaded = false; // ensures safe async load

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loadInitial();
      _loaded = true;
    }
  }

  Future<void> _loadInitial() async {
    if (!isEdit) return;

    final p = widget.project!;
    final prov = Provider.of<ProjectProvider>(context, listen: false);

    // Load project basic data
    titleCtrl.text = p.title;
    descCtrl.text = p.description;
    category = p.category;
    isPublic = p.isPublic == 1;

    setState(() {});

    // Load collaborators safely
    try {
      final members = await prov.getMembers(p.id!);
      selectedUsers = members.map((u) => u.id!).toList();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Failed to load collaborators: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProjectProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 🔥 Prevent crash: wait until users list is available
    if (prov.users.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Project" : "Create Project"),
        actions: [
          // Theme Toggle
          Consumer<ThemeProvider>(
            builder: (_, t, __) {
              return IconButton(
                icon: Icon(
                  t.isDark ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.amber,
                ),
                onPressed: t.toggleTheme,
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              _inputField(
                controller: titleCtrl,
                label: "Project Title",
                hint: "Enter project name",
                theme: theme,
              ),
              const SizedBox(height: 16),

              _inputField(
                controller: descCtrl,
                label: "Description",
                hint: "Describe the project...",
                maxLines: 4,
                theme: theme,
              ),
              const SizedBox(height: 20),

              _categoryDropdown(theme),
              const SizedBox(height: 20),

              _collaboratorSelector(prov, theme),
              const SizedBox(height: 20),

              SwitchListTile(
                title: Text("Public Project"),
                value: isPublic,
                activeColor: theme.colorScheme.primary,
                onChanged: (v) => setState(() => isPublic = v),
              ),

              const SizedBox(height: 30),

              _saveButton(prov, theme),

              if (isEdit)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _deleteButton(prov),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------ UI COMPONENTS ------------------------

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeData theme,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: theme.cardColor.withOpacity(0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _categoryDropdown(ThemeData theme) {
    const categories = [
      "General",
      "Tech",
      "Design",
      "Social",
      "Event",
      "Research",
      "Others",
    ];

    return DropdownButtonFormField<String>(
      initialValue: category,
      decoration: InputDecoration(
        labelText: "Category",
        filled: true,
        fillColor: theme.cardColor.withOpacity(0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) => setState(() => category = v!),
    );
  }

  Widget _collaboratorSelector(ProjectProvider prov, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Collaborators", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          children: prov.users.map((u) {
            final selected = selectedUsers.contains(u.id);
            return FilterChip(
              label: Text(u.name),
              selected: selected,
              selectedColor: Colors.amber,
              backgroundColor: theme.cardColor.withOpacity(0.3),
              onSelected: (v) {
                setState(() {
                  if (v) {
                    selectedUsers.add(u.id!);
                  } else {
                    selectedUsers.remove(u.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _saveButton(ProjectProvider prov, ThemeData theme) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () async {
        if (!_form.currentState!.validate()) return;

        if (!isEdit) {
          // CREATE
          final project = Project(
            title: titleCtrl.text.trim(),
            description: descCtrl.text.trim(),
            creatorId: prov.currentUserId,
            category: category,
            isPublic: isPublic ? 1 : 0,
            createdAt: DateTime.now().toIso8601String(),
          );
          await prov.addProject(project, selectedUsers);
        } else {
          // UPDATE
          final old = widget.project!;
          final updated = Project(
            id: old.id,
            title: titleCtrl.text.trim(),
            description: descCtrl.text.trim(),
            creatorId: old.creatorId,
            category: category,
            isPublic: isPublic ? 1 : 0,
            createdAt: old.createdAt,
          );
          await prov.updateProject(updated, selectedUsers);
        }

        if (mounted) Navigator.pop(context);
      },
      child: Text(isEdit ? "Update Project" : "Create Project"),
    );
  }

  Widget _deleteButton(ProjectProvider prov) {
    return TextButton(
      onPressed: () async {
        await prov.deleteProject(widget.project!.id!);
        if (mounted) Navigator.pop(context);
      },
      child: const Text(
        "Delete Project",
        style: TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
