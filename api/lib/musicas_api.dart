import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'musica.dart';

/// Erro com mensagem já pronta para o usuário.
class ErroApi implements Exception {
  const ErroApi(this.mensagem);
  final String mensagem;
}

class MusicasApi {
  // Chave entra na execução
  static const _chave = String.fromEnvironment('YT_KEY');

  Future<List<Musica>> carregar() async {
    if (_chave.isEmpty) {
      throw const ErroApi(
        'Chave da API ausente. Rode com --dart-define=YT_KEY=sua_chave.',
      );
    }

    final url = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
      'part': 'snippet,statistics',
      'chart': 'mostPopular',
      'videoCategoryId': '10', // 10 = Música
      'regionCode': 'BR',
      'maxResults': '25',
      'key': _chave,
    });

    final http.Response resposta;
    try {
      resposta = await http.get(url).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const ErroApi('O servidor demorou demais. Tente de novo.');
    } on http.ClientException {
      throw const ErroApi('Sem conexão com a internet.');
    }

    if (resposta.statusCode == 400 || resposta.statusCode == 403) {
  String motivo = '';
  try {
    final erro = jsonDecode(resposta.body) as Map;
    motivo = (erro['error'] as Map?)?['message'] as String? ?? '';
  } catch (_) {}
  throw ErroApi('A API recusou o pedido (${resposta.statusCode}). $motivo');
}
    if (resposta.statusCode != 200) {
      throw ErroApi('O servidor respondeu ${resposta.statusCode}.');
    }

    final corpo = jsonDecode(resposta.body);
    final bruto = (corpo is Map ? corpo['items'] : null) as List<dynamic>? ?? [];

    return bruto
        .map((m) => Musica.fromMap((m as Map).cast<String, Object?>()))
        .toList();
  }
}