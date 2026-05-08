import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SetaVoltar extends StatelessWidget {
  const SetaVoltar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        } else {
          GoRouter.of(context).go('/home-page');
        }
      },
        child: const SizedBox(
          width: 21.0,
          height: 21.0,
          child: Icon(Icons.arrow_back_ios_new, color: Color(0xFF5D201C), size: 20),
        ),
      
    );
  }
}