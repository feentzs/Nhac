import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/components/botoes/botao_largo_nhac.dart';
import 'package:nhac/components/seta_voltar.dart';

class CuponsPage extends StatefulWidget {
  const CuponsPage({super.key});

  @override
  State<CuponsPage> createState() => _CuponsPageState();
}

class _CuponsPageState extends State<CuponsPage> {
  int _abaSelecionada = 0;
  final TextEditingController _cupomController = TextEditingController();

  final List<Map<String, dynamic>> _cupons = [
    {'titulo': '20% desconto em Frutas', 'validade': 'Válido até 02/08/2026', 'icone': Icons.apple, 'status': 0},
    {'titulo': '25% desconto em Vegetais', 'validade': 'Válido até 04/08/2026', 'icone': Icons.eco, 'status': 0},
    {'titulo': '20% desconto em Peixes', 'validade': 'Válido até 05/08/2026', 'icone': Icons.set_meal, 'status': 0},
  ];

  @override
  void dispose() {
    _cupomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        _buildTabItem(0, 'Disponíveis (5)'),
                        _buildTabItem(1, 'Usados (0)'),
                        _buildTabItem(2, 'Expirados (0)'),
                      ]),
                      SizedBox(height: 32.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                            Expanded(child: TextField(controller: _cupomController, decoration: const InputDecoration(hintText: 'Digite o código do cupom', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey, fontSize: 14)))),
                            TextButton(onPressed: () {}, child: Text('Resgatar', style: TextStyle(color: const Color(0xFFFF6961), fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cupons.where((c) => c['status'] == _abaSelecionada).length,
                        separatorBuilder: (context, index) => Divider(height: 32.h, color: const Color(0xFFF5F5F5)),
                        itemBuilder: (context, index) {
                          final cupom = _cupons.where((c) => c['status'] == _abaSelecionada).toList()[index];
                          return Row(
                            children: [
                              Container(padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(12.r)), child: Icon(cupom['icone'], color: const Color(0xFFFF6961), size: 28.sp)),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cupom['titulo'], style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C))),
                                    SizedBox(height: 4.h),
                                    Text(cupom['validade'], style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              TextButton(onPressed: () {}, child: Text('Usar', style: TextStyle(color: const Color(0xFFFF6961), fontWeight: FontWeight.bold, fontSize: 14.sp))),
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
            Padding(
              padding: EdgeInsets.all(24.w),
              child: BotaoLargoNhac(texto: 'Usar', onPressed: () => context.pop()),
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