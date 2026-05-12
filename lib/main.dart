import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nhac/controllers/cadastro_controller.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nhac/controllers/endereco_provider.dart';
import 'package:nhac/controllers/user_provider.dart';
import 'package:nhac/services/auth_service.dart';
import 'package:nhac/services/connectivity_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:flutter/material.dart';
import 'package:nhac/globals/app_state.dart';
import 'package:nhac/globals/router.dart';
import 'package:firebase_core/firebase_core.dart';
import './firebase_options.dart';


import 'package:flutter_dotenv/flutter_dotenv.dart';

@NowaGenerated()
late final SharedPreferences sharedPrefs;

@NowaGenerated()
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  sharedPrefs = await SharedPreferences.getInstance();

   FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, 
  );

  runApp(const MyApp());
}

@NowaGenerated({'visibleInNowa': false})
class MyApp extends StatelessWidget {
  
  @NowaGenerated({'loader': 'auto-constructor'})
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      
      providers: [
        ChangeNotifierProvider<AppState>(create: (context) => AppState()),
        ChangeNotifierProvider<AuthService>(create: (context) => AuthService()), 
        ChangeNotifierProvider<CadastroController>(create: (context) => CadastroController()),
        ChangeNotifierProvider<UserProvider>(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => EnderecoProvider()),
        ChangeNotifierProvider<ConnectivityService>(create: (context) => ConnectivityService()),
      ],
      builder: (context, child) {
        return Consumer<ConnectivityService>(
          builder: (context, connectivity, child) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: AppState.of(context).theme,
              routerConfig: appRouter,
              builder: (context, navigator) {
                // if (!connectivity.isOnline) {
                //   return const NoInternetPage();
                // }
                return navigator!;
              },
            );
          },
        );
      },
    );
  }
}
