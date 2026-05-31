import 'package:flutter/material.dart';

/// Clé globale pour afficher des SnackBars sans dépendre d'un BuildContext
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
