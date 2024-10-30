import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vicar_app/components/components.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('Es', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vicar App',
      theme: ThemeData(
        textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Arial')),
      ),
      home:
          const BottomMenu(), //Navigate to `lib/components/components.dart` at lines 387-465
    );
  }
}
