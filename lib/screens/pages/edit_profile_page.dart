import 'package:flutter/material.dart';

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
  final _ancienMdpController = TextEditingController();
  final _nouveauMdpController = TextEditingController();
  final _confirmerMdpController = TextEditingController();

  bool _showAncienMdp = false;
  bool _showNouveauMdp = false;
  bool _showConfirmerMdp = false;
  bool _modifierMdp = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _ancienMdpController.dispose();
    _nouveauMdpController.dispose();
    _confirmerMdpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FB),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 20),
              _buildSectionLabel('Informations personnelles'),
              _buildInfoCard(),
              _buildSectionLabel('Adresse email'),
              _buildEmailCard(),
              _buildSectionLabel('Mot de passe'),
              _buildPasswordSection(),
              const SizedBox(height: 28),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFC8698A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Modifier le profil',
        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
      ),
      actions: [
        TextButton(
          onPressed: _saveProfile,
          child: const Text('Enregistrer',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
        ),
      ],
    );
  }

  // ─── Avatar ───────────────────────────────────────────────
  Widget _buildAvatarSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFC8698A),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 3),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'SA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _changerPhoto,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFC8698A), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.camera_alt,
                        size: 15, color: Color(0xFFC8698A)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Sara Saadi',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _changerPhoto,
            child: const Text(
              'Changer la photo',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Infos personnelles ───────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB06080),
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D6E4)),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nomController,
            label: 'Prénom',
            emoji: '👤',
            hint: 'Ton prénom',
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const Divider(height: 0.5, thickness: 0.5, indent: 56, color: Color(0xFFF5E0EC)),
          _buildTextField(
            controller: _prenomController,
            label: 'Nom',
            emoji: '👤',
            hint: 'Ton nom de famille',
            isLast: true,
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
        ],
      ),
    );
  }

  // ─── Email ────────────────────────────────────────────────
  Widget _buildEmailCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D6E4)),
      ),
      child: _buildTextField(
        controller: _emailController,
        label: 'Email',
        emoji: '📧',
        hint: 'ton@email.com',
        keyboardType: TextInputType.emailAddress,
        isLast: true,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Champ requis';
          if (!v.contains('@')) return 'Email invalide';
          return null;
        },
      ),
    );
  }

  // ─── Mot de passe ─────────────────────────────────────────
  Widget _buildPasswordSection() {
    return Column(
      children: [
        // Toggle pour afficher/cacher la section mot de passe
        GestureDetector(
          onTap: () => setState(() => _modifierMdp = !_modifierMdp),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF2D6E4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🔑', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Modifier le mot de passe',
                          style: TextStyle(fontSize: 14, color: Color(0xFF3A1A28))),
                      SizedBox(height: 2),
                      Text('Cliquez pour changer',
                          style: TextStyle(fontSize: 11, color: Color(0xFFB06080))),
                    ],
                  ),
                ),
                Icon(
                  _modifierMdp ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFFD4A0B8),
                  size: 22,
                ),
              ],
            ),
          ),
        ),

        // Champs mot de passe (visibles seulement si _modifierMdp == true)
        if (_modifierMdp) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF2D6E4)),
            ),
            child: Column(
              children: [
                _buildPasswordField(
                  controller: _ancienMdpController,
                  label: 'Ancien mot de passe',
                  show: _showAncienMdp,
                  onToggle: () => setState(() => _showAncienMdp = !_showAncienMdp),
                  validator: (v) {
                    if (_modifierMdp && (v == null || v.isEmpty)) return 'Champ requis';
                    return null;
                  },
                ),
                const Divider(height: 0.5, thickness: 0.5, indent: 56, color: Color(0xFFF5E0EC)),
                _buildPasswordField(
                  controller: _nouveauMdpController,
                  label: 'Nouveau mot de passe',
                  show: _showNouveauMdp,
                  onToggle: () => setState(() => _showNouveauMdp = !_showNouveauMdp),
                  validator: (v) {
                    if (_modifierMdp && (v == null || v.length < 6)) {
                      return 'Minimum 6 caractères';
                    }
                    return null;
                  },
                ),
                const Divider(height: 0.5, thickness: 0.5, indent: 56, color: Color(0xFFF5E0EC)),
                _buildPasswordField(
                  controller: _confirmerMdpController,
                  label: 'Confirmer le mot de passe',
                  show: _showConfirmerMdp,
                  onToggle: () => setState(() => _showConfirmerMdp = !_showConfirmerMdp),
                  isLast: true,
                  validator: (v) {
                    if (_modifierMdp && v != _nouveauMdpController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          // Indicateur de force du mot de passe
          const SizedBox(height: 8),
          _buildPasswordStrength(),
        ],
      ],
    );
  }

  Widget _buildPasswordStrength() {
    final mdp = _nouveauMdpController.text;
    int force = 0;
    if (mdp.length >= 6) force++;
    if (mdp.length >= 10) force++;
    if (mdp.contains(RegExp(r'[A-Z]'))) force++;
    if (mdp.contains(RegExp(r'[0-9]'))) force++;
    if (mdp.contains(RegExp(r'[!@#\$%^&*]'))) force++;

    final labels = ['', 'Faible', 'Moyen', 'Bien', 'Fort', 'Très fort'];
    final colors = [
      Colors.transparent,
      const Color(0xFFE53935),
      const Color(0xFFFB8C00),
      const Color(0xFFFDD835),
      const Color(0xFF43A047),
      const Color(0xFF1B5E20),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF2D6E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < force ? colors[force] : const Color(0xFFF2D6E4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          if (mdp.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              force > 0 ? 'Force : ${labels[force]}' : '',
              style: TextStyle(fontSize: 11, color: colors[force.clamp(1, 5)]),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Bouton enregistrer ───────────────────────────────────
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC8698A),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Text(
        'Enregistrer les modifications',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ─── Widgets utilitaires ──────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String emoji,
    required String hint,
    bool isLast = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(fontSize: 14, color: Color(0xFF3A1A28)),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(fontSize: 12, color: Color(0xFFB06080)),
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFD4A0B8)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool show,
    required VoidCallback onToggle,
    bool isLast = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: !show,
              validator: validator,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14, color: Color(0xFF3A1A28)),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(fontSize: 12, color: Color(0xFFB06080)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(
                    show ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFD4A0B8),
                    size: 18,
                  ),
                  onPressed: onToggle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Actions ──────────────────────────────────────────────
  void _changerPhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFF2D6E4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Changer la photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF3A1A28))),
            const SizedBox(height: 16),
            _bottomSheetOption(Icons.camera_alt, 'Prendre une photo', const Color(0xFFFDEEF4)),
            const SizedBox(height: 10),
            _bottomSheetOption(Icons.photo_library, 'Choisir depuis la galerie', const Color(0xFFF0EEFE)),
            const SizedBox(height: 10),
            _bottomSheetOption(Icons.delete_outline, 'Supprimer la photo', const Color(0xFFFCEBEB),
                textColor: const Color(0xFFA32D2D)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheetOption(IconData icon, String label, Color bg,
      {Color textColor = const Color(0xFF3A1A28)}) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, color: textColor)),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès !'),
          backgroundColor: Color(0xFFC8698A),
        ),
      );
      Navigator.pop(context);
    }
  }
}
