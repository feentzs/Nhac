import 'package:flutter/material.dart';

class NhacMenuTile extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;

  const NhacMenuTile({
    super.key,
    required this.titulo,
    this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Color(0xFF5D201C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitulo != null) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    subtitulo!,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF5D201C),
            ),
          ],
        ),
      ),
    );
  }
}
