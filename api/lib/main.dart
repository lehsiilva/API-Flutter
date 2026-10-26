import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'musicas_api.dart';
import 'musicas_store.dart';
import 'tela_musicas.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Músicas em alta',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: ChangeNotifierProvider(
          create: (_) => MusicasStore(MusicasApi()),
          child: const TelaMusicas(),
        ),
      );
}