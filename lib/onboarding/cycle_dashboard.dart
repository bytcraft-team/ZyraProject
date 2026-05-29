import 'package:flutter/material.dart';

class CycleDashboardPage extends StatelessWidget {
  const CycleDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Period Tracking'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Your period tracker is ready',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We’ll keep your cycle predictions gentle, clear, and helpful. You can always update your cycle settings from the dashboard later.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_month, size: 40, color: Color(0xFF7FBFC0)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Next period and ovulation reminders will be personalized for you, with a calm and supportive experience.',
                        style: TextStyle(fontSize: 15, height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F4F2),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    size: 96,
                    color: Color(0xFF7FBFC0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
