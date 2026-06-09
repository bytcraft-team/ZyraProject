import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zyra/paramettres/providers/appearance_provider.dart';

class AboutSettingsPage extends StatefulWidget {
  const AboutSettingsPage({super.key});

  @override
  State<AboutSettingsPage> createState() => _AboutSettingsPageState();
}

class _AboutSettingsPageState extends State<AboutSettingsPage> {
  String _version = 'v1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = 'v${info.version}';
          _buildNumber = info.buildNumber;
        });
      }
    } catch (e) {
      debugPrint("Error loading version: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppearanceProvider>();
    final primaryColor = provider.currentPrimaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F8),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9B59B6), Color(0xFFE91E8C)],
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'À propos',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
        children: [
          _buildSectionLabel('Application'),
          _buildAppLogoCard(primaryColor),
          const SizedBox(height: 16),
          _buildSectionLabel('Informations'),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildSectionLabel('Légal'),
          _buildLegalCard(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF9B59B6), letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildAppLogoCard(Color primaryColor) {
    return Container(
      // تأكدنا أن Margin زيرو (موجب)
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5E6F5)),
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFFE91E8C)]),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text('Z', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          const Expanded( // زدنا Expanded باش Column ما يخرجش على الحدود
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Zyra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D1B3D))),
                Text('Votre compagnon de cycle', style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5E6F5)),
      ),
      child: Column(
        children: [
          _infoRow('Version', _version),
          const Divider(height: 1, color: Color(0xFFF5E6F5)),
          _infoRow('Build', _buildNumber),
          const Divider(height: 1, color: Color(0xFFF5E6F5)),
          _infoRow('Framework', 'Flutter'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2D1B3D))),
        ],
      ),
    );
  }

  Widget _buildLegalCard() {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5E6F5)),
      ),
      child: Column(
        children: [
          _legalRow('Politique de confidentialité'),
          const Divider(height: 1, color: Color(0xFFF5E6F5)),
          _legalRow('Conditions d\'utilisation'),
        ],
      ),
    );
  }

  Widget _legalRow(String label) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF2D1B3D))),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFE91E8C)),
      onTap: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}