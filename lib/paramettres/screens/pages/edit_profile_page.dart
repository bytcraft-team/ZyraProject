import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/paramettres/providers/user_provider.dart';
import '../../services/image_service.dart';
import 'package:zyra/auth/viewmodels/authentication_view_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();

  bool showPasswordSection = false;
  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. تحميل صورة البروفايل من SQLite
      context.read<UserProvider>().loadUserData();

      // 2. تعمير الحقول بمعلومات المستخدم
      final authViewModel = context.read<AuthenticationViewModel>();
      final user = authViewModel.user;
      if (user != null) {
        _emailController.text = user.email ?? '';
        String fullName = user.displayName ?? "";
        List<String> parts = fullName.split(' ');
        _prenomController.text = parts.isNotEmpty ? parts[0] : '';
        _nomController.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        setState(() {});
      }
    });
  }

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

  String getInitials(String nom) {
    if (nom.isEmpty) return "U";
    return nom[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFF0F8),
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFFE91E8C)]),
              ),
            ),
            title: const Text('Modifier le profil', style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: userProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: const Color(0xFFE91E8C).withOpacity(0.2),
                                  // استخدام avatarPath من الـ Provider مباشرة
                                  backgroundImage: (userProvider.avatarPath != null && userProvider.avatarPath!.isNotEmpty)
                                      ? FileImage(File(userProvider.avatarPath!))
                                      : null,
                                  child: (userProvider.avatarPath == null || userProvider.avatarPath!.isEmpty)
                                      ? Text(
                                          getInitials(_nomController.text),
                                          style: const TextStyle(fontSize: 40, color: Color(0xFFE91E8C), fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showImagePickerOptions(userProvider),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: Color(0xFFE91E8C), shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        _card([
                          _field(_nomController, 'Nom', Icons.person_outline),
                          _field(_prenomController, 'Prénom', Icons.person_outline),
                          _field(_emailController, 'E-mail', Icons.email_outlined),
                        ]),
                        // باقي الكود (Password Section و Button) يبقى كما هو...
                        const SizedBox(height: 20),
                        SwitchListTile(
                          title: const Text("Changer le mot de passe", style: TextStyle(fontWeight: FontWeight.bold)),
                          value: showPasswordSection,
                          activeColor: const Color(0xFFE91E8C),
                          onChanged: (v) => setState(() => showPasswordSection = v),
                        ),
                        if (showPasswordSection)
                          _card([
                            _passwordField(_oldPass, 'Ancien mot de passe', showOld, () => setState(() => showOld = !showOld)),
                            _passwordField(_newPass, 'Nouveau mot de passe', showNew, () => setState(() => showNew = !showNew)),
                            _passwordField(_confirmPass, 'Confirmer le mot de passe', showConfirm, () => setState(() => showConfirm = !showConfirm)),
                          ]),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () => _save(userProvider),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E8C), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: const Text('Enregistrer les modifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  // ... (نفس الدوال السابقة: _showImagePickerOptions, _card, _field, _passwordField, _save)
  
  Future<void> _showImagePickerOptions(UserProvider provider) async {
    showModalBottomSheet(context: context, builder: (context) => SafeArea(child: Wrap(children: [
      ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Prendre une photo'), onTap: () async { Navigator.pop(context); final path = await ImageService.takePhoto(); if (path != null) provider.setAvatar(path); }),
      ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choisir de la galerie'), onTap: () async { Navigator.pop(context); final path = await ImageService.pickImage(); if (path != null) provider.setAvatar(path); }),
      ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)), onTap: () async { Navigator.pop(context); await provider.deleteAvatar(); }),
    ])));
  }

  Widget _card(List<Widget> children) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF5E6F5))), child: Column(children: children));
  Widget _field(TextEditingController c, String label, IconData icon) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: TextFormField(controller: c, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: const Color(0xFFE91E8C), size: 20), border: InputBorder.none)));
  Widget _passwordField(TextEditingController c, String label, bool show, VoidCallback toggle) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: TextFormField(controller: c, obscureText: !show, decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFE91E8C), size: 20), border: InputBorder.none, suffixIcon: IconButton(icon: Icon(show ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: toggle))));
  
  Future<void> _save(UserProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    if (showPasswordSection && _oldPass.text.isNotEmpty && _newPass.text.isNotEmpty) {
      await provider.updatePassword(ancienMdp: _oldPass.text, nouveauMdp: _newPass.text);
    }
    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour avec succès !'))); Navigator.pop(context); }
  }
}