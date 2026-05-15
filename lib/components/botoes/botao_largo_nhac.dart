import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BotaoLargoNhac extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed; 
  final bool carregando;
  final Widget? icone;
  final bool isSecundario;

  const BotaoLargoNhac({
    super.key,
    required this.texto,
    this.onPressed,
    this.carregando = false,
    this.icone,
    this.isSecundario = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color corPrimaria = const Color(0xFFFE645C);
    final Color corEscura = const Color(0xFF5D201C);
    final Color corTextoClaro = const Color(0xFFFEE3E1);

    return SizedBox(
      width: double.infinity,
      height: 49.0,
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecundario 
              ? Colors.transparent 
              : (onPressed == null ? const Color(0xFFC9BCBC) : corPrimaria),
          foregroundColor: isSecundario ? corEscura : corTextoClaro,
          elevation: 0,
          side: isSecundario 
              ? BorderSide(color: onPressed == null ? const Color(0xFFC9BCBC) : corEscura, width: 1) 
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          disabledBackgroundColor: isSecundario ? Colors.transparent : const Color(0xFFC9BCBC),
          disabledForegroundColor: isSecundario ? const Color(0xFFC9BCBC) : corTextoClaro,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return isSecundario ? Colors.transparent : const Color(0xFFC9BCBC);
            }
            return isSecundario ? Colors.transparent : corPrimaria;
          }),
        ),
        child: carregando
            ? Transform.scale(
                scale: 2.5,
                child: Lottie.asset(
                  'assets/animations/loading_nhac.json',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icone != null) ...[
                    icone!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    texto,
                    style: TextStyle(
                      color: isSecundario ? corEscura : corTextoClaro,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}