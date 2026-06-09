import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zyra/theme/zyra_colors.dart';
import 'package:zyra/screens/community/create_post_screen.dart';
import 'package:zyra/pregnancy1/view/shared_navigation.dart';
import 'package:zyra/widgets/bottom_nav_bar.dart';
import 'package:zyra/app_tab_notifier.dart';

class PostsFeedScreen extends StatefulWidget {
  final bool showCycleNav;
  const PostsFeedScreen({super.key, this.showCycleNav = false});
  @override
  State<PostsFeedScreen> createState() => _PostsFeedScreenState();
}

class _PostsFeedScreenState extends State<PostsFeedScreen> {
  int _selectedTab = 0;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const _tabs = ['Tendances', 'Récents', 'Abonnements'];

  Query<Map<String, dynamic>> get _query {
    final col = _firestore.collection('posts');
    if (_selectedTab == 0) return col.orderBy('likes', descending: true);
    return col.orderBy('createdAt', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyraColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _SliverHeader(
                selectedTab: _selectedTab,
                onTabChanged: (i) => setState(() => _selectedTab = i),
              ),
              _SliverStories(firestore: _firestore),
              _SliverPosts(
                query: _query,
                currentUserId: _auth.currentUser?.uid ?? '',
                firestore: _firestore,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // FAB
          Positioned(
            bottom: 90,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ZyraColors.mainGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x55E91E8C),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showCycleNav
          ? BottomNavBar(
              selectedIndex: 4,
              onTap: (i) {
                // request MainShell to switch tab and return to it
                appTabNotifier.value = i;
                Navigator.popUntil(context, (r) => r.isFirst);
              },
            )
          : CustomBottomNavBar(
              currentIndex: 4,
              onTap: (i) {
                if (i != 4) navigateToPage(context, i);
              },
            ),
    );
  }
}

// ─── Sliver Header ───────────────────────────────────────────
class _SliverHeader extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  const _SliverHeader({required this.selectedTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(color: ZyraColors.background),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + title row like app screenshots
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ZyraColors.lightPink,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.people_alt_outlined,
                        color: ZyraColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Communauté',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: ZyraColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Fil d\'actualité',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: ZyraColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: ZyraColors.lightPink,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: ZyraColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Tabs like the app (rounded pill selector)
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E4F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: List.generate(3, (i) {
                      final active = selectedTab == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTabChanged(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: active
                                  ? [
                                      const BoxShadow(
                                        color: Color(0x18000000),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                ['Tendances', 'Récents', 'Abonnements'][i],
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: active
                                      ? ZyraColors.primary
                                      : ZyraColors.greyText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sliver Stories ──────────────────────────────────────────
class _SliverStories extends StatelessWidget {
  final FirebaseFirestore firestore;
  const _SliverStories({required this.firestore});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 96,
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('users').limit(8).snapshots(),
          builder: (ctx, snap) {
            final docs = snap.data?.docs ?? [];
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: docs.length + 1,
              itemBuilder: (ctx, i) {
                if (i == 0) return _myStory();
                final d = docs[i - 1].data() as Map<String, dynamic>;
                final fn = (d['first_name'] as String? ?? '');
                final ln = (d['last_name'] as String? ?? '');
                final name = '$fn $ln'.trim().isEmpty ? 'U' : '$fn $ln'.trim();
                final initial = name[0].toUpperCase();
                final firstName = name.split(' ').first;
                return _storyBubble(initial, firstName);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _myStory() {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: ZyraColors.lightPink,
                  shape: BoxShape.circle,
                  border: Border.all(color: ZyraColors.divider, width: 2),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: ZyraColors.primary,
                  size: 28,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: ZyraColors.mainGradient,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ma story',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: ZyraColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyBubble(String initial, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: ZyraColors.mainGradient,
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ZyraColors.background,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ZyraColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: ZyraColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sliver Posts ─────────────────────────────────────────────
class _SliverPosts extends StatelessWidget {
  final Query<Map<String, dynamic>> query;
  final String currentUserId;
  final FirebaseFirestore firestore;
  const _SliverPosts({
    required this.query,
    required this.currentUserId,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.limit(30).snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: CircularProgressIndicator(color: ZyraColors.primary),
              ),
            ),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return SliverToBoxAdapter(child: _empty());
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _PostCard(
                postId: docs[i].id,
                data: docs[i].data() as Map<String, dynamic>,
                currentUserId: currentUserId,
                firestore: firestore,
              ),
              childCount: docs.length,
            ),
          ),
        );
      },
    );
  }

  Widget _empty() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Column(
      children: [
        Icon(
          Icons.people_outline,
          size: 64,
          color: ZyraColors.primary.withOpacity(0.25),
        ),
        const SizedBox(height: 14),
        Text(
          'Aucun post pour l\'instant',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ZyraColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sois la première à partager !',
          style: GoogleFonts.poppins(fontSize: 13, color: ZyraColors.greyText),
        ),
      ],
    ),
  );
}

// ─── Post Card ────────────────────────────────────────────────
class _PostCard extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> data;
  final String currentUserId;
  final FirebaseFirestore firestore;
  const _PostCard({
    required this.postId,
    required this.data,
    required this.currentUserId,
    required this.firestore,
  });
  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    final likedBy = List<String>.from(widget.data['likedBy'] ?? []);
    _liked = likedBy.contains(widget.currentUserId);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    _ctrl.forward(from: 0);
    setState(() => _liked = !_liked);
    final ref = widget.firestore.collection('posts').doc(widget.postId);
    final likedBy = List<String>.from(widget.data['likedBy'] ?? []);
    if (_liked) {
      likedBy.add(widget.currentUserId);
    } else {
      likedBy.remove(widget.currentUserId);
    }
    await ref.update({'likedBy': likedBy, 'likes': likedBy.length});
  }

  static Color _tagColor(String? t) {
    switch (t) {
      case 'Ramadan':
        return const Color(0xFF27AE60);
      case 'Grossesse':
        return const Color(0xFF2980B9);
      case 'Bien-être':
        return ZyraColors.purple;
      case 'Nutrition':
        return const Color(0xFFE67E22);
      default:
        return ZyraColors.primary;
    }
  }

  static Color _tagBg(String? t) {
    switch (t) {
      case 'Ramadan':
        return const Color(0xFFE8F8F5);
      case 'Grossesse':
        return const Color(0xFFEBF5FB);
      case 'Bien-être':
        return const Color(0xFFF5EEF8);
      case 'Nutrition':
        return const Color(0xFFFEF9E7);
      default:
        return ZyraColors.lightPink;
    }
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return 'Il y a ${d.inMinutes} min';
    if (d.inHours < 24) return 'Il y a ${d.inHours}h';
    return 'Il y a ${d.inDays}j';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.data['userName'] as String? ?? 'Utilisatrice';
    final content = widget.data['content'] as String? ?? '';
    final tag = widget.data['tag'] as String?;
    final likes = widget.data['likes'] as int? ?? 0;
    final ts = widget.data['createdAt'] as Timestamp?;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: ZyraColors.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: ZyraColors.mainGradient,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ZyraColors.darkText,
                        ),
                      ),
                      Text(
                        _timeAgo(ts?.toDate()),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: ZyraColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _tagBg(tag),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _tagColor(tag),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF555555),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: ZyraColors.divider, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _scale,
                        builder: (_, __) => Transform.scale(
                          scale: _scale.value,
                          child: Icon(
                            _liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _liked
                                ? ZyraColors.primary
                                : ZyraColors.greyText,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$likes',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _liked
                              ? ZyraColors.primary
                              : ZyraColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('comments')
                      .where('postId', isEqualTo: widget.postId)
                      .snapshots(),
                  builder: (_, s) => Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: ZyraColors.greyText,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${s.data?.docs.length ?? 0}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ZyraColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.share_outlined,
                  color: ZyraColors.greyText,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────
