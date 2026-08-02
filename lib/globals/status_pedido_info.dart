import 'package:flutter/material.dart';

/// Helper de exibição pro status do pedido. Os valores aqui (PENDENTE,
/// CONFIRMADO, EM_PREPARO, SAIU_PARA_ENTREGA, ENTREGUE, CANCELADO) são a
/// PROPOSTA de enum que o backend precisa adotar — ver contrato no final
/// da conversa. Se o backend usar outros nomes, só ajustar o 'switch'
/// aqui, nada mais no app depende disso.
class StatusPedidoInfo {
  final String label;
  final IconData icon;
  final Color cor;

  const StatusPedidoInfo({required this.label, required this.icon, required this.cor});

  static StatusPedidoInfo daString(String? status) {
    switch (status) {
      case 'PENDENTE':
        return const StatusPedidoInfo(
            label: 'Aguardando confirmação', icon: Icons.hourglass_empty, cor: Colors.orange);
      case 'CONFIRMADO':
        return const StatusPedidoInfo(
            label: 'Confirmado pela loja', icon: Icons.check_circle_outline, cor: Colors.blue);
      case 'EM_PREPARO':
        return const StatusPedidoInfo(
            label: 'Em preparo', icon: Icons.soup_kitchen_outlined, cor: Colors.blue);
      case 'SAIU_PARA_ENTREGA':
        return const StatusPedidoInfo(
            label: 'Saiu para entrega', icon: Icons.delivery_dining_outlined, cor: Color(0xFFFF6961));
      case 'ENTREGUE':
        return const StatusPedidoInfo(
            label: 'Entregue', icon: Icons.check_circle, cor: Colors.green);
      case 'CANCELADO':
        return const StatusPedidoInfo(
            label: 'Cancelado', icon: Icons.cancel_outlined, cor: Colors.red);
      default:
        return const StatusPedidoInfo(
            label: 'Status desconhecido', icon: Icons.help_outline, cor: Colors.grey);
    }
  }

  static const List<String> ordemFluxoNormal = [
    'PENDENTE',
    'CONFIRMADO',
    'EM_PREPARO',
    'SAIU_PARA_ENTREGA',
    'ENTREGUE',
  ];
}
