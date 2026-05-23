import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nhac/models/loja/lojas.dart';
import 'package:nhac/models/produto/produtos.dart';
import 'package:nhac/pages/loja_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/components/home/home_banner_carousel.dart';
import 'package:nhac/components/home/home_product_section.dart';
import 'package:nhac/pages/search_page.dart';
import 'package:nhac/controllers/endereco_provider.dart';
import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/services/local_cache_service.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nhac/controllers/user_provider.dart';
import 'package:provider/provider.dart';

@NowaGenerated()
class HomeContent extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _currentAddress = 'Buscando localização...';
  static bool _jaCarregouUmaVez = false;
  late bool _isLoading;

  Widget _buildListaDeLojas() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('lojas').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: List.generate(
                3,
                (index) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _buildBoxSkeleton(
                          width: double.infinity, height: 90.h, borderRadius: 12.r),
                    )),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: Text(
                'Nenhum restaurante encontrado na região.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final lojas = snapshot.data!.docs.map((doc) {
          return LojasModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: lojas.length,
          itemBuilder: (context, index) {
            final loja = lojas[index];

            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5D201C).withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: const Offset(0.0, 4.0),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () {
                  if (loja.aberta) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LojaPage(loja: loja),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('${loja.nome} está fechado no momento.')),
                    );
                  }
                },
                child: Opacity(
                  opacity: loja.aberta ? 1.0 : 0.5,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CachedNetworkImage(
                            imageUrl: loja.imagemUrl,
                            width: 70.w,
                            height: 70.w,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: 70.w,
                                height: 70.w,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 70.w,
                              height: 70.w,
                              color: Colors.grey.shade100,
                              child: Icon(Icons.store, color: Colors.grey, size: 24.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),

                        // Informações do Restaurante
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      loja.nome,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: const Color(0xFF5D201C),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber, size: 16.r),
                                      SizedBox(width: 4.w),
                                      Text(
                                        loja.mediaAvaliacao.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                loja.categoria,
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 13.sp),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                loja.aberta ? 'Aberto agora' : 'Fechado',
                                style: TextStyle(
                                  color: loja.aberta
                                      ? const Color(0xFFFF6961)
                                      : Colors.red.shade300,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSecaoProdutosFirebase(String titulo) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('produtos')
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("🔴 ERRO DO FIREBASE: ${snapshot.error}");
        } else if (snapshot.hasData) {
          debugPrint("🟢 LOJAS ENCONTRADAS: ${snapshot.data!.docs.length}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSectionSkeleton();
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final produtosFirebase = snapshot.data!.docs.map((doc) {
          return ProdutosModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        final produtosParaTela = produtosFirebase.map((prod) {
          return ProductSectionItem(
            idProduto: prod.uid,
            imageUrl: prod.imagemUrl.isNotEmpty
                ? prod.imagemUrl
                : 'https://via.placeholder.com/150',
            name: prod.nome,
            weight: '',
            price: prod.preco,
            discountPercent: null,
          );
        }).toList();

        return HomeProductSection(
          title: titulo,
          onSeeAll: () {},
          products: produtosParaTela,
        );
      },
    );
  }

  final List<ProductSectionItem> _produtosNecessidades = [
    const ProductSectionItem(
      idProduto: 'prod_001',
      imageUrl:
          'https://pbs.twimg.com/media/GtXShofWAAAJX5w?format=jpg&name=small',
      name: 'Pãozinho',
      weight: '50 g.',
      price: 16.00,
      discountPercent: null,
    ),
    const ProductSectionItem(
      idProduto: 'prod_002',
      imageUrl:
          'https://pbs.twimg.com/media/G3TGk4iWIAA4s5I?format=jpg&name=large',
      name: 'Carne',
      weight: '68 g.',
      price: 16.00,
      discountPercent: 20,
    ),
    const ProductSectionItem(
      idProduto: 'prod_003',
      imageUrl:
          'https://pbs.twimg.com/media/G5QJ2csWMAAoV07?format=jpg&name=large',
      name: 'Coxinha',
      weight: '140 g.',
      price: 1.90,
      discountPercent: null,
    ),
    const ProductSectionItem(
      idProduto: 'prod_004',
      imageUrl:
          'https://scontent-gru2-1.cdninstagram.com/v/t51.82787-15/529775120_18051698096641079_8755412289038896486_n.jpg?stp=dst-jpg_e35_tt6&_nc_cat=109&ig_cache_key=MzY5NDY0NTUwODQwODc3MjM5OA%3D%3D.3-ccb7-5&ccb=7-5&_nc_sid=58cdad&efg=eyJ2ZW5jb2RlX3RhZyI6IkZFRUQueHBpZHMuMTQ0MC5zZHIucmVndWxhcl9waG90by5DMyJ9&_nc_ohc=bc5H_aNNKJ8Q7kNvwEYKUHk&_nc_oc=AdpsCnmGJAjhPQAngv4wL6jQ_ghXce55Vz-fwy4iNb2y8wJ5LlYQGbQEXKocsvfSX6mj8cPbeESIm2_CHEOEnESY&_nc_ad=z-m&_nc_cid=0&_nc_zt=23&_nc_ht=scontent-gru2-1.cdninstagram.com&_nc_gid=gIS1rtj7AdY_TZoXLUV27A&_nc_ss=7a22e&oh=00_Af4KGjw7haLwhDBlF4-eJuHgGO9MC7QH7iGdfJxdETwJ3w&oe=6A01486A',
      name: 'Refrigerante Viver',
      weight: '2L',
      price: 03.99,
      discountPercent: 10,
    ),
  ];

  final List<ProductSectionItem> _produtosPromocao = [
    const ProductSectionItem(
      idProduto: 'prod_005',
      imageUrl:
          'https://pbs.twimg.com/media/GtXShofWAAAJX5w?format=jpg&name=small',
      name: 'Pãozinho',
      weight: '50 g.',
      price: 16.00,
      discountPercent: null,
    ),
    const ProductSectionItem(
      idProduto: 'prod_006',
      imageUrl:
          'https://pbs.twimg.com/media/G3TGk4iWIAA4s5I?format=jpg&name=large',
      name: 'Carne',
      weight: '68 g.',
      price: 16.00,
      discountPercent: 20,
    ),
    const ProductSectionItem(
      idProduto: 'prod_007',
      imageUrl:
          'https://pbs.twimg.com/media/G5QJ2csWMAAoV07?format=jpg&name=large',
      name: 'Coxinha',
      weight: '140 g.',
      price: 1.90,
      discountPercent: null,
    ),
    const ProductSectionItem(
      idProduto: 'prod_008',
      imageUrl:
          'https://scontent-gru2-1.cdninstagram.com/v/t51.82787-15/529775120_18051698096641079_8755412289038896486_n.jpg?stp=dst-jpg_e35_tt6&_nc_cat=109&ig_cache_key=MzY5NDY0NTUwODQwODc3MjM5OA%3D%3D.3-ccb7-5&ccb=7-5&_nc_sid=58cdad&efg=eyJ2ZW5jb2RlX3RhZyI6IkZFRUQueHBpZHMuMTQ0MC5zZHIucmVndWxhcl9waG90by5DMyJ9&_nc_ohc=bc5H_aNNKJ8Q7kNvwEYKUHk&_nc_oc=AdpsCnmGJAjhPQAngv4wL6jQ_ghXce55Vz-fwy4iNb2y8wJ5LlYQGbQEXKocsvfSX6mj8cPbeESIm2_CHEOEnESY&_nc_ad=z-m&_nc_cid=0&_nc_zt=23&_nc_ht=scontent-gru2-1.cdninstagram.com&_nc_gid=gIS1rtj7AdY_TZoXLUV27A&_nc_ss=7a22e&oh=00_Af4KGjw7haLwhDBlF4-eJuHgGO9MC7QH7iGdfJxdETwJ3w&oe=6A01486A',
      name: 'Refrigerante Viver',
      weight: '2L',
      price: 03.99,
      discountPercent: 10,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isLoading = !_jaCarregouUmaVez;

    _produtosNecessidades.shuffle();
    _produtosPromocao.shuffle();
    _carregarGpsComCache();

    if (_isLoading) {
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _jaCarregouUmaVez = true;
          });
        }
      });
    }
  }

  Future<void> _carregarGpsComCache() async {
    final cachedGps = await LocalCacheService.carregarLocalizacaoGps();
    if (cachedGps != null && mounted) {
      setState(() => _currentAddress = cachedGps);
    }
    _pegarLocalizacaoUsuario();
  }

  Future<void> _pegarLocalizacaoUsuario() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _currentAddress = 'GPS desativado');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _currentAddress = 'Permissão negada');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() => _currentAddress = 'Permissão negada permanentemente');
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final endereco = '${place.street}, ${place.subLocality}';
        if (mounted) {
          setState(() => _currentAddress = endereco);
          LocalCacheService.salvarLocalizacaoGps(endereco);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = 'Erro ao buscar endereço');
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _pegarLocalizacaoUsuario(),
      context.read<UserProvider>().carregarDadosUsuario(),
    ]);
  }

  void _abrirSelecaoEndereco(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SelecaoEnderecoBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enderecoPadrao = context.select<EnderecoProvider, EnderecoModel?>(
      (p) => p.enderecos.where((e) => e.padrao).firstOrNull,
    );

    String enderecoTopo = _currentAddress;
    if (enderecoPadrao != null) {
      enderecoTopo = '${enderecoPadrao.rua}, ${enderecoPadrao.numero}';
      if (enderecoPadrao.complemento.isNotEmpty) {
        enderecoTopo += ' - ${enderecoPadrao.complemento}';
      }
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          refreshIndicatorExtent: 140.h,
          refreshTriggerPullDistance: 180.h,
          onRefresh: _onRefresh,
          builder: (context, refreshState, pulledExtent,
              refreshTriggerPullDistance, refreshIndicatorExtent) {
            return Center(
              child: Opacity(
                opacity:
                    (pulledExtent / refreshIndicatorExtent).clamp(0.0, 1.0),
                child: Lottie.asset(
                  'assets/animations/loading_nhac.json',
                  width: 240.w,
                  height: 240.h,
                  animate: refreshState == RefreshIndicatorMode.refresh ||
                      refreshState == RefreshIndicatorMode.armed,
                ),
              ),
            );
          },
        ),
        SliverPadding(
          padding: EdgeInsets.all(24.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 16.h),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, -20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF5D201C)
                                          .withValues(alpha: 0.05),
                                      blurRadius: 10.r,
                                      offset: const Offset(0.0, 4.0),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.grey,
                                  size: 20.r,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sua Localização',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12.sp),
                                    ),
                                    Text(
                                      enderecoTopo,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                        color: const Color(0xFF5D201C),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        GestureDetector(
                          onTap: () => _abrirSelecaoEndereco(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5D201C)
                                      .withValues(alpha: 0.05),
                                  blurRadius: 10.r,
                                  offset: const Offset(0.0, 4.0),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Mudar',
                                  style: TextStyle(
                                    color: const Color(0xFFFF6961),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: const Color(0xFFFF6961), size: 18.r),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Hero(
                      tag: 'search_bar',
                      child: Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const SearchPage(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                      opacity: animation, child: child);
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5D201C)
                                      .withValues(alpha: 0.05),
                                  blurRadius: 10.r,
                                  offset: const Offset(0.0, 4.0),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey, size: 22.r),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Procurar',
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 16.sp),
                                  ),
                                ),
                                Icon(Icons.tune, color: Colors.grey, size: 22.r),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, -20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: _isLoading
                      ? SizedBox(
                          key: const ValueKey('carousel_skeleton'),
                          height: 180.h,
                          child: PageView(
                            controller: PageController(viewportFraction: 0.9),
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildBoxSkeleton(
                                  width: double.infinity,
                                  height: 180.h,
                                  borderRadius: 20.r),
                            ],
                          ),
                        )
                      : const HomeBannerCarousel(
                          key: ValueKey('carousel_content')),
                ),
              ),
              SizedBox(height: 28.h),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: _isLoading
                      ? _buildSectionSkeleton(
                          key: const ValueKey('section1_skeleton'))
                      : _buildSecaoProdutosFirebase(
                          'Temos tudo que você precisa'),
                ),
              ),
              SizedBox(height: 28.h),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: _isLoading
                      ? _buildSectionSkeleton(
                          key: const ValueKey('section2_skeleton'))
                      : HomeProductSection(
                          key: const ValueKey('section2_content'),
                          title: 'Tudo abaixo de R\$ 20',
                          onSeeAll: () {},
                          products: _produtosPromocao,
                        ),
                ),
              ),
              SizedBox(height: 28.h),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurantes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                        color: const Color(0xFF5D201C),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildListaDeLojas(),
                  ],
                ),
              ),
              SizedBox(height: 100.h),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildBoxSkeleton(
      {double? width, double? height, double borderRadius = 8}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  Widget _buildSectionSkeleton({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBoxSkeleton(width: 180.w, height: 20.h),
            _buildBoxSkeleton(width: 60.w, height: 16.h),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 220.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) => _buildProductCardSkeleton(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCardSkeleton() {
    return Container(
      width: 160.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildBoxSkeleton(
                width: 160.w, height: double.infinity, borderRadius: 16.r),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBoxSkeleton(width: 100.w, height: 14.h),
                SizedBox(height: 4.h),
                _buildBoxSkeleton(width: 60.w, height: 12.h),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBoxSkeleton(width: 50.w, height: 16.h),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelecaoEnderecoBottomSheet extends StatelessWidget {
  const _SelecaoEnderecoBottomSheet();

  @override
  Widget build(BuildContext context) {
    final enderecoProvider = context.watch<EnderecoProvider>();
    final enderecos = enderecoProvider.enderecos;

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
                'Onde você quer receber seu pedido?',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D201C),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: enderecos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final endereco = enderecos[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    context
                        .read<EnderecoProvider>()
                        .definirComoPadrao(endereco.idDocumento);
                    Navigator.pop(context);
                  },
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6961).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      endereco.bairro.toLowerCase().contains('trabalho') ||
                              endereco.complemento
                                  .toLowerCase()
                                  .contains('trabalho')
                          ? Icons.work_outline
                          : Icons.home_outlined,
                      color: const Color(0xFFFF6961),
                      size: 20.r,
                    ),
                  ),
                  title: Text(
                    '${endereco.rua}, ${endereco.numero}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  subtitle: Text(
                    '${endereco.bairro}${endereco.complemento.isNotEmpty ? ' - ${endereco.complemento}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  trailing: endereco.padrao
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
              onTap: () {
                Navigator.pop(context);
                context.push('/enderecos-salvos');
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: Colors.grey, size: 20.r),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Adicionar novo endereço',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                        color: Colors.grey,
                      ),
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