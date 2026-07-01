import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Troca de e-mail com verificação não é suportada pelo backend atual
/// (o endpoint PATCH /usuarios/{id} ignora silenciosamente o campo "email",
/// e não existe fluxo de verificação). Tela mantida como placeholder até
/// que o backend ofereça esse recurso.
/// TODO(backend): implementar endpoint de troca de e-mail com verificação.
class EditarEmailPage extends StatelessWidget {
  const EditarEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar e-mail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'A troca de e-mail estará disponível em breve.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Color(0xFF5D201C)),
          ),
        ),
      ),
    );
  }
}
