import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../providers/project_provider.dart';

class AddEditProjectScreen extends StatefulWidget {
  final Project? existingProject; // null → add mode

  const AddEditProjectScreen({super.key, this.existingProject});

  @override
  State<AddEditProjectScreen> createState() => _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends State<AddEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleC;
  late TextEditingController descC;
  late TextEditingController categoryC;

  bool isPublic = true;
  bool isEdit = false;

  // ⭐ NEW: Member Selection Data
  List<AppUser> allUsers = [];
  List<int> selectedMemberIds = [];

  @override
  void initState() {
    super.initState();

    isEdit = widget.existingProject != null;

    titleC = TextEditingController(
      text: isEdit ? widget.existingProject!.title : "",
    );
    descC = TextEditingController(
      text: isEdit ? widget.existingProject!.description : "",
    );
    categoryC = TextEditingController(
      text: isEdit ? widget.existingProject!.category : "",
    );

    if (isEdit) {
      isPublic = widget.existingProject!.isPublic == 1;
    }

    loadMembers();
  }

  // ⭐ NEW: Load all users except the creator
  Future<void> loadMembers() async {
    final prov = Provider.of<ProjectProvider>(context, listen: false);

    // All users except current user
    allUsers = prov.users.where((u) => u.id != prov.currentUserId).toList();

    // ⭐ If editing, load existing collaborators
    if (isEdit && widget.existingProject!.id != null) {
      final existingMembers = await prov.getMembers(
        widget.existingProject!.id!,
      );

      selectedMemberIds = existingMembers
          .map((u) => u.id!)
          .toList(); // pre-select them
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProjectProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          isEdit ? "Edit Project" : "Add Project",
          style: GoogleFonts.poppins(),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              // Title
              _fieldLabel("Project Title"),
              _inputField(titleC, "Enter project title"),

              const SizedBox(height: 20),

              // Description
              _fieldLabel("Description"),
              _inputField(descC, "Describe your project", maxLines: 5),

              const SizedBox(height: 20),

              // Category
              _fieldLabel("Category"),
              _inputField(categoryC, "e.g., Web, App, AI, UI/UX"),

              const SizedBox(height: 20),

              // PUBLIC / PRIVATE SWITCH
              SwitchListTile(
                thumbColor: WidgetStateProperty.all(Colors.blueAccent),
                trackColor: WidgetStateProperty.all(Colors.white24),

                activeThumbColor: Colors.blueAccent,
                activeTrackColor: Colors.blueAccent.withValues(alpha:  0.35),

                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.white12,

                title: const Text(
                  "Make Public",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  "Allow others to discover this project",
                  style: TextStyle(color: Colors.white70),
                ),

                value: isPublic,
                onChanged: (v) => setState(() => isPublic = v),
              ),

              const SizedBox(height: 30),

              // ⭐ NEW: MEMBER SELECTION UI
              _fieldLabel("Add Collaborators"),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 200,
                child: allUsers.isEmpty
                    ? const Center(
                        child: Text(
                          "No other users available.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: allUsers.length,
                        itemBuilder: (context, index) {
                          final user = allUsers[index];
                          final isSelected = selectedMemberIds.contains(
                            user.id,
                          );

                          return CheckboxListTile(
                            value: isSelected,
                            activeColor: Colors.blueAccent,
                            title: Text(
                              user.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              user.email,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  selectedMemberIds.add(user.id!);
                                } else {
                                  selectedMemberIds.remove(user.id);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(isEdit ? "Update Project" : "Create Project"),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final newProject = Project(
                    id: isEdit ? widget.existingProject!.id : null,
                    title: titleC.text.trim(),
                    description: descC.text.trim(),
                    creatorId: prov.currentUserId,
                    category: categoryC.text.trim(),
                    isPublic: isPublic ? 1 : 0,
                    status: isEdit ? widget.existingProject!.status : "Active",
                    createdAt: isEdit
                        ? widget.existingProject!.createdAt
                        : DateTime.now().toIso8601String(),
                  );

                  if (isEdit) {
                    await prov.updateProject(newProject, selectedMemberIds);
                  } else {
                    await prov.addProject(newProject, selectedMemberIds);
                  }

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Field Label Widget
  // ------------------------------------------------------------
  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ------------------------------------------------------------
  // Reusable Input Field
  // ------------------------------------------------------------
  Widget _inputField(TextEditingController c, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: (v) => v!.isEmpty ? "Field cannot be empty" : null,

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
