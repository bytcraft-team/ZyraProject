import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyra/l10n/app_localizations.dart';
import 'package:zyra/providers/appearance_provider.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppearanceProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> colorThemes = [
      {
        'name': 'Rose doux',
        'sub': 'Par défaut',
        'bg': const Color(0xFFFDEEF4),
        'dot': const Color(0xFFC8698A),
        'text': const Color(0xFF72243E),
        'sub_c': const Color(0xFF993556),
      },
      {
        'name': 'Lavande',
        'sub': 'Violet doux',
        'bg': const Color(0xFFF0EEFE),
        'dot': const Color(0xFF7F77DD),
        'text': const Color(0xFF3C3489),
        'sub_c': const Color(0xFF534AB7),
      },
      {
        'name': 'Menthe',
        'sub': 'Vert frais',
        'bg': const Color(0xFFE1F5EE),
        'dot': const Color(0xFF1D9E75),
        'text': const Color(0xFF085041),
        'sub_c': const Color(0xFF0F6E56),
      },
      {
        'name': 'Pêche',
        'sub': 'Chaud & doux',
        'bg': const Color(0xFFFAECE7),
        'dot': const Color(0xFFD85A30),
        'text': const Color(0xFF712B13),
        'sub_c': const Color(0xFF993C1D),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: provider.currentPrimaryColor,
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
              color: provider.currentPrimaryColor,
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
          const SizedBox(height: 12),
          Text(
            l10n.colorTheme.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB06080),
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
                          ? provider.currentPrimaryColor
                          : const Color(0xFFF2D6E4),
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
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB06080),
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
                          ? provider.currentPrimaryColor.withOpacity(0.15)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? provider.currentPrimaryColor
                            : const Color(0xFFF2D6E4),
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
                                ? provider.currentPrimaryColor
                                : Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
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
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB06080),
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFF2D6E4),
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                              ),
                            ),
                            if (selected)
                              Icon(
                                Icons.check,
                                color: provider.currentPrimaryColor,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (i < languages.length - 1)
                      const Divider(
                        height: 0.5,
                        thickness: 0.5,
                        indent: 52,
                        color: Color(0xFFF5E0EC),
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
                  backgroundColor: provider.currentPrimaryColor,
                ),
              );

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: provider.currentPrimaryColor,
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
