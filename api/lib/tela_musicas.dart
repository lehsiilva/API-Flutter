import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'musica.dart';
import 'musicas_store.dart';

const _rosa = Color(0xFFFF2E88);
const _rosaEscuro = Color(0xFFB0125B);
const _rosaClaro = Color(0xFFFFD9E8);
const _fundo = Color(0xFFFFF3F8);
const _tinta = Color(0xFF2A0F1E);

class TelaMusicas extends StatelessWidget {
  const TelaMusicas({super.key});

  @override
  Widget build(BuildContext context) {
    final loja = context.watch<MusicasStore>();

    return Scaffold(
      backgroundColor: _fundo,
      body: switch (loja.estado) {
        Estado.carregando => const Center(
            child: CircularProgressIndicator(color: _rosa, strokeWidth: 5),
          ),
        Estado.erro => _TelaDeErro(
            mensagem: loja.mensagemErro!,
            aoTentarDeNovo: () => loja.carregar(),
          ),
        Estado.pronto => loja.musicas.isEmpty
            ? const _TelaVazia()
            : _Conteudo(itens: loja.musicas),
      },
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.itens});
  final List<Musica> itens;

  @override
  Widget build(BuildContext context) {
    final maior = itens.map((m) => m.visualizacoes).fold(1, (a, b) => a > b ? a : b);
    final demais = itens.skip(1).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          backgroundColor: _fundo,
          surfaceTintColor: Colors.transparent,
          foregroundColor: _tinta,
          title: const Text(
            'Em alta no Brasil',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: _Destaque(musica: itens.first),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList.separated(
            itemCount: demais.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _Faixa(posicao: i + 2, musica: demais[i], maior: maior),
          ),
        ),
      ],
    );
  }
}

/// O 1º lugar ganha o palco: é o elemento mais marcante da tela.
class _Destaque extends StatelessWidget {
  const _Destaque({required this.musica});
  final Musica musica;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: 16 / 11,
        child: Stack(
          fit: StackFit.expand,
          children: [
            musica.miniatura == null
                ? const _SemCapa()
                : Image.network(
                    musica.miniatura!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _SemCapa(),
                  ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE62A0F1E)],
                  stops: [0.35, 1],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _rosa,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  '1º lugar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    musica.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${musica.canal}  •  ${_formatar(musica.visualizacoes)} de views',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _rosaClaro, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Faixa extends StatelessWidget {
  const _Faixa({required this.posicao, required this.musica, required this.maior});
  final int posicao;
  final Musica musica;
  final int maior;

  @override
  Widget build(BuildContext context) {
    final fracao = (musica.visualizacoes / maior).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _rosa.withValues(alpha: .12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$posicao',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: posicao <= 3 ? _rosa : _rosaEscuro.withValues(alpha: .45),
              ),
            ),
          ),
          const SizedBox(width: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 84,
              height: 56,
              child: musica.miniatura == null
                  ? const _SemCapa()
                  : Image.network(
                      musica.miniatura!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _SemCapa(),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  musica.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _tinta,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${musica.canal}  •  ${_formatar(musica.visualizacoes)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: _tinta.withValues(alpha: .6),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: fracao,
                    minHeight: 5,
                    color: _rosa,
                    backgroundColor: _rosaClaro,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatar(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)} mi';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)} mil';
  return '$n';
}

class _SemCapa extends StatelessWidget {
  const _SemCapa();
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [_rosa, _rosaEscuro]),
        ),
        child: const Icon(Icons.music_note_rounded, color: Colors.white),
      );
}

class _TelaVazia extends StatelessWidget {
  const _TelaVazia();
  @override
  Widget build(BuildContext context) => const _Aviso(
        icone: Icons.queue_music_rounded,
        mensagem: 'O YouTube não listou nenhuma música em alta agora. '
            'Volte mais tarde.',
      );
}

class _TelaDeErro extends StatelessWidget {
  const _TelaDeErro({required this.mensagem, required this.aoTentarDeNovo});
  final String mensagem;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) => _Aviso(
        icone: Icons.wifi_off_rounded,
        mensagem: mensagem,
        acao: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _rosa,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: const StadiumBorder(),
          ),
          onPressed: aoTentarDeNovo,
          child: const Text(
            'Tentar de novo',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icone, required this.mensagem, this.acao});
  final IconData icone;
  final String mensagem;
  final Widget? acao;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    color: _rosaClaro,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icone, size: 40, color: _rosaEscuro),
                ),
                const SizedBox(height: 20),
                Text(
                  mensagem,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.4, color: _tinta),
                ),
                if (acao != null) ...[const SizedBox(height: 24), acao!],
              ],
            ),
          ),
        ),
      );
}