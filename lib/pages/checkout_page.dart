import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nhac/controllers/endereco_provider.dart';
import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/components/botoes/botao_largo_nhac.dart';
import 'package:nhac/globals/ui_utils.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _formaPagamento = 'Dinheiro';
  final TextEditingController _trocoController = TextEditingController();
  bool _mostrarCampoTroco = false;
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void dispose() {
    _trocoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final enderecoProvider = Provider.of<EnderecoProvider>(context);

    final EnderecoModel? enderecoPadrao = enderecoProvider.enderecos.isEmpty
        ? null
        : enderecoProvider.enderecos.firstWhere(
            (e) => e.padrao,
            orElse: () => enderecoProvider.enderecos.first,
          );

    final subtotal = cartProvider.valorTotal;
    final frete = 0.0;
    final total = subtotal + frete;

    final tempoEntrega = '30 - 50 min';

    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE7E5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: const Color(0xFF5D201C), size: 20.r),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Finalizar Pedido',
          style: TextStyle(
            color: const Color(0xFF5D201C),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Endereço de entrega'),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6961).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on_outlined, color: const Color(0xFFFF6961), size: 20.r),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enderecoPadrao != null
                              ? '${enderecoPadrao.rua}, ${enderecoPadrao.numero}'
                              : 'Nenhum endereço selecionado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: const Color(0xFF5D201C),
                          ),
                        ),
                        if (enderecoPadrao != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            '${enderecoPadrao.bairro} - ${enderecoPadrao.cidade}/${enderecoPadrao.estado}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selecionarEndereco(context),
                    child: Text(
                      'Alterar',
                      style: TextStyle(color: const Color(0xFFFF6961), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            _buildSectionTitle('Forma de pagamento'),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  _buildPaymentOption('Dinheiro', Icons.money),
                  _buildPaymentOption('Cartão de crédito', Icons.credit_card),
                  _buildPaymentOption('PIX', Icons.pix),
                ],
              ),
            ),

            if (_mostrarCampoTroco) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precisa de troco?',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: const Color(0xFF5D201C)),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _trocoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Valor para troco (ex: 50,00)',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                        prefixIcon: Icon(Icons.money, size: 20.r, color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 24.h),

            _buildSectionTitle('Resumo do pedido'),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  ...cartProvider.itens.values.map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      children: [
                        Text(
                          '${item.quantidade}x',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            item.nome,
                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          currencyFormat.format(item.preco * item.quantidade),
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  )),
                  Divider(height: 24.h, color: Colors.grey.shade200),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: TextStyle(color: Colors.grey.shade700, fontSize: 14.sp)),
                      Text(currencyFormat.format(subtotal), style: TextStyle(fontSize: 14.sp)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Frete', style: TextStyle(color: Colors.grey.shade700, fontSize: 14.sp)),
                      Text(
                        frete == 0 ? 'Grátis' : currencyFormat.format(frete),
                        style: TextStyle(
                          color: frete == 0 ? Colors.green : Colors.black87,
                          fontWeight: frete == 0 ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: const Color(0xFF5D201C)),
                      ),
                      Text(
                        currencyFormat.format(total),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: const Color(0xFFFF6961)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            _buildSectionTitle('Previsão de entrega'),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: const Color(0xFFFF6961), size: 24.r),
                  SizedBox(width: 12.w),
                  Text(
                    tempoEntrega,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF5D201C)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // ==================== BOTÃO FINALIZAR ====================
            BotaoLargoNhac(
              texto: 'Confirmar pedido',
              onPressed: () => _confirmarPedido(context, total),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  // -------------------- MÉTODOS AUXILIARES --------------------

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF5D201C),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10.r,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    final isSelected = _formaPagamento == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _formaPagamento = title;
          _mostrarCampoTroco = (title == 'Dinheiro');
          if (!_mostrarCampoTroco) _trocoController.clear();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 24.r, color: isSelected ? const Color(0xFFFF6961) : Colors.grey.shade500),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFFFF6961) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: const Color(0xFFFF6961), size: 20.r),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarEndereco(BuildContext context) async {
    final enderecoProvider = context.read<EnderecoProvider>();
    final enderecos = enderecoProvider.enderecos;

    if (enderecos.isEmpty) {
      context.showInfo('Adicione um endereço primeiro.');
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddressSelectionSheet(enderecos: enderecos),
    );
    await enderecoProvider.iniciarEscutaEnderecos();
    setState(() {});
  }

  void _confirmarPedido(BuildContext context, double total) {
    // Aqui você enviará o pedido para o Firebase, limpará o carrinho e navegará para a tela de sucesso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: const Text('Pedido confirmado!'),
        content: Text(
          'Seu pedido no valor de ${currencyFormat.format(total)} foi recebido.\n'
          'Acompanhe o status pelo app.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Limpar carrinho
              context.read<CartProvider>().esvaziarCarrinho();
              Navigator.pop(context); // fecha o dialog
              Navigator.pop(context); // volta para o carrinho ou home
              Navigator.pop(context); // se necessário, volta mais uma tela
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// -------------------- BOTTOM SHEET DE ENDEREÇOS (reutilizado) --------------------

class _AddressSelectionSheet extends StatelessWidget {
  final List<EnderecoModel> enderecos;
  const _AddressSelectionSheet({required this.enderecos});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.only(top: 16.h, bottom: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selecione o endereço de entrega',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C)),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: enderecos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final endereco = enderecos[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    await context.read<EnderecoProvider>().definirComoPadrao(endereco.idDocumento);
                    if (context.mounted) Navigator.pop(context);
                  },
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6961).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      endereco.bairro.toLowerCase().contains('trabalho') ||
                              endereco.complemento.toLowerCase().contains('trabalho')
                          ? Icons.work_outline
                          : Icons.home_outlined,
                      color: const Color(0xFFFF6961),
                      size: 20.r,
                    ),
                  ),
                  title: Text(
                    '${endereco.rua}, ${endereco.numero}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                  ),
                  subtitle: Text(
                    '${endereco.bairro}${endereco.complemento.isNotEmpty ? ' - ${endereco.complemento}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  trailing: endereco.padrao
                      ? Icon(Icons.check_circle, color: const Color(0xFFFF6961), size: 22.r)
                      : null,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: const Divider(height: 32),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/enderecos-salvos');
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: Icon(Icons.add, color: Colors.grey, size: 20.r),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Adicionar novo endereço',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}