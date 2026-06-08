import 'package:flutter/material.dart';
import 'package:zyra/paramettres/services/gemini_service.dart';
import 'package:zyra/paramettres/services/ai_settings_storage.dart';
import 'package:zyra/config/env.dart';
import 'package:zyra/theme/zyra_colors.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> messages = [];

  late GeminiService gemini;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    gemini = GeminiService(Env.geminiApiKey);
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Défilement automatique vers le bas de la discussion
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Gestion de l'envoi du message
  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    print("Mon API Key utilisé est: ${Env.geminiApiKey}");
    setState(() {
      messages.add({"role": "user", "text": text});
      controller.clear();
      _isLoading = true;
    });
    
    _scrollToBottom();

    try {
      final config = await AiSettingsStorage.load();
      final response = await gemini.askGemini(
        message: text,
        config: config,
      );

      setState(() {
        messages.add({"role": "ai", "text": response});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "ai", "text": "⚠️ Une erreur est survenue. Veuillez réessayer."});
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 Application de la couleur de fond officielle de l'application ZYRA
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        title: const Text(
          "AI Assistant 🤖",
          style: TextStyle(color: ZyraColors.white, fontWeight: FontWeight.bold),
        ),
        // 🎨 Utilisation de la couleur primaire pour l'AppBar
        backgroundColor: ZyraColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: ZyraColors.white),
      ),
      body: Column(
        children: [
          // Historique des messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, i) {
                
                // Indicateur de chargement stylisé quand l'IA réfléchit
                if (i == messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ZyraColors.lightPink, // 🎨 Fond rose clair pour l'IA
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(ZyraColors.primary),
                        ),
                      ),
                    ),
                  );
                }

                final msg = messages[i];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    // 🎨 Application des styles Zyra (Bulle utilisateur avec dégradé ou couleur primaire)
                    decoration: BoxDecoration(
                      color: isUser ? ZyraColors.primary : ZyraColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      // Ajout d'une légère ombre pour les bulles de l'IA (comme vos cartes)
                      boxShadow: isUser ? [] : [
                        BoxShadow(
                          color: ZyraColors.primary.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                        // 🎨 Utilisation du texte sombre officiel de ZYRA pour l'IA
                        color: isUser ? ZyraColors.white : ZyraColors.darkText,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Zone d'écriture (Input Bar)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: ZyraColors.white,
              // Bordure haute subtile pour séparer le chat de l'input
              border: Border(top: BorderSide(color: ZyraColors.divider, width: 1)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !_isLoading,
                      style: const TextStyle(color: ZyraColors.darkText),
                      decoration: InputDecoration(
                        hintText: _isLoading ? "L'assistant réfléchit..." : "Posez votre question...",
                        hintStyle: const TextStyle(color: ZyraColors.greyText),
                        filled: true,
                        fillColor: ZyraColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        // Bordures arrondies et épurées
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bouton d'envoi rond et coloré
                  CircleAvatar(
                    backgroundColor: _isLoading ? ZyraColors.greyText : ZyraColors.primary,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: ZyraColors.white, size: 18),
                      onPressed: _isLoading ? null : sendMessage,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}