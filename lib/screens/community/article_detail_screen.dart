import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zyra/theme/zyra_colors.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;
  final Map<String, dynamic> data;
  const ArticleDetailScreen(
      {super.key, required this.articleId, required this.data});
  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _commentCtrl = TextEditingController();
  bool _liked = false;
  bool _bookmarked = false;
  bool _sendingComment = false;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _likes = widget.data['likes'] as int? ?? 0;
    final likedBy = List<String>.from(widget.data['likedBy'] ?? []);
    _liked = likedBy.contains(_auth.currentUser?.uid ?? '');
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
    final ref = _firestore.collection('articles').doc(widget.articleId);
    final likedBy = List<String>.from(widget.data['likedBy'] ?? []);
    if (_liked) {
      likedBy.add(uid);
    } else {
      likedBy.remove(uid);
    }
    await ref.update({'likedBy': likedBy, 'likes': likedBy.length});
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sendingComment = true);
    try {
      final user = _auth.currentUser;
      String userName = 'Utilisatrice';
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        userName = (doc.data()?['name'] as String?) ?? 'Utilisatrice';
      }
      await _firestore.collection('comments').add({
        'articleId': widget.articleId,
        'userId': user?.uid ?? '',
        'userName': userName,
        'content': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _commentCtrl.clear();
      FocusScope.of(context).unfocus();
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title'] as String? ?? '';
    final content = widget.data['content'] as String? ?? '';
    final author = widget.data['authorName'] as String? ?? '';
    final tag = widget.data['tag'] as String? ?? '';
    final readTime = widget.data['readTimeMinutes'] as int? ?? 5;
    final ts = widget.data['createdAt'] as Timestamp?;
    final dateStr = ts != null
        ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}'
        : '';
    final initial = author.isNotEmpty ? author[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: ZyraColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ─── Header ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    color: ZyraColors.background,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: ZyraColors.lightPink,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: ZyraColors.primary,
                                        size: 18),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _toggleLike,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: _liked
                                          ? ZyraColors.lightPink
                                          : ZyraColors.lightPink,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _liked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: ZyraColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _bookmarked = !_bookmarked),
                                  child: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: ZyraColors.lightPink,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _bookmarked
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_border_rounded,
                                      color: ZyraColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Tag pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: ZyraColors.lightPink,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(tag,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: ZyraColors.primary)),
                            ),
                            const SizedBox(height: 12),
                            // Title
                            Text(title,
                                style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: ZyraColors.darkText,
                                    height: 1.3)),
                            const SizedBox(height: 14),
                            // Author row
                            Row(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: ZyraColors.mainGradient),
                                  child: Center(
                                    child: Text(initial,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(author,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: ZyraColors.darkText)),
                                    Text('$dateStr  •  $readTime min de lecture',
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: ZyraColors.greyText)),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Icon(Icons.favorite_rounded,
                                        color: ZyraColors.primary
                                            .withOpacity(0.7),
                                        size: 14),
                                    const SizedBox(width: 4),
                                    Text('$_likes',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: ZyraColors.primary)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ─── Content ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(20),
                    decoration: ZyraColors.cardDecoration,
                    child: Text(content,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF555555),
                            height: 1.8)),
                  ),
                ),

                // ─── Comments ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: ZyraColors.lightPink,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.chat_bubble_outline_rounded,
                              color: ZyraColors.primary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('comments')
                              .where('articleId', isEqualTo: widget.articleId)
                              .snapshots(),
                          builder: (_, s) => Text(
                              'Commentaires (${s.data?.docs.length ?? 0})',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: ZyraColors.darkText)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('comments')
                      .where('articleId', isEqualTo: widget.articleId)
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (ctx, snap) {
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Center(
                            child: Text('Sois la première à commenter ! 💬',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: ZyraColors.greyText)),
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final cd = docs[i].data() as Map<String, dynamic>;
                            final cName = cd['userName'] as String? ?? 'Utilisatrice';
                            final cContent = cd['content'] as String? ?? '';
                            final cInitial = cName.isNotEmpty ? cName[0].toUpperCase() : 'U';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 34, height: 34,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: ZyraColors.mainGradient),
                                    child: Center(
                                      child: Text(cInitial,
                                          style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: ZyraColors.lightPink
                                            .withOpacity(0.5),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(cName,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: ZyraColors.darkText)),
                                          const SizedBox(height: 4),
                                          Text(cContent,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color:
                                                      const Color(0xFF555555),
                                                  height: 1.5)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: docs.length,
                        ),
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // ─── Comment Input ─────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Color(0x0F000000), blurRadius: 12)
              ],
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ZyraColors.background,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _commentCtrl,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: ZyraColors.darkText),
                      decoration: InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 13, color: ZyraColors.greyText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendingComment ? null : _sendComment,
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ZyraColors.mainGradient,
                    ),
                    child: _sendingComment
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}