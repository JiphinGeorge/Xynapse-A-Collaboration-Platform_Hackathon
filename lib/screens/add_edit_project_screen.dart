import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    if (!isEdit) return;

    final p = widget.project!;
    final prov = Provider.of<ProjectProvider>(context, listen: false);

    titleCtrl.text = p.title;
    descCtrl.text = p.description;
    category = p.category;
    isPublic = p.isPublic == 1;

    // Load collaborators
    selectedUsers = await prov
        .getMembers(p.id!)
        .then((list) => list.map((u) => u.id!).toList());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProjectProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEdit ? "Edit Project" : "Create Project",
          style: const TextStyle(color: Colors.white),
        ),
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

              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text(
                  "Public Project",
                  style: TextStyle(color: Colors.white),
                ),
                value: isPublic,
                activeThumbColor: Colors.amber,
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

  //---------------------- UI COMPONENTS ----------------------

  Widget _inputBox({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _categoryDropdown() {
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
      dropdownColor: const Color(0xFF1C1C1C),
      initialValue: category,
      decoration: InputDecoration(
        labelText: "Category",
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha:  0.07),
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
          style: TextStyle(color: Color.fromARGB(219, 255, 255, 255), fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: prov.users.map((u) {
            final selected = selectedUsers.contains(u.id);
            return FilterChip(
              selected: selected,
              selectedColor: Colors.amber,
              backgroundColor: Colors.white12,
              label: Text(u.name, style: const TextStyle(color: Colors.white)),
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

  Widget _saveButton(ProjectProvider prov) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () async {
        if (!_form.currentState!.validate()) return;

        if (!isEdit) {
          // ---- CREATE PROJECT ----
          final project = Project(
            title: titleCtrl.text,
            description: descCtrl.text,
            creatorId: prov.currentUserId,
            category: category,
            isPublic: isPublic ? 1 : 0,
            createdAt: DateTime.now().toIso8601String(),
          );

          await prov.addProject(project, selectedUsers);
        } else {
          // ---- UPDATE PROJECT ----
          final old = widget.project!;
          final updated = Project(
            id: old.id,
            title: titleCtrl.text,
            description: descCtrl.text,
            creatorId: old.creatorId,
            category: category,
            isPublic: isPublic ? 1 : 0,
            createdAt: old.createdAt,
          );

          await prov.updateProject(updated, selectedUsers);
        }

        if (mounted) Navigator.pop(context);
      },
      child: Text(
        isEdit ? "Update Project" : "Create Project",
        style: const TextStyle(color: Colors.white),
      ),
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
