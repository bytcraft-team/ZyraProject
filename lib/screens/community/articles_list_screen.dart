import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zyra/theme/zyra_colors.dart';
import 'package:zyra/screens/community/article_detail_screen.dart';
import 'package:zyra/screens/community/create_article_screen.dart';
import 'package:zyra/pregnancy1/view/shared_navigation.dart';
import 'package:zyra/widgets/bottom_nav_bar.dart';
import 'package:zyra/app_tab_notifier.dart';

class ArticlesListScreen extends StatefulWidget {
  final bool showCycleNav;
  const ArticlesListScreen({super.key, this.showCycleNav = false});
  @override
  State<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends State<ArticlesListScreen> {
  final _firestore = FirebaseFirestore.instance;
  String _selectedCat = 'Tout';

  static const _cats = [
    'Tout',
    'Cycle',
    'Grossesse',
    'Ramadan',
    'Bien-être',
    'Nutrition',
  ];

  static const _catColors = {
    'Cycle': ZyraColors.primary,
    'Grossesse': Color(0xFF2980B9),
    'Ramadan': Color(0xFF27AE60),
    'Bien-être': ZyraColors.purple,
    'Nutrition': Color(0xFFE67E22),
  };
  static const _catBgs = {
    'Cycle': ZyraColors.lightPink,
    'Grossesse': Color(0xFFEBF5FB),
    'Ramadan': Color(0xFFE8F8F5),
    'Bien-être': Color(0xFFF5EEF8),
    'Nutrition': Color(0xFFFEF9E7),
  };
  static const _catIcons = {
    'Cycle': Icons.favorite_outline_rounded,
    'Grossesse': Icons.child_friendly_outlined,
    'Ramadan': Icons.nightlight_round_outlined,
    'Bien-être': Icons.spa_outlined,
    'Nutrition': Icons.local_dining_outlined,
  };

  Query<Map<String, dynamic>> get _query {
    final col = _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true);
    if (_selectedCat == 'Tout') return col;
    return col.where('tag', isEqualTo: _selectedCat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyraColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          _buildFeatured(),
          _buildCategoryFilter(),
          _buildArticlesList(),
          _buildWriteBtn(),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
      bottomNavigationBar: widget.showCycleNav
          ? BottomNavBar(
              selectedIndex: 5,
              onTap: (i) {
                appTabNotifier.value = i;
                Navigator.popUntil(context, (r) => r.isFirst);
              },
            )
          : CustomBottomNavBar(
              currentIndex: 5,
              onTap: (i) {
                if (i != 5) navigateToPage(context, i);
              },
            ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: ZyraColors.background,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: ZyraColors.lightPink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.article_outlined,
                    color: ZyraColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Santé & Bien-être',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: ZyraColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Articles',
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
                      Icons.search_rounded,
                      color: ZyraColors.primary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatured() {
    return SliverToBoxAdapter(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('articles')
            .orderBy('likes', descending: true)
            .limit(1)
            .snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return _featuredPlaceholder();
          }
          final doc = snap.data!.docs.first;
          final d = doc.data() as Map<String, dynamic>;
          return _featuredCard(doc.id, d);
        },
      ),
    );
  }

  Widget _featuredPlaceholder() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ZyraColors.purple, ZyraColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: Text(
          'Sois la première à écrire un article ! ✍️',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _featuredCard(String id, Map<String, dynamic> d) {
    final title = d['title'] as String? ?? '';
    final author = d['authorName'] as String? ?? '';
    final readTime = d['readTimeMinutes'] as int? ?? 5;
    final likes = d['likes'] as int? ?? 0;
    final tag = d['tag'] as String? ?? '';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(articleId: id, data: d),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ZyraColors.purple, ZyraColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44E91E8C),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // decorative circles
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              right: 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '★  À la une',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      author,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    const Text(
                      '  •  ',
                      style: TextStyle(color: Colors.white54),
                    ),
                    Text(
                      '$readTime min',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    const Text(
                      '  •  ',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$likes',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          itemCount: _cats.length,
          itemBuilder: (ctx, i) {
            final cat = _cats[i];
            final active = _selectedCat == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [ZyraColors.purple, ZyraColors.primary],
                        )
                      : null,
                  color: active ? null : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: active
                      ? [
                          const BoxShadow(
                            color: Color(0x33E91E8C),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : [
                          const BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 4,
                          ),
                        ],
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : ZyraColors.greyText,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildArticlesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _query.limit(20).snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: ZyraColors.primary),
              ),
            ),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: ZyraColors.primary.withOpacity(0.25),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Aucun article dans cette catégorie',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ZyraColors.darkText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((ctx, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              return _ArticleCard(
                articleId: docs[i].id,
                data: d,
                catColors: _catColors,
                catBgs: _catBgs,
                catIcons: _catIcons,
              );
            }, childCount: docs.length),
          ),
        );
      },
    );
  }

  Widget _buildWriteBtn() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateArticleScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ZyraColors.purple, ZyraColors.primary],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44E91E8C),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Écrire un article',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Article Card ─────────────────────────────────────────────
class _ArticleCard extends StatelessWidget {
  final String articleId;
  final Map<String, dynamic> data;
  final Map<String, Color> catColors;
  final Map<String, Color> catBgs;
  final Map<String, IconData> catIcons;
  const _ArticleCard({
    required this.articleId,
    required this.data,
    required this.catColors,
    required this.catBgs,
    required this.catIcons,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? '';
    final author = data['authorName'] as String? ?? '';
    final readTime = data['readTimeMinutes'] as int? ?? 5;
    final likes = data['likes'] as int? ?? 0;
    final tag = data['tag'] as String? ?? '';
    final tagColor = catColors[tag] ?? ZyraColors.primary;
    final tagBg = catBgs[tag] ?? ZyraColors.lightPink;
    final tagIcon = catIcons[tag] ?? Icons.article_outlined;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(articleId: articleId, data: data),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: ZyraColors.cardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(tagIcon, color: tagColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: tagColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZyraColors.darkText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: ZyraColors.greyText,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$readTime min',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: ZyraColors.greyText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.favorite_border_rounded,
                          size: 12,
                          color: ZyraColors.greyText,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$likes',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: ZyraColors.greyText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          author,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: ZyraColors.greyText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: ZyraColors.greyText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Nav (shared) ──────────────────────────────────────
