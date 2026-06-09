import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:zyra/paramettres/providers/appearance_provider.dart';
import 'package:zyra/l10n/app_localizations.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _fingerprint = false;
  bool _pinCode = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppearanceProvider>(context);
    final primaryColor = provider.currentPrimaryColor;
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final dividerColor = theme.dividerColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sécurité',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 40),
              children: [
                // Hero
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🔒', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sécurité',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Protégez votre application',
                              style: TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section accès
                Text(
                  'ACCÈS À L\'APPLICATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primaryColor.withValues(alpha: 0.8),
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: dividerColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      _buildToggleTile(
                        emoji: '👆',
                        bg: const Color(0xFFEEF4FE),
                        title: 'Verrouillage par empreinte',
                        subtitle: 'Touch ID / Face ID',
                        value: _fingerprint,
                        primaryColor: primaryColor,
                        onChanged: (v) => setState(() => _fingerprint = v),
                      ),
                      Divider(height: 0.5, thickness: 0.5, indent: 52, color: dividerColor.withValues(alpha: 0.3)),
                      _buildToggleTile(
                        emoji: '🔢',
                        bg: const Color(0xFFFDEEF4),
                        title: 'Code PIN',
                        subtitle: 'Sécuriser l\'accès par un code',
                        value: _pinCode,
                        primaryColor: primaryColor,
                        onChanged: (v) => setState(() => _pinCode = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section actions
                Text(
                  'ACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primaryColor.withValues(alpha: 0.8),
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: dividerColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      _buildActionTile(
                        emoji: '📤',
                        bg: const Color(0xFFF0EEFE),
                        title: 'Exporter les données',
                        subtitle: 'Télécharger vos données en fichier',
                        primaryColor: primaryColor,
                        onTap: _exportData,
                      ),
                      Divider(height: 0.5, thickness: 0.5, indent: 52, color: dividerColor.withValues(alpha: 0.3)),
                      _buildActionTile(
                        emoji: '🗑️',
                        bg: const Color(0xFFFCEBEB),
                        title: 'Supprimer toutes les données',
                        subtitle: 'Action irréversible',
                        primaryColor: Colors.red,
                        onTap: () => _showDeleteDialog(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Sync active | DB: Local',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildToggleTile({
    required String emoji,
    required Color bg,
    required String title,
    required String subtitle,
    required bool value,
    required Color primaryColor,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Text(emoji),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      value: value,
      activeColor: primaryColor,
      onChanged: onChanged,
    );
  }

  Widget _buildActionTile({
    required String emoji,
    required Color bg,
    required String title,
    required String subtitle,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(emoji),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = snapshot.data().toString();
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/mes_donnees.txt');
        await file.writeAsString(data);
        await Share.shareXFiles([XFile(file.path)], text: 'Voici votre fichier de données');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer tout'),
        content: const Text('Action irréversible. Êtes-vous sûr ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () { Navigator.pop(context); _performDelete(); },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        await user.delete();
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}