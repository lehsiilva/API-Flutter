import 'package:flutter/foundation.dart';

import 'musica.dart';
import 'musicas_api.dart';

enum Estado { carregando, pronto, erro }

class MusicasStore extends ChangeNotifier {
  MusicasStore(this._repo) {
    carregar(); 
  }
  final MusicasApi _repo;

  List<Musica> _musicas = [];
  Estado estado = Estado.carregando;
  String? mensagemErro;

  List<Musica> get musicas => List.unmodifiable(_musicas);

  Future<void> carregar() async {
    estado = Estado.carregando;
    notifyListeners(); // a tela mostra o indicador
    try {
      _musicas = await _repo.carregar();
      estado = Estado.pronto;
    } on ErroApi catch (e) {
      estado = Estado.erro;
      mensagemErro = e.mensagem;
    } catch (_) {
      // JSON com formato inesperado, por exemplo.
      estado = Estado.erro;
      mensagemErro = 'A resposta veio em um formato inesperado.';
    }
    notifyListeners(); // a tela mostra o resultado
  }
}