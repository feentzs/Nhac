import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/controllers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:nhac/components/nhac_menu_tile.dart';

class DadosPessoaisPage extends StatelessWidget {
  final bool? isGoogleUserOverride;

  const DadosPessoaisPage({super.key, this.isGoogleUserOverride});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final usuario = userProvider.usuario;

    if (usuario == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFE7E5),
        body: Center(
          child: Lottie.asset(
            'assets/animations/botao_loading_nhac.json',
            width: 150,
            height: 150,
          ),
        ),
      );
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final isGoogleUser = currentUser?.providerData.any((info) => info.providerId == 'google.com') ?? false;
    final hasPassword = currentUser?.providerData.any((info) => info.providerId == 'password') ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE7E5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF5D201C), size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Dados Pessoais',
          style: TextStyle(
            color: Color(0xFF5D201C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 16.0),
            NhacMenuTile(
              titulo: 'Foto de Perfil',
              subtitulo: usuario.fotoUrl.isNotEmpty ? 'Alterar foto' : 'Adicionar foto',
              onTap: () => context.push('/editar-foto'),
            ),
            NhacMenuTile(
              titulo: 'Nome', 
              subtitulo: usuario.nome, 
              onTap: () => context.push('/editar-nome-preferencia')
            ),
            NhacMenuTile(
              titulo: 'E-mail',
              subtitulo: usuario.email.isEmpty ? 'Toque para adicionar' : usuario.email,
              onTap: isGoogleUser ? () {} : () => context.push('/editar-email'),
            ),
            NhacMenuTile(
              titulo: 'Telefone', 
              subtitulo: usuario.telefone, 
              onTap: () {},
            ),
            NhacMenuTile(
              titulo: 'Senha', 
              subtitulo: hasPassword ? '**************' : 'Não cadastrada', 
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
