import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:nhac/repositories/favorito_repository.dart';
import 'package:nhac/services/auth_service.dart';

class FavoriteHeart extends StatefulWidget {
  final String produtoId;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const FavoriteHeart({
    super.key,
    required this.produtoId,
    this.size = 24.0,
    this.activeColor = Colors.orange,
    this.inactiveColor = Colors.grey,
  });

  @override
  State<FavoriteHeart> createState() => _FavoriteHeartState();
}

class _FavoriteHeartState extends State<FavoriteHeart> {
  final _favoritoRepository = FavoritoRepository();
  bool _isFavorito = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavorito();
  }

  Future<void> _checkFavorito() async {
    final auth = context.read<AuthService>();
    if (auth.usuarioId != null) {
      try {
        final favoritos = await _favoritoRepository.buscarFavoritos(auth.usuarioId!);
        if (mounted) {
          setState(() {
            _isFavorito = favoritos.any((f) => f.produtoId == widget.produtoId);
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorito() async {
    final auth = context.read<AuthService>();
    if (auth.usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para favoritar produtos.')),
      );
      return;
    }

    // Optimistic update
    setState(() {
      _isFavorito = !_isFavorito;
    });

    try {
      if (_isFavorito) {
        await _favoritoRepository.favoritarProduto(auth.usuarioId!, widget.produtoId);
      } else {
        await _favoritoRepository.desfavoritarProduto(auth.usuarioId!, widget.produtoId);
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isFavorito = !_isFavorito;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
      );
    }

    return GestureDetector(
      onTap: _toggleFavorito,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isFavorito ? Icons.star : Icons.star_border,
          color: _isFavorito ? widget.activeColor : widget.inactiveColor,
          size: widget.size,
        ),
      ),
    );
  }
}
