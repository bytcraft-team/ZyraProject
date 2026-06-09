import 'package:flutter/material.dart';
import 'package:zyra/pregnancy1/view/shared_header.dart';

/// Places the pregnancy header fixed at the top and shows [child]
/// beneath it (content is shifted down to avoid overlap).
class StickyPregnancyHeader extends StatelessWidget {
  final String title;
  final Widget child;

  const StickyPregnancyHeader({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    // The PregnancyModuleHeader uses SafeArea + vertical padding (top:14, bottom:44)
    // Use the device top padding + that vertical size to compute a safe offset.
    final topInset = MediaQuery.of(context).padding.top;
    final headerVertical = 14.0 + 44.0; // matches PregnancyModuleHeader internal padding
    final headerHeight = topInset + headerVertical;

    return Stack(
      children: [
        // Fixed header
        Positioned(top: 0, left: 0, right: 0, child: PregnancyModuleHeader(title: title)),

        // Content shifted down under the header to remain visible while scrolling
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: headerHeight),
            child: child,
          ),
        ),
      ],
    );
  }
}
