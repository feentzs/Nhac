import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nhac/controllers/user_provider.dart';
import 'package:provider/provider.dart';

import 'package:nhac/components/botoes/botao_largo_nhac.dart';

class EditarFotoPage extends StatefulWidget {
  const EditarFotoPage({super.key});

  @override
  State<EditarFotoPage> createState() => _EditarFotoPageState();
}

class _EditarFotoPageState extends State<EditarFotoPage> {
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePhoto() async {
    if (_image == null) return;

    setState(() => _isLoading = true);
    try {
      // 1. VALIDAÇÃO DE CONTEXTO (PRE-UPLOAD)
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      debugPrint("UID obtido para upload: $uid");

      if (uid == null || user == null) {
        throw Exception("Usuário não autenticado. UID is null.");
      }

      // FORÇAR REFRESH DO TOKEN para evitar erro -13040
      debugPrint("Forçando refresh do token ID...");
      await user.getIdToken(true);

      // 2. FORÇAR INSTÂNCIA DO STORAGE & 4. ESTRUTURA DO CAMINHO
      final storage = FirebaseStorage.instanceFor(app: Firebase.app());
      final ref = storage.ref().child('usuarios').child(uid).child('perfil.jpg');

      // Executa o upload
      await ref.putFile(
        _image!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      // Atualiza os dados no Firestore e notifica o Provider
      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      
      // Atualizamos diretamente via Firestore para garantir o sucesso da refatoração
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'foto_url': url,
      });

      // Recarrega os dados locais para atualizar a UI
      await userProvider.carregarDadosUsuario();

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil atualizada com sucesso!')),
      );

      context.pop();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      
      String mensagemErro = 'Erro ao atualizar foto';
      // 3. BLINDAGEM DE APPS E APP CHECK
      if (e.code == 'unauthenticated') {
        debugPrint("Falha de autenticação no Storage: Verifique se o App Check está a bloquear ou se o token de sessão expirou");
        mensagemErro = "Falha de autenticação no Storage: Verifique se o App Check está a bloquear ou se o token de sessão expirou";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErro)),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<UserProvider>().usuario;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE7E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF5D201C), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      const Text(
                        'Foto de Perfil',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D201C),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Escolha uma foto bem bonita para que todos possam te reconhecer.',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      Center(
                        child: GestureDetector(
                          onTap: _showPickerOptions,
                          child: Stack(
                            children: [
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF5D201C).withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _image != null
                                      ? Image.file(_image!, fit: BoxFit.cover)
                                      : (usuario!.fotoUrl.isNotEmpty == true
                                          ? CachedNetworkImage(
                                              imageUrl: usuario.fotoUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (ctx, url) => Container(
                                                color: Colors.grey.shade200,
                                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5D201C))),
                                              ),
                                              errorWidget: (ctx, url, err) => Container(
                                                color: Colors.grey.shade300,
                                                child: Icon(Icons.person, size: 80, color: Colors.grey.shade600),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.grey.shade300,
                                              child: Icon(Icons.person, size: 80, color: Colors.grey.shade600),
                                            )),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFE645C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      const Center(
                        child: Text(
                          'Toque para mudar a foto',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xFF5D201C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 32.0, top: 16.0),
              child: BotaoLargoNhac(
                texto: 'Salvar alterações',
                carregando: _isLoading,
                onPressed: (_image != null && !_isLoading) ? _savePhoto : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
