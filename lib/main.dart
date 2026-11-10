import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/language/bloc/language_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  // Langue enregistrée relue avant le premier affichage, pour que
  // l'app ne s'ouvre pas une fraction de seconde dans une autre langue.
  await di.sl<LanguageCubit>().load();
  runApp(const CartodexApp());
}
