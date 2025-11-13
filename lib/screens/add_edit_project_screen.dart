import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';

class AddEditProjectScreen extends StatefulWidget {
  final Project? project; // ← If null → Add mode, else Edit mode

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

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      // Load existing project data
      final p = widget.project!;
      titleCtrl.text = p.title;
      descCtrl.text = p.description;
      category = p.category;
      isPublic = p.isPublic == 1;

      // You can fetch collaborators if you want (optional)
      // We'll load collaborators via provider later
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProjectProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          isEdit ? "Edit Project" : "Create Project",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              _inputBox(
                controller: titleCtrl,
                label: "Project Title",
                hint: "Enter project name",
              ),

              const SizedBox(height: 15),

              _inputBox(
                controller: descCtrl,
                label: "Description",
                hint: "Describe your project...",
                maxLines: 4,
              ),

              const SizedBox(height: 15),

              _categoryDropdown(),

              const SizedBox(height: 20),
              _collaboratorSelector(prov),

              const SizedBox(height: 15),

              SwitchListTile(
                title: const Text(
                  "Public Project",
                  style: TextStyle(color: Colors.white),
                ),
                value: isPublic,
                activeColor: Colors.amber,
                onChanged: (v) => setState(() => isPublic = v),
              ),

              const SizedBox(height: 25),

              _saveButton(prov),

              if (isEdit) ...[const SizedBox(height: 15), _deleteButton(prov)],
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------ UI COMPONENTS ------------------------

  Widget _inputBox({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      validator: (v) =>
          (v == null || v.isEmpty) ? "This field is required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _categoryDropdown() {
    final categories = [
      "General",
      "Tech",
      "Design",
      "Social",
      "Event",
      "Research",
      "Others",
    ];

    return DropdownButtonFormField<String>(
      dropdownColor: const Color(0xFF1C1C1C),
      value: category,
      decoration: InputDecoration(
        labelText: "Category",
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: categories
          .map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(c, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => category = v!),
    );
  }

  Widget _collaboratorSelector(ProjectProvider prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Collaborators",
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: prov.users.map((u) {
            final selected = selectedUsers.contains(u.id);
            return FilterChip(
              selectedColor: Colors.amber,
              backgroundColor: Colors.white12,
              label: Text(u.name, style: const TextStyle(color: Colors.white)),
              selected: selected,
              onSelected: (s) {
                setState(() {
                  if (s) {
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

  Widget _saveButton(ProjectProvider prov) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () async {
        if (!_form.currentState!.validate()) return;

        if (!mounted) return;

        if (!isEdit) {
          // ------------------ CREATE NEW PROJECT ------------------
          final project = Project(
            title: titleCtrl.text.trim(),
            description: descCtrl.text.trim(),
            creatorId: prov.currentUserId,
            category: category,
            isPublic: isPublic ? 1 : 0,
            createdAt: DateTime.now().toIso8601String(),
          );

          await prov.addProject(project, selectedUsers);

          Navigator.pop(context);
        } else {
          // ------------------ UPDATE EXISTING ------------------
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

          await prov.deleteProject(old.id!);
          await prov.addProject(updated, selectedUsers);

          Navigator.pop(context);
        }
      },
      child: Text(
        isEdit ? "Update Project" : "Create Project",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _deleteButton(ProjectProvider prov) {
    return TextButton(
      onPressed: () async {
        final id = widget.project!.id!;
        await prov.deleteProject(id);
        if (mounted) Navigator.pop(context);
      },
      child: const Text(
        "Delete Project",
        style: TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
