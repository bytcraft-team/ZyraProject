import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zyra/theme/zyra_colors.dart';

class CreateArticleScreen extends StatefulWidget {
  const CreateArticleScreen({super.key});
  @override
  State<CreateArticleScreen> createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String _tag = 'Cycle';
  int _readTime = 5;
  bool _publishing = false;

  static const _tags = [
    ('Cycle', ZyraColors.primary, ZyraColors.lightPink),
    ('Grossesse', Color(0xFF2980B9), Color(0xFFEBF5FB)),
    ('Ramadan', Color(0xFF27AE60), Color(0xFFE8F8F5)),
    ('Bien-être', ZyraColors.purple, Color(0xFFF5EEF8)),
    ('Nutrition', Color(0xFFE67E22), Color(0xFFFEF9E7)),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      _snack('Remplis le titre et le contenu 📝');
      return;
    }
    setState(() => _publishing = true);
    try {
      final user = _auth.currentUser;
      String userName = 'Auteure';
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final d = doc.data() ?? {};
          final fn = (d['first_name'] as String? ?? '');
          final ln = (d['last_name'] as String? ?? '');
          userName = '$fn $ln'.trim();
          if (userName.isEmpty) userName = 'Auteure';
        }
      }
      await _firestore.collection('articles').add({
        'authorId': user?.uid ?? '',
        'authorName': userName,
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'tag': _tag,
        'readTimeMinutes': _readTime,
        'likes': 0,
        'likedBy': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        _snack('Article publié ! 🎉');
        Navigator.pop(context);
      }
    } catch (e) {
      _snack('Erreur lors de la publication');
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: ZyraColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyraColors.background,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Titre de l\'article'),
                  const SizedBox(height: 10),
                  _inputField(_titleCtrl,
                      'Ex: Comment gérer ses règles au travail...', 2),
                  const SizedBox(height: 20),
                  _sectionLabel('Contenu'),
                  const SizedBox(height: 10),
                  _inputField(_contentCtrl, 'Écris ton article ici...', 10),
                  const SizedBox(height: 20),
                  _sectionLabel('Catégorie'),
                  const SizedBox(height: 10),
                  _tagsWrap(),
                  const SizedBox(height: 20),
                  _sectionLabel('Temps de lecture estimé'),
                  const SizedBox(height: 10),
                  _readTimeRow(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      color: ZyraColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: ZyraColors.lightPink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: ZyraColors.primary, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Articles',
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: ZyraColors.primary,
                            fontWeight: FontWeight.w600)),
                    Text('Écrire un article',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: ZyraColors.darkText)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _publishing ? null : _publish,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: _publishing
                        ? null
                        : const LinearGradient(
                            colors: [ZyraColors.purple, ZyraColors.primary]),
                    color: _publishing ? ZyraColors.greyText : null,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: _publishing
                        ? []
                        : [const BoxShadow(
                            color: Color(0x44E91E8C),
                            blurRadius: 12,
                            offset: Offset(0, 4))],
                  ),
                  child: _publishing
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Publier',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
      TextEditingController ctrl, String hint, int maxLines) {
    return Container(
      decoration: ZyraColors.cardDecoration,
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        minLines: maxLines ~/ 2 + 1,
        style: GoogleFonts.poppins(
            fontSize: 14, color: ZyraColors.darkText, height: 1.6),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
              fontSize: 13, color: ZyraColors.greyText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(t,
      style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: ZyraColors.darkText));

  Widget _tagsWrap() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _tags.map((t) {
        final sel = _tag == t.$1;
        return GestureDetector(
          onTap: () => setState(() => _tag = t.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              gradient: sel
                  ? const LinearGradient(
                      colors: [ZyraColors.purple, ZyraColors.primary])
                  : null,
              color: sel ? null : t.$3,
              borderRadius: BorderRadius.circular(30),
              boxShadow: sel
                  ? [const BoxShadow(
                      color: Color(0x44E91E8C),
                      blurRadius: 10,
                      offset: Offset(0, 4))]
                  : [],
            ),
            child: Text(t.$1,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : t.$2)),
          ),
        );
      }).toList(),
    );
  }

  Widget _readTimeRow() {
    return Container(
      decoration: ZyraColors.cardDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded,
              color: ZyraColors.primary, size: 22),
          const SizedBox(width: 10),
          Text('$_readTime minutes',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ZyraColors.darkText)),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if (_readTime > 1) setState(() => _readTime--);
            },
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: ZyraColors.lightPink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.remove_rounded,
                  color: ZyraColors.primary, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _readTime++),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [ZyraColors.purple, ZyraColors.primary]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}