import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/l10n/app_localizations.dart';
import 'package:zyra/paramettres/providers/appearance_provider.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppearanceProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final primaryColor = provider.currentPrimaryColor;
    final dividerColor = theme.dividerColor;
    final cardColor = theme.cardColor;

    final List<Map<String, dynamic>> colorThemes = [
      {
        'name': 'Zyra Rose',
        'sub': 'Par défaut',
        'bg': const Color(0xFFFFE4F3),
        'dot': const Color(0xFFE91E8C),
        'text': const Color(0xFF72243E),
        'sub_c': const Color(0xFF993556),
      },
      {
        'name': 'Zyra Violet',
        'sub': 'Élégant',
        'bg': const Color(0xFFF3EEFF),
        'dot': const Color(0xFF9B59B6),
        'text': const Color(0xFF4B2B66),
        'sub_c': const Color(0xFF6C3E85),
      },
      {
        'name': 'Lavande',
        'sub': 'Relaxant',
        'bg': const Color(0xFFF7F3FF),
        'dot': const Color(0xFFB388EB),
        'text': const Color(0xFF4E3A68),
        'sub_c': const Color(0xFF73589A),
      },
      {
        'name': 'Pêche',
        'sub': 'Chaleureux',
        'bg': const Color(0xFFFFF0E8),
        'dot': const Color(0xFFFF8A65),
        'text': const Color(0xFF7A3E2A),
        'sub_c': const Color(0xFFA8553A),
      },
      {
        'name': 'Menthe',
        'sub': 'Santé',
        'bg': const Color(0xFFE8F8F2),
        'dot': const Color(0xFF26A69A),
        'text': const Color(0xFF0C5A52),
        'sub_c': const Color(0xFF15756B)
      },
      {
        'name': 'Night',
        'sub': 'Premium',
        'bg': const Color(0xFF2D1B3D),
        'dot': const Color(0xFF9B59B6),
        'text': Colors.white,
        'sub_c': const Color(0xFFD6C6E5),
      },
    ];

    final List<Map<String, String>> languages = [
      {'flag': '🇫🇷', 'name': 'Français'},
      {'flag': '🇬🇧', 'name': 'English'},
      {'flag': '🇲🇦', 'name': 'العربية'},
    ];

    final List<Map<String, String>> modes = [
      {'icon': '☀️', 'label': l10n.light},
      {'icon': '🌙', 'label': l10n.dark},
      {'icon': '⚙️', 'label': l10n.system},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.appearance,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 40),
        children: [
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '🎨',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appearance,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.customizeAppearance,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.colorTheme.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primaryColor.withOpacity(0.8), 
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.6,
            ),
            itemCount: colorThemes.length,
            itemBuilder: (context, i) {
              final t = colorThemes[i];
              final selected = provider.selectedColor == i;

              return GestureDetector(
                onTap: () {
                  provider.updateColor(i);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: t['bg'],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? primaryColor
                          : dividerColor.withOpacity(0.3), // 🚀 حدود غير المختار تصبح متناسقة ديناميكياً
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: t['dot'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        t['name'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: t['text'],
                        ),
                      ),
                      Text(
                        t['sub'],
                        style: TextStyle(
                          fontSize: 11,
                          color: t['sub_c'],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            l10n.displayMode.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primaryColor.withOpacity(0.8), // 🚀 يتبع اللون المختار
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(modes.length, (i) {
              final selected = provider.selectedMode == i;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    provider.updateMode(i);
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: i < modes.length - 1 ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? primaryColor.withOpacity(0.15)
                          : cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? primaryColor
                            : dividerColor.withOpacity(0.3), // 🚀 يتبع الثيم
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          modes[i]['icon']!,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          modes[i]['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: selected
                                ? primaryColor
                                : theme.textTheme.bodyMedium?.color,
                            fontWeight: selected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.appLanguage.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primaryColor.withOpacity(0.8),
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: dividerColor.withOpacity(0.3), 
              ),
            ),
            child: Column(
              children: List.generate(languages.length, (i) {
                final selected = provider.selectedLang == i;

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        provider.updateLanguage(i);
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        child: Row(
                          children: [
                            Text(
                              languages[i]['flag']!,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                languages[i]['name']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                            if (selected)
                              Icon(
                                Icons.check,
                                color: primaryColor,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (i < languages.length - 1)
                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        indent: 52,
                        color: dividerColor.withOpacity(0.3), // 🚀 خط فاصل متناسق
                      ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.appearanceUpdated,
                  ),
                  backgroundColor: primaryColor,
                ),
              );

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.save,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}