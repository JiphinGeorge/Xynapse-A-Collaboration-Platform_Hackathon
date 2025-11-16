import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/project_model.dart';
import '../models/user_model.dart';
import '../providers/project_provider.dart';
import 'package:xynapse/utils/fade_route.dart';
import 'profile_screen.dart';

class AddEditProjectScreen extends StatefulWidget {
  final Project? existingProject;

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

    if (isEdit) isPublic = widget.existingProject!.isPublic == 1;

    loadMembers();
  }

  Future<void> loadMembers() async {
    final prov = Provider.of<ProjectProvider>(context, listen: false);

    allUsers = prov.users.where((u) => u.id != prov.currentUserId).toList();

    if (isEdit && widget.existingProject!.id != null) {
      final existingMembers = await prov.getMembers(
        widget.existingProject!.id!,
      );

      selectedMemberIds = existingMembers.map((u) => u.id!).toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProjectProvider>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF0E3D72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: CustomScrollView(
          slivers: [
            // ---------------------- APPBAR ----------------------
            SliverAppBar(
              pinned: true,
              elevation: 0,
              expandedHeight: 45,

              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              title: Text(
                isEdit ? "Edit Project" : "Add Project",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),

              centerTitle: true,

              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        FadeRoute(page: const ProfileScreen()),
                      );
                    },
                    child: Consumer<ProjectProvider>(
                      builder: (_, prov, __) {
                        return Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              prov.currentUserInitial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: Container(
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),

            //  BODY
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel("Project Title"),
                      _inputField(titleC, "Enter project title"),
                      const SizedBox(height: 20),

                      _fieldLabel("Description"),
                      _inputField(descC, "Describe your project", maxLines: 5),
                      const SizedBox(height: 20),

                      _fieldLabel("Category"),
                      _inputField(categoryC, "e.g., Web, App, AI, UI/UX"),
                      const SizedBox(height: 20),

                      // ---------------- SWITCH ----------------
                      SwitchListTile(
                        thumbColor: WidgetStateProperty.all(Colors.blueAccent),
                        trackColor: WidgetStateProperty.all(Colors.white24),

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

                      _fieldLabel("Add Collaborators"),

                      _collaboratorList(),

                      const SizedBox(height: 30),

                      _submitButton(prov),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _collaboratorList() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      height: 210,

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
                final u = allUsers[index];
                final selected = selectedMemberIds.contains(u.id);

                return CheckboxListTile(
                  value: selected,
                  activeColor: Colors.blueAccent,
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,

                  title: Text(
                    u.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    u.email,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        selectedMemberIds.add(u.id!);
                      } else {
                        selectedMemberIds.remove(u.id);
                      }
                    });
                  },
                );
              },
            ),
    );
  }

  // ---------------------- BUTTON ----------------------
  Widget _submitButton(ProjectProvider prov) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2575FC),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isEdit ? "Update Project" : "Create Project",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),

        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          final newP = Project(
            id: isEdit ? widget.existingProject!.id : null,
            title: titleC.text.trim(),
            description: descC.text.trim(),

            //  FIXED creatorId
            creatorId: isEdit
                ? widget.existingProject!.creatorId
                : (prov.currentUserId ?? 0),

            category: categoryC.text.trim(),
            isPublic: isPublic ? 1 : 0,
            status: isEdit ? widget.existingProject!.status : "Active",
            createdAt: isEdit
                ? widget.existingProject!.createdAt
                : DateTime.now().toIso8601String(),
          );

          if (isEdit) {
            await prov.updateProject(newP, selectedMemberIds);
          } else {
            await prov.addProject(newP, selectedMemberIds);
          }

          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }

  // ---------------------- INPUT ----------------------
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
        fillColor: Colors.white.withValues(alpha: 0.05),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF76A9FF), width: 1.4),
        ),
      ),
    );
  }
}
