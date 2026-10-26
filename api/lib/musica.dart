/// Único lugar do projeto que conhece o vocabulário da API do YouTube.
class Musica {
  const Musica({
    required this.id,
    required this.titulo,
    required this.canal,
    required this.miniatura,
    required this.visualizacoes,
  });

  final String id;
  final String titulo;
  final String canal;
  final String? miniatura;
  final int visualizacoes;

  factory Musica.fromMap(Map<String, Object?> m) {
    final snippet = (m['snippet'] as Map?)?.cast<String, Object?>() ?? {};
    final stats = (m['statistics'] as Map?)?.cast<String, Object?>() ?? {};
    final thumbs = (snippet['thumbnails'] as Map?)?.cast<String, Object?>() ?? {};
    final media = (thumbs['medium'] as Map?)?.cast<String, Object?>();

    return Musica(
      id: m['id'] as String? ?? '',
      titulo: snippet['title'] as String? ?? '(sem título)',
      canal: snippet['channelTitle'] as String? ?? '(canal desconhecido)',
      miniatura: media?['url'] as String?,
      // A API manda viewCount como TEXTO, não como número.
      visualizacoes: int.tryParse('${stats['viewCount'] ?? ''}') ?? 0,
    );
  }
}