import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/image_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController(text: 'Sara');
  final _prenomController = TextEditingController(text: 'Saadi');
  final _emailController = TextEditingController(text: 'sara@example.com');

  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();

  bool showPasswordSection = false;
  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _oldPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFDF8FB),

          // ───────── APP BAR ─────────
          appBar: AppBar(
            backgroundColor: const Color(0xFFC8698A),
            title: const Text("Modifier profil"),
            actions: [
              TextButton(
                onPressed: userProvider.isLoading
                    ? null
                    : () => _save(userProvider),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),

          // ───────── BODY ─────────
          body: userProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        // ───── AVATAR ─────
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.pink.shade100,
                              child: Text(
                                "SA",
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () => _pickImage(userProvider),
                            )
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ───── ERROR ─────
                        if (userProvider.errorMessage != null)
                          Text(
                            userProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),

                        // ───── SUCCESS ─────
                        if (userProvider.passwordUpdated)
                          const Text(
                            "Password updated + verification email sent",
                            style: TextStyle(color: Colors.green),
                          ),

                        const SizedBox(height: 20),

                        // ───── NOM ─────
                        _field(_nomController, "Nom"),
                        _field(_prenomController, "Prénom"),
                        _field(_emailController, "Email"),

                        const SizedBox(height: 20),

                        // ───── PASSWORD SECTION ─────
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showPasswordSection = !showPasswordSection;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.pink),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text("Changer mot de passe"),
                          ),
                        ),

                        if (showPasswordSection) ...[
                          const SizedBox(height: 10),

                          _passwordField(_oldPass, "Ancien mot de passe", showOld, () {
                            setState(() => showOld = !showOld);
                          }),

                          _passwordField(_newPass, "Nouveau mot de passe", showNew, () {
                            setState(() => showNew = !showNew);
                          }),

                          _passwordField(_confirmPass, "Confirmer mot de passe", showConfirm, () {
                            setState(() => showConfirm = !showConfirm);
                          }),
                        ],

                        const SizedBox(height: 30),

                        // ───── SAVE BUTTON ─────
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC8698A),
                              padding: const EdgeInsets.all(14),
                            ),
                            onPressed: () => _save(userProvider),
                            child: const Text("Enregistrer"),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  // ───── TEXT FIELD ─────
  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ───── PASSWORD FIELD ─────
  Widget _passwordField(
    TextEditingController c,
    String label,
    bool show,
    VoidCallback toggle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        obscureText: !show,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: IconButton(
            icon: Icon(show ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }

  // ───── PICK IMAGE ─────
  Future<void> _pickImage(UserProvider provider) async {
    final path = await ImageService.pickImage();
    if (path != null) {
      provider.setAvatar(path);
    }
  }

  // ───── SAVE ─────
  Future<void> _save(UserProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    if (showPasswordSection &&
        _oldPass.text.isNotEmpty &&
        _newPass.text.isNotEmpty) {

      await provider.updatePassword(
        ancienMdp: _oldPass.text,
        nouveauMdp: _newPass.text,
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil mis à jour")),
    );

    Navigator.pop(context);
  }
}