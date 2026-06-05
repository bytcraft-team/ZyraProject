import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/notification_provider.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends State<NotificationSettingsPage> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<NotificationProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FB),

      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFC8698A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                _card(
                  child: SwitchListTile(
                    value: provider.settings.regles,
                    onChanged: provider.setRegles,
                    title: const Text("🩸 Règles"),
                    subtitle: const Text(
                      "Recevoir les rappels des règles",
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _card(
                  child: SwitchListTile(
                    value: provider.settings.fertile,
                    onChanged: provider.setFertile,
                    title: const Text("🌿 Fertilité"),
                    subtitle: const Text(
                      "Recevoir les rappels fertilité",
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _card(
                  child: SwitchListTile(
                    value: provider.settings.ovulation,
                    onChanged: provider.setOvulation,
                    title: const Text("🌸 Ovulation"),
                    subtitle: const Text(
                      "Recevoir les rappels ovulation",
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: provider.saveAll,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8698A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  child: const Text(
                    "Enregistrer",
                    style: TextStyle(fontSize: 15),
                  ),
                ),

                if (provider.isSaved) ...[
                  const SizedBox(height: 16),

                  const Center(
                    child: Text(
                      "✅ Préférences enregistrées",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF2D6E4),
        ),
      ),
      child: child,
    );
  }
}