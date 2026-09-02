import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nhac/models/pedido_model.dart';
import 'package:nhac/models/loja/lojas.dart';
import 'package:nhac/repositories/pedido_repository.dart';
import 'package:nhac/repositories/loja_repository.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RastreioPedidoPage extends StatefulWidget {
  final String pedidoId;

  const RastreioPedidoPage({
    super.key,
    required this.pedidoId,
  });

  @override
  State<RastreioPedidoPage> createState() => _RastreioPedidoPageState();
}

class _RastreioPedidoPageState extends State<RastreioPedidoPage> {
  PedidoModel? _pedido;
  LojasModel? _loja;
  bool _isLoading = true;
  String _erro = '';
  
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  GoogleMapController? _mapController;

  // Localizações fixas (mock) para o mapa se não tivermos a localização real.
  // Em produção, isso viria da geocodificação do endereço do cliente e do restaurante.
  final LatLng _lojaLocation = const LatLng(-23.550520, -46.633308); 
  final LatLng _clienteLocation = const LatLng(-23.558520, -46.640308); 

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final pedidoRepo = PedidoRepository();
      final lojaRepo = LojaRepository();

      final pedido = await pedidoRepo.buscarPedidoPorId(widget.pedidoId);
      final loja = await lojaRepo.buscarLoja(pedido.lojaId);

      if (mounted) {
        setState(() {
          _pedido = pedido;
          _loja = loja;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Erro ao carregar dados do pedido: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _ligarParaRestaurante(String? telefone) async {
    if (telefone == null || telefone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefone indisponível para este restaurante.')),
      );
      return;
    }
    
    final uri = Uri.parse('tel:$telefone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível realizar a chamada.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_erro.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_erro, textAlign: TextAlign.center),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _carregarDados,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pedido == null || _loja == null) {
      return const Scaffold(
        body: Center(child: Text('Pedido não encontrado.')),
      );
    }

    // Calcula tempo de preparo estimado
    final dataPedido = _pedido!.criadoEm != null ? DateTime.tryParse(_pedido!.criadoEm!) : DateTime.now();
    final previsao = dataPedido != null ? dataPedido.add(Duration(minutes: _loja!.dadosOperacionais?.tempoEntregaMax ?? 45)) : DateTime.now();
    final horaPrevisao = DateFormat('HH:mm').format(previsao);
    
    int quantidadeItens = _pedido!.itens.fold(0, (sum, item) => sum + item.quantidade);

    return Scaffold(
      body: Stack(
        children: [
          // Mapa
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _lojaLocation,
              zoom: 14.5,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              // Centraliza mapa para mostrar os dois pontos
              Future.delayed(const Duration(milliseconds: 500), () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest: LatLng(
                        _lojaLocation.latitude < _clienteLocation.latitude ? _lojaLocation.latitude : _clienteLocation.latitude,
                        _lojaLocation.longitude < _clienteLocation.longitude ? _lojaLocation.longitude : _clienteLocation.longitude,
                      ),
                      northeast: LatLng(
                        _lojaLocation.latitude > _clienteLocation.latitude ? _lojaLocation.latitude : _clienteLocation.latitude,
                        _lojaLocation.longitude > _clienteLocation.longitude ? _lojaLocation.longitude : _clienteLocation.longitude,
                      ),
                    ),
                    50.0, // padding
                  ),
                );
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('loja'),
                position: _lojaLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                infoWindow: InfoWindow(title: _loja!.nome),
              ),
              Marker(
                markerId: const MarkerId('cliente'),
                position: _clienteLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: const InfoWindow(title: 'Você'),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId('rota'),
                points: [_lojaLocation, _clienteLocation],
                color: Colors.red.withOpacity(0.5),
                width: 4,
                patterns: [PatternItem.dash(20), PatternItem.gap(10)],
              ),
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          
          // Botão de voltar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.h,
            left: 16.w,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: Colors.black),
              ),
            ),
          ),

          // Informação de distância (mockada por enquanto) no topo
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.h,
            left: 70.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.turn_left, color: Colors.red, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        '1.5 Km', // Valor mockado. Substituir pelo cálculo real no futuro.
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_pedido!.enderecoEntrega.rua}, ${_pedido!.enderecoEntrega.numero}',
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Painel Inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Previsão até $horaPrevisao',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$quantidadeItens Itens • ${_loja!.dadosOperacionais?.tempoEntregaMax ?? 45} Min total',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(_pedido!.valorTotal),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: Colors.red),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Total',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Divider(color: Colors.grey.shade300, height: 1),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25.r),
                        child: _loja!.imagemUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: _loja!.imagemUrl,
                                width: 50.r,
                                height: 50.r,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 50.r,
                                height: 50.r,
                                color: Colors.grey.shade200,
                                child: Icon(Icons.store, color: Colors.grey.shade400),
                              ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Restaurante',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
                            ),
                            Text(
                              _loja!.nome,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _ligarParaRestaurante(_loja!.endereco?.rua), // Aqui o modelo não tem telefone, colocar um fallback.
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.call, color: Colors.white, size: 24.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  // "Slide After Arrival" Botão Simulado
                  Container(
                    width: double.infinity,
                    height: 56.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Deslize após a chegada  >',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
