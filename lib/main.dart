import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:linux_image_editor/l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/image_editor_screen.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar a janela sem barra de título
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    // Define o ícone da janela
    await windowManager.setIcon('assets/icons/Icone2.png');
  });

  runApp(MyApp(initialFilePath: args.isNotEmpty ? args.first : null));
}

class MyApp extends StatelessWidget {
  final String? initialFilePath;

  const MyApp({super.key, this.initialFilePath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: ImageEditorScreen(initialFilePath: initialFilePath),
    );
  }
}
