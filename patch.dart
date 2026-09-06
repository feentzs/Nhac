import 'dart:io';

void main() {
  final file = File(r'c:\Users\tuxedo\source\repos\FNFVsliceLauncher\FNFVsliceLauncher\Nhac\lib\pages\search_page.dart');
  var content = file.readAsStringSync().replaceAll('\r\n', '\n');

  // 1. State class definition
  content = content.replaceFirst(
    'class _SearchPageState extends State<SearchPage> {',
    'class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {\n  late AnimationController _animationController;'
  );

  // 2. initState
  content = content.replaceFirst(
    '  @override\n  void initState() {\n    super.initState();\n    _carregarHistorico();',
    '  @override\n  void initState() {\n    super.initState();\n    _animationController = AnimationController(\n        vsync: this, duration: const Duration(milliseconds: 800));\n    _animationController.forward();\n    _carregarHistorico();'
  );

  // 3. dispose and _buildAnimatedItem
  content = content.replaceFirst(
    '  @override\n  void dispose() {\n    _searchController.dispose();\n    _searchFocus.dispose();\n    super.dispose();\n  }',
    '  @override\n  void dispose() {\n    _animationController.dispose();\n    _searchController.dispose();\n    _searchFocus.dispose();\n    super.dispose();\n  }\n\n  Widget _buildAnimatedItem(Widget child, int index) {\n    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(\n        CurvedAnimation(\n            parent: _animationController,\n            curve: Interval((index * 0.1).clamp(0.0, 1.0),\n                (index * 0.1 + 0.5).clamp(0.0, 1.0),\n                curve: Curves.easeOutCubic)));\n    return AnimatedBuilder(\n        animation: animation,\n        builder: (context, child) => Opacity(\n            opacity: animation.value,\n            child: Transform.translate(\n                offset: Offset(0, 30 * (1 - animation.value)), child: child)),\n        child: child);\n  }'
  );

  // 4. _iniciarBusca
  content = content.replaceFirst(
    '    _salvarNoHistorico(termoLimpo);\n    setState(() {\n      _filtro = _FiltroBusca.tudo;',
    '    _salvarNoHistorico(termoLimpo);\n    _animationController.forward(from: 0.0);\n    setState(() {\n      _filtro = _FiltroBusca.tudo;'
  );

  // 5. _buscarPorCategoriaInicial
  content = content.replaceFirst(
    '  void _buscarPorCategoriaInicial(String categoria) {\n    if (categoria.isEmpty) return;\n    setState(() {',
    '  void _buscarPorCategoriaInicial(String categoria) {\n    if (categoria.isEmpty) return;\n    _animationController.forward(from: 0.0);\n    setState(() {'
  );

  // 6. Replace _buildBarraBusca
  final oldBarraBusca = '''
  Widget _buildBarraBusca() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: _corTexto, size: 18.r),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.r),
                border: Border.all(
                  color:
                      _searchFocus.hasFocus ? _corPrimaria : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: _searchFocus.hasFocus
                    ? []
                    : [
                        BoxShadow(
                          color: _corTexto.withValues(alpha: 0.05),
                          blurRadius: 10.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: _corTexto.withValues(alpha: 0.6), size: 20.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onSubmitted: _iniciarBusca,
                      style: TextStyle(
                          color: _corTexto,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Pesquisar produtos ou lojas...',
                        hintStyle: TextStyle(
                          color: _corTexto.withValues(alpha: 0.4),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _temTexto
                        ? GestureDetector(
                            key: const ValueKey('clear'),
                            onTap: _limparBusca,
                            child: Icon(Icons.close_rounded,
                                color: _corTexto.withValues(alpha: 0.5),
                                size: 18.r),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }'''.replaceAll('\r\n', '\n');

  final newBarraBusca = '''
  Widget _buildBarraBusca() {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, left: 24.w, right: 24.w, bottom: 24.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF5D201C).withValues(alpha: 0.05),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h))
                  ]),
              child: Icon(Icons.arrow_back,
                  color: const Color(0xFF5D201C), size: 20.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Hero(
              tag: 'search_bar',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(
                      color:
                          _searchFocus.hasFocus ? _corPrimaria : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: _searchFocus.hasFocus
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF5D201C).withValues(alpha: 0.05),
                              blurRadius: 10.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          onSubmitted: _iniciarBusca,
                          style: TextStyle(
                              color: _corTexto,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Procurar',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _temTexto
                            ? GestureDetector(
                                key: const ValueKey('clear'),
                                onTap: _limparBusca,
                                child: Icon(Icons.close_rounded,
                                    color: _corTexto.withValues(alpha: 0.5),
                                    size: 18.r),
                              )
                            : const Icon(Icons.tune, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }'''.replaceAll('\r\n', '\n');

  content = content.replaceFirst(oldBarraBusca, newBarraBusca);

  // 7. _StaggeredFadeIn replacements
  content = content.replaceAllMapped(RegExp(r'_StaggeredFadeIn\(\s*index:\s*([a-zA-Z0-9_]+),\s*child:\s*(.*?),\s*\)', dotAll: true), (match) {
    return '_buildAnimatedItem(${match.group(2)}, ${match.group(1)})';
  });
  
  // Also remove the _StaggeredFadeIn class at the end
  content = content.replaceAll(RegExp(r'/// Faz um item de lista/grid entrar com fade.*?}\n', dotAll: true), '');

  file.writeAsStringSync(content);
  print('Done patching.');
}
