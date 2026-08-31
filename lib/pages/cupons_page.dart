import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/components/seta_voltar.dart';
import 'package:nhac/globals/ui_utils.dart';
import 'package:nhac/models/usuario/cupom_model.dart';
import 'package:nhac/repositories/cupom_repository.dart';
import 'package:nhac/services/auth_service.dart';
import 'package:provider/provider.dart';

class CuponsPage extends StatefulWidget {
  const CuponsPage({super.key});

  @override
  State<CuponsPage> createState() => _CuponsPageState();
}

class _CuponsPageState extends State<CuponsPage> {
  int _abaSelecionada = 0;
  final TextEditingController _cupomController = TextEditingController();
  final CupomRepository _repository = CupomRepository();
  List<CupomModel> _cupons = [];
  bool _isLoading = true;
  bool _isResgatando = false;

  @override
  void initState() {
    super.initState();
    _carregarCupons();
  }

  Future<void> _carregarCupons() async {
    final auth = context.read<AuthService>();
    if (auth.usuarioId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final cupons = await _repository.buscarCupons(auth.usuarioId!);
      if (mounted) {
        setState(() {
          _cupons = cupons;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showError(e.toString());
      }
    }
  }

  Future<void> _resgatarCupom() async {
    final codigo = _cupomController.text.trim();
    if (codigo.isEmpty) return;

    final auth = context.read<AuthService>();
    if (auth.usuarioId == null) return;

    setState(() => _isResgatando = true);
    try {
      await _repository.resgatarCupom(auth.usuarioId!, codigo);
      if (!mounted) return;
      context.showSuccess('Cupom resgatado com sucesso!');
      _cupomController.clear();
      await _carregarCupons();
    } catch (e) {
      if (mounted) context.showError(e.toString());
    } finally {
      if (mounted) setState(() => _isResgatando = false);
    }
  }

  Future<void> _usarCupom(CupomModel cupom) async {
    if (cupom.status != 'DISPONIVEL') {
      context.showError('Este cupom não está disponível para uso.');
      return;
    }

    try {
      context.showSuccess('Validando cupom...');
      final cupomValidado = await _repository.validarCupom(cupom.codigo);
      if (!mounted) return;
      context.pop(cupomValidado); // Retorna ao checkout
    } catch (e) {
      if (mounted) context.showError(e.toString());
    }
  }

  List<CupomModel> _getCuponsFiltrados() {
    final statusAlvo = _abaSelecionada == 0 ? 'DISPONIVEL' : (_abaSelecionada == 1 ? 'USADO' : 'EXPIRADO');
    return _cupons.where((c) => c.status == statusAlvo).toList();
  }

  @override
  void dispose() {
    _cupomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cuponsFiltrados = _getCuponsFiltrados();

    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      const Row(children: [SetaVoltar()]),
                      SizedBox(height: 24.h),
                      Text('Cupons', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C))),
                      SizedBox(height: 24.h),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        _buildTabItem(0, 'Disponíveis (${_cupons.where((c) => c.status == 'DISPONIVEL').length})'),
                        _buildTabItem(1, 'Usados (${_cupons.where((c) => c.status == 'USADO').length})'),
                        _buildTabItem(2, 'Expirados (${_cupons.where((c) => c.status == 'EXPIRADO').length})'),
                      ]),
                      SizedBox(height: 32.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                            Expanded(child: TextField(controller: _cupomController, decoration: const InputDecoration(hintText: 'Digite o código do cupom', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey, fontSize: 14)))),
                            TextButton(
                              onPressed: _isResgatando ? null : _resgatarCupom,
                              child: _isResgatando 
                                ? SizedBox(height: 16.h, width: 16.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6961)))
                                : Text('Resgatar', style: TextStyle(color: const Color(0xFFFF6961), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator(color: Color(0xFFFF6961)))
                      else if (cuponsFiltrados.isEmpty)
                        Center(child: Text('Nenhum cupom encontrado.', style: TextStyle(color: Colors.grey.shade600)))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cuponsFiltrados.length,
                          separatorBuilder: (context, index) => Divider(height: 32.h, color: const Color(0xFFF5F5F5)),
                          itemBuilder: (context, index) {
                            final cupom = cuponsFiltrados[index];
                            final isDisponivel = cupom.status == 'DISPONIVEL';
                            return Row(
                              children: [
                                Container(padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.local_offer, color: isDisponivel ? const Color(0xFFFF6961) : Colors.grey, size: 28.sp)),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cupom.titulo, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: isDisponivel ? const Color(0xFF5D201C) : Colors.grey)),
                                      SizedBox(height: 4.h),
                                      Text(cupom.dataValidade ?? 'Sem validade', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                if (isDisponivel)
                                  TextButton(onPressed: () => _usarCupom(cupom), child: Text('Usar', style: TextStyle(color: const Color(0xFFFF6961), fontWeight: FontWeight.bold, fontSize: 14.sp))),
                              ],
                            );
                          },
                        ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    bool isSelected = _abaSelecionada == index;
    return GestureDetector(
      onTap: () => setState(() => _abaSelecionada = index),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFFFF6961) : const Color(0xFF5D201C))),
          if (isSelected) Container(margin: EdgeInsets.only(top: 4.h), height: 2.h, width: 20.w, color: const Color(0xFFFF6961)),
        ],
      ),
    );
  }
}
