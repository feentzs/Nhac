import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/models/pedido_model.dart';
import 'package:nhac/repositories/pedido_repository.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nhac/controllers/endereco_provider.dart';
import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/components/botoes/botao_largo_nhac.dart';
import 'package:nhac/services/auth_service.dart';
import 'package:nhac/models/usuario/cupom_model.dart';
import 'package:nhac/repositories/cupom_repository.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _formaPagamento = 'Dinheiro';
  final TextEditingController _trocoController = TextEditingController();

  bool _mostrarCampoTroco = true;
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  bool _isLoading = true;
  bool _isSubmitting = false;

  CupomModel? _cupomAplicado;
  final TextEditingController _cupomController = TextEditingController();
  bool _validandoCupom = false;
  final CupomRepository _cupomRepository = CupomRepository();

  @override
  void initState() {
    super.initState();
    _verificarNumeroEndereco();
  }

  Future<void> _verificarNumeroEndereco() async {
    await Future.delayed(Duration.zero); 
    if (!mounted) return;
    final enderecoProvider = context.read<EnderecoProvider>();
    final EnderecoModel? enderecoisPadrao = enderecoProvider.enderecos.isEmpty
        ? null
        : enderecoProvider.enderecos.firstWhere(
            (e) => e.isPadrao,
            orElse: () => EnderecoModel(
              id: '', 
              bairro: '',
              cep: '',
              cidade: '',
              estado: '',
              numero: '',
              rua: '',
            ),
          );
    if (enderecoisPadrao != null &&
        enderecoisPadrao.id.isNotEmpty &&
        enderecoisPadrao.numero.isEmpty) {
        
      await _pedirNumeroEndereco(enderecoisPadrao);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pedirNumeroEndereco(EnderecoModel endereco) async {
    final TextEditingController numeroController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.home, color: const Color(0xFFFF6961), size: 28.r),
            SizedBox(width: 12.w),
            Text(
              'Número da casa',
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D201C)),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Para completar seu endereço, informe o número da casa.',
                style:
                    TextStyle(fontSize: 14.sp, color: const Color(0xFF5D201C)),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: numeroController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Número (ex: 123, S/N)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
         ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final numero = numeroController.text.trim();
                  final enderecoAtualizado = endereco.copyWith(numero: numero);
                  
                  await context
                      .read<EnderecoProvider>()
                      .atualizarEndereco(enderecoAtualizado.id, enderecoAtualizado);
                      
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE645C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.r)),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _trocoController.dispose();
    _cupomController.dispose();
    super.dispose();
  }

  Future<void> _aplicarCupom(double subtotal) async {
    final codigo = _cupomController.text.trim();
    if (codigo.isEmpty) return;

    setState(() => _validandoCupom = true);
    try {
      final cupom = await _cupomRepository.validarCupom(codigo);
      if (subtotal < cupom.usoMinimo) {
        throw Exception('Valor mínimo para este cupom é R\$ ${cupom.usoMinimo.toStringAsFixed(2)}');
      }
      setState(() {
        _cupomAplicado = cupom;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cupom aplicado com sucesso!')),
        );
      }
    } catch (e) {
      setState(() => _cupomAplicado = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _validandoCupom = false);
    }
  }

  void _removerCupom() {
    setState(() {
      _cupomAplicado = null;
      _cupomController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final enderecoProvider = Provider.of<EnderecoProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFE7E5),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final EnderecoModel? enderecoisPadrao = enderecoProvider.enderecos.isEmpty
        ? null
        : enderecoProvider.enderecos.firstWhere(
            (e) => e.isPadrao,
            orElse: () => enderecoProvider.enderecos.first,
          );

    final subtotal = cartProvider.valorTotal;
    final frete = 5.0; // TODO(backend): usar loja.dadosOperacionais.taxaEntregaBase
    
    double descontoValue = 0.0;
    if (_cupomAplicado != null) {
      if (_cupomAplicado!.tipo == 'PERCENTUAL') {
        descontoValue = subtotal * (_cupomAplicado!.desconto / 100);
      } else {
        descontoValue = _cupomAplicado!.desconto;
      }
      if (descontoValue > subtotal) descontoValue = subtotal;
    }
    
    final total = subtotal + frete - descontoValue;
    final tempoEntrega = '30 - 50 min';
    final podeFinalizar =
        enderecoisPadrao != null && enderecoisPadrao.numero.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE7E5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: const Color(0xFF5D201C), size: 20.r),
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
                    child: Icon(Icons.location_on_outlined,
                        color: const Color(0xFFFF6961), size: 20.r),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enderecoisPadrao != null
                              ? '${enderecoisPadrao.rua}, ${enderecoisPadrao.numero}'
                              : 'Nenhum endereço selecionado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: const Color(0xFF5D201C),
                          ),
                        ),
                        if (enderecoisPadrao != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            '${enderecoisPadrao.bairro} - ${enderecoisPadrao.cidade}/${enderecoisPadrao.estado}',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12.sp),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selecionarEndereco(context),
                    child: Text(
                      'Alterar',
                      style: TextStyle(
                          color: const Color(0xFFFF6961),
                          fontWeight: FontWeight.w600),
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
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: const Color(0xFF5D201C)),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _trocoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Valor para troco (ex: 50,00)',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14.sp),
                        prefixIcon: Icon(Icons.money,
                            size: 20.r, color: Colors.grey.shade600),
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
            _buildSectionTitle('Cupom de desconto'),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: _cardDecoration(),
              child: _cupomAplicado != null
                  ? Row(
                      children: [
                        Icon(Icons.local_offer, color: const Color(0xFFFF6961), size: 24.r),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cupomAplicado!.titulo,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                              ),
                              Text(
                                _cupomAplicado!.codigo,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: _removerCupom,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cupomController,
                            decoration: InputDecoration(
                              hintText: 'Digite seu cupom',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        ElevatedButton(
                          onPressed: _validandoCupom ? null : () => _aplicarCupom(subtotal),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6961),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                          ),
                          child: _validandoCupom
                              ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Aplicar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
            ),
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
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14.sp),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                item.nome,
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              currencyFormat
                                  .format(item.preco * item.quantidade),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14.sp),
                            ),
                          ],
                        ),
                      )),
                  if (cartProvider.observacao.isNotEmpty) ...[
                    Divider(height: 24.h, color: Colors.grey.shade200),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note_outlined,
                            size: 18.r, color: Colors.grey.shade600),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Observações: ${cartProvider.observacao}',
                            style: TextStyle(
                                fontSize: 13.sp, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ],
                  Divider(height: 24.h, color: Colors.grey.shade200),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal',
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 14.sp)),
                      Text(currencyFormat.format(subtotal),
                          style: TextStyle(fontSize: 14.sp)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Frete',
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 14.sp)),
                      Text(
                        currencyFormat.format(frete),
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  if (descontoValue > 0) ...[
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Desconto',
                            style: TextStyle(
                                color: const Color(0xFFFF6961), fontSize: 14.sp)),
                        Text(
                          '- ${currencyFormat.format(descontoValue)}',
                          style: TextStyle(
                            color: const Color(0xFFFF6961),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: const Color(0xFF5D201C)),
                      ),
                      Text(
                        currencyFormat.format(total),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: const Color(0xFFFF6961)),
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
                  Icon(Icons.timer_outlined,
                      color: const Color(0xFFFF6961), size: 24.r),
                  SizedBox(width: 12.w),
                  Text(
                    tempoEntrega,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5D201C)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
            BotaoLargoNhac(
              texto: _isSubmitting ? 'Enviando pedido...' : 'Confirmar pedido',
              onPressed: (podeFinalizar && !_isSubmitting)
                  ? () => _confirmarPedido(context, total, cartProvider)
                  : null,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }


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
            Icon(icon,
                size: 24.r,
                color: isSelected
                    ? const Color(0xFFFF6961)
                    : Colors.grey.shade500),
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
              Icon(Icons.check_circle,
                  color: const Color(0xFFFF6961), size: 20.r),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarEndereco(BuildContext context) async {
    final enderecoProvider = context.read<EnderecoProvider>();
    final enderecos = enderecoProvider.enderecos;

    if (enderecos.isEmpty) {
      _mostrarDialogEnderecoVazio(context);
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddressSelectionSheet(enderecos: enderecos),
    );
    await enderecoProvider.buscarEnderecos();
    setState(() {});
  }

  void _mostrarDialogEnderecoVazio(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.location_off_outlined,
                color: const Color(0xFFFF6961), size: 28.r),
            SizedBox(width: 12.w),
            Text(
              'Sem endereço',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D201C),
              ),
            ),
          ],
        ),
        content: Text(
          'Você precisa adicionar um endereço de entrega antes de finalizar o pedido.',
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF5D201C)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                  color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
              context.push('/enderecos-salvos');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE645C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.r)),
            ),
            child: const Text('Adicionar endereço'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarPedido(
      BuildContext context, double total, CartProvider cartProvider) async {
    if (_isSubmitting) return; 
    setState(() => _isSubmitting = true);

    final enderecoProvider = context.read<EnderecoProvider>();
    final enderecoisPadrao = enderecoProvider.enderecos.firstWhere(
      (e) => e.isPadrao,
      orElse: () => enderecoProvider.enderecos.first,
    );

    final authService = context.read<AuthService>();
    final uid = authService.usuarioId;
    if (uid == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sessão expirada. Faça login novamente.'),
          backgroundColor: Colors.red,
        ),
      );
      context.go('/bem-vindo');
      return;
    }

    final trocoText = _trocoController.text.replaceAll(RegExp(r'[^0-9,]'), '').replaceAll(',', '.');
    final trocoPara = (_formaPagamento == 'Dinheiro' && trocoText.isNotEmpty) 
      ? double.tryParse(trocoText) 
      : null;

    final pedido = PedidoModel(
      usuarioId: uid,
      lojaId: cartProvider.lojaId,
      valorTotal: total,
      taxaFrete: 0, 
      formaPagamento: _formaPagamento,
      trocoPara: trocoPara,
      observacao: cartProvider.observacao,
      cupomId: _cupomAplicado?.id,
      enderecoEntrega: enderecoisPadrao,
      itens: cartProvider.itens.values.toList(),
    );

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6961))),
      );

      final respostaPedido = await PedidoRepository().finalizarPedido(pedido);
      final idGerado = respostaPedido['id'] ?? respostaPedido['pedidoId'] ?? 'ID Indisponível';
      final clientSecret = respostaPedido['clientSecret'];

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); 

      if (clientSecret != null && clientSecret.toString().isNotEmpty) {
        try {
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: clientSecret,
              merchantDisplayName: 'Nhac Delivery',
            ),
          );
          await Stripe.instance.presentPaymentSheet();
        } on StripeException {
          if (!context.mounted) return;
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pagamento cancelado ou falhou.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.white,
          title: Text(
            'Pedido confirmado!',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C)),
          ),
          content: Text(
            'O seu pedido foi recebido com sucesso!\n\nID do Pedido: $idGerado',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF5D201C)),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                cartProvider.esvaziarCarrinho();
                
                // Fecha o dialog primeiro
                Navigator.of(dialogContext).pop();
               
                if (context.mounted) {
                  // Volta para a raiz/home
                  context.go('/home-page');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE645C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
              ),
              child: const Text('Voltar ao Início', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

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
                borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selecione o endereço de entrega',
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D201C)),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5),
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
                    await context
                        .read<EnderecoProvider>()
                        .definirComoPadrao(endereco.id);
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
                             (endereco.complemento ?? '').toLowerCase().contains('trabalho')
                          ? Icons.work_outline
                          : Icons.home_outlined,
                      color: const Color(0xFFFF6961),
                      size: 20.r,
                    ),
                  ),
                  title: Text(
                    '${endereco.rua}, ${endereco.numero}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                  ),
                  subtitle: Text(
                    '${endereco.bairro}${(endereco.complemento?.isNotEmpty ?? false) ? ' - ${endereco.complemento}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  trailing: endereco.isPadrao
                      ? Icon(Icons.check_circle,
                          color: const Color(0xFFFF6961), size: 22.r)
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
              onTap: () => context.push('/enderecos-salvos'),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: Icon(Icons.add, color: Colors.grey, size: 20.r),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Adicionar novo endereço',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: Colors.grey),
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
