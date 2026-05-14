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
import 'package:go_router/go_router.dart';
import 'package:nhac/components/home_banner_carousel.dart';
import 'package:nhac/components/home_product_section.dart';
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
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildBoxSkeleton(
                          width: double.infinity, height: 90, borderRadius: 12),
                    )),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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

        // Desenha a lista
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: lojas.length,
          itemBuilder: (context, index) {
            final loja = lojas[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5D201C).withValues(alpha: 0.05),
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 4.0),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
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
// ...
                child: Opacity(
                  opacity: loja.aberta ? 1.0 : 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: loja.imagemUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: 70,
                                height: 70,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.store, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF5D201C),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        loja.mediaAvaliacao.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loja.categoria,
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                loja.aberta ? 'Aberto agora' : 'Fechado',
                                style: TextStyle(
                                  color: loja.aberta
                                      ? const Color(0xFFFF6961)
                                      : Colors.red.shade300,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
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
          onSeeAll: () {
            
          },
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
          refreshIndicatorExtent: 140.0,
          refreshTriggerPullDistance: 180.0,
          onRefresh: _onRefresh,
          builder: (context, refreshState, pulledExtent,
              refreshTriggerPullDistance, refreshIndicatorExtent) {
            return Center(
              child: Opacity(
                opacity:
                    (pulledExtent / refreshIndicatorExtent).clamp(0.0, 1.0),
                child: Lottie.asset(
                  'assets/animations/loading_nhac.json',
                  width: 240,
                  height: 240,
                  animate: refreshState == RefreshIndicatorMode.refresh ||
                      refreshState == RefreshIndicatorMode.armed,
                ),
              ),
            );
          },
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16.0),
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
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF5D201C)
                                          .withValues(alpha: 0.05),
                                      blurRadius: 10.0,
                                      offset: const Offset(0.0, 4.0),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.grey,
                                  size: 20.0,
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Sua Localização',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12.0),
                                    ),
                                    Text(
                                      enderecoTopo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color: Color(0xFF5D201C),
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
                        const SizedBox(width: 16.0),
                        GestureDetector(
                          onTap: () => _abrirSelecaoEndereco(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.0),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5D201C)
                                      .withValues(alpha: 0.05),
                                  blurRadius: 10.0,
                                  offset: const Offset(0.0, 4.0),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Mudar',
                                  style: TextStyle(
                                    color: Color(0xFFFF6961),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.0,
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: Color(0xFFFF6961), size: 18.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.0),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5D201C)
                                      .withValues(alpha: 0.05),
                                  blurRadius: 10.0,
                                  offset: const Offset(0.0, 4.0),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    'Procurar',
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 16.0),
                                  ),
                                ),
                                const Icon(Icons.tune, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
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
                          height: 180.0,
                          child: PageView(
                            controller: PageController(viewportFraction: 0.9),
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildBoxSkeleton(
                                  width: double.infinity,
                                  height: 180,
                                  borderRadius: 20),
                            ],
                          ),
                        )
                      : const HomeBannerCarousel(
                          key: ValueKey('carousel_content')),
                ),
              ),
              const SizedBox(height: 28.0),
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
              const SizedBox(height: 28.0),
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
              const SizedBox(height: 28.0),
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
                    const Text(
                      'Restaurantes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Color(0xFF5D201C),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _buildListaDeLojas(),
                  ],
                ),
              ),
              const SizedBox(height: 100.0),
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
            _buildBoxSkeleton(width: 180, height: 20),
            _buildBoxSkeleton(width: 60, height: 16),
          ],
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          height: 220.0,
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
      width: 160,
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildBoxSkeleton(
                width: 160, height: double.infinity, borderRadius: 16),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBoxSkeleton(width: 100, height: 14),
                const SizedBox(height: 4),
                _buildBoxSkeleton(width: 60, height: 12),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBoxSkeleton(width: 50, height: 16),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 24,
                        height: 24,
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Onde você quer receber seu pedido?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D201C),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    padding: const EdgeInsets.all(8),
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
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${endereco.rua}, ${endereco.numero}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    '${endereco.bairro}${endereco.complemento.isNotEmpty ? ' - ${endereco.complemento}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: endereco.padrao
                      ? const Icon(Icons.check_circle, color: Color(0xFFFF6961))
                      : null,
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(height: 32),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                context.push('/enderecos-salvos');
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Adicionar novo endereço',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
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
