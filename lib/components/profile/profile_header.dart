import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../models/usuario/usuario_model.dart';
import '../../controllers/user_provider.dart';

class ProfileHeader extends StatefulWidget {
  final UsuarioModel usuario;
  final String textoEndereco;

  const ProfileHeader({
    super.key,
    required this.usuario,
    required this.textoEndereco,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            GestureDetector(
              onLongPress: () =>
                  _mostrarPreviewFoto(context, widget.usuario.fotoUrl),
              onLongPressUp: () => Navigator.of(context).pop(),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  image: (widget.usuario.fotoUrl.isNotEmpty)
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                              widget.usuario.fotoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5D201C).withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isUploading
                    ? Center(
                        child: Lottie.asset(
                          'assets/animations/loading_nhac.json',
                          width: 40,
                          height: 40,
                        ),
                      )
                    : (widget.usuario.fotoUrl.isNotEmpty)
                        ? null
                        : Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploading
                    ? null
                    : () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 70,
                        );
                        if (pickedFile != null && mounted) {
                          setState(() => _isUploading = true);
                          try {
                            if (mounted) {
                              await context
                                  .read<UserProvider>()
                                  .atualizarFotoPerfil(File(pickedFile.path));
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Erro ao carregar imagem: $e')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isUploading = false);
                            }
                          }
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF5D201C),
                      shape: BoxShape.circle,
                    ),
                    child: _isUploading
                        ? SizedBox(
                            width: 12,
                            height: 12,
                            child: Lottie.asset(
                              'assets/animations/loading_nhac.json',
                            ),
                          )
                        : const Icon(Icons.edit, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.usuario.nome,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D201C),
                ),
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      widget.textoEndereco,
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _mostrarPreviewFoto(BuildContext context, String? fotoUrl) {
    showGeneralPage(
      context,
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: const Color(0xFF5D201C).withValues(alpha: 0.4),
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                  image: (fotoUrl != null && fotoUrl.isNotEmpty)
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(fotoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5D201C).withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: (fotoUrl == null || fotoUrl.isEmpty)
                    ? Icon(Icons.person, size: 160, color: Colors.grey.shade300)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showGeneralPage(BuildContext context, Widget child) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 110),
        reverseTransitionDuration: const Duration(milliseconds: 110),
        pageBuilder: (context, _, __) => child,
        transitionsBuilder: (context, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
