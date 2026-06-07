import 'package:flutter/material.dart';

import '../models/nutrition_model.dart';

// ── Palette rose-violet ───────────────────────────────────────────────────────
const Color _kViolet      = Color(0xFF7C3AED);
const Color _kVioletMid   = Color(0xFF9B5CF6);
const Color _kVioletLight = Color(0xFFEDE9FE);
const Color _kPink        = Color(0xFFEC4899);
const Color _kPinkLight   = Color(0xFFFCE7F3);
const Color _kPinkBorder  = Color(0xFFFBCFE8);
const Color _kPageBg      = Color(0xFFFDF8FF);
const Color _kTextPrimary = Color(0xFF1A0A2E);
const Color _kTextMuted   = Color(0xFF6B6880);
const Color _kTextHint    = Color(0xFF9590A8);

const _kGradientMain = LinearGradient(
  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const _kGradientSoft = LinearGradient(
  colors: [Color(0xFFF5F0FF), Color(0xFFFCE7F3)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class NutritionDetailPage extends StatelessWidget {
  final NutritionModel item;
  const NutritionDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          ),
        ),
        title: const Text(
          'Détails nutritionnels',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageHeader(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  // ── Image header ──────────────────────────────────────────────────────────

  Widget _buildImageHeader() {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(gradient: _kGradientMain),
              child: const Icon(Icons.restaurant_outlined, color: Colors.white54, size: 56),
            ),
          ),
          // Dark + gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.10),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Bottom rose-violet fade
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, _kPageBg],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Name card at bottom
          Positioned(
            left: 20, right: 20, bottom: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _GradientBadge('Semaine ${item.weekNumber}'),
                          const SizedBox(width: 8),
                          _OutlineBadge(item.categoryLabel),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBenefitCard(),
          const SizedBox(height: 18),
          _buildSectionLabel('Description détaillée'),
          const SizedBox(height: 10),
          _buildDescriptionCard(),
          const SizedBox(height: 18),
          _buildSectionLabel('Nutriments clés'),
          const SizedBox(height: 10),
          _buildNutrientChips(),
          const SizedBox(height: 18),
          _buildInfoCard(
            icon: Icons.scale_outlined,
            label: 'Quantité recommandée',
            value: item.recommendedQuantity,
            gradientColors: [const Color(0xFFEDE9FE), const Color(0xFFF5F0FF)],
            accentColor: _kViolet,
          ),
          const SizedBox(height: 14),
          _buildInfoCard(
            icon: Icons.tips_and_updates_outlined,
            label: 'Conseil de consommation',
            value: item.consumptionAdvice,
            gradientColors: [const Color(0xFFFCE7F3), const Color(0xFFFFF0F9)],
            accentColor: _kPink,
          ),
          const SizedBox(height: 18),
          _buildPrecautionsCard(),
        ],
      ),
    );
  }

  // ── Benefit card ──────────────────────────────────────────────────────────

  Widget _buildBenefitCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _kGradientMain,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: _kViolet.withOpacity(0.28), blurRadius: 24, offset: const Offset(0, 10)),
          BoxShadow(color: _kPink.withOpacity(0.15),   blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          // Orb
          Positioned(
            right: -16, top: -16,
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.09)),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BIENFAIT CLÉ',
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        letterSpacing: 0.9, color: Colors.white.withOpacity(0.68),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.shortBenefit,
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: Colors.white, height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Description card ──────────────────────────────────────────────────────

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE9FE), width: 1),
        boxShadow: [
          BoxShadow(color: _kViolet.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Text(
        item.detailedDescription,
        style: const TextStyle(
          color: _kTextMuted, height: 1.7, fontSize: 14,
        ),
      ),
    );
  }

  // ── Nutrient chips ────────────────────────────────────────────────────────

  Widget _buildNutrientChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(item.nutrientList.length, (i) {
        final isEven = i.isEven;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: isEven
                ? const LinearGradient(colors: [Color(0xFFEDE9FE), Color(0xFFF5F0FF)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : const LinearGradient(colors: [Color(0xFFFCE7F3), Color(0xFFFFF0F9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEven ? const Color(0xFFD8B4FE) : _kPinkBorder,
              width: 1,
            ),
          ),
          child: Text(
            item.nutrientList[i],
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isEven ? _kViolet : _kPink,
            ),
          ),
        );
      }),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradientColors,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.18), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: _kGradientMain,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: accentColor.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    letterSpacing: 0.7, color: accentColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14, color: _kTextPrimary, height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Precautions card ──────────────────────────────────────────────────────

  Widget _buildPrecautionsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPinkBorder, width: 1),
        boxShadow: [
          BoxShadow(color: _kPink.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: _kPink.withOpacity(0.28), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRÉCAUTIONS',
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    letterSpacing: 0.7, color: _kPink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.precautions,
                  style: const TextStyle(fontSize: 14, height: 1.6, color: _kTextPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String title) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (b) => _kGradientMain.createShader(b),
          child: Container(
            width: 3, height: 15,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: _kTextMuted, letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }
}

// ── Reusable badge widgets ────────────────────────────────────────────────────

class _GradientBadge extends StatelessWidget {
  final String text;
  const _GradientBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: _kGradientMain,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.30), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

class _OutlineBadge extends StatelessWidget {
  final String text;
  const _OutlineBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ShaderMask(
        shaderCallback: (b) => _kGradientMain.createShader(b),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}