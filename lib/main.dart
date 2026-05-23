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
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac/services/push_notification_service.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Notificação em background recebida!");
}

@NowaGenerated()
late final SharedPreferences sharedPrefs;

@NowaGenerated()
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final pushService = PushNotificationService();
  await pushService.initialize();

  sharedPrefs = await SharedPreferences.getInstance();

   FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, 
  );

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://426ab5d997cbcb45965278b6b9cc5a32@o4511393718272000.ingest.us.sentry.io/4511393743896577';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(SentryWidget(child: const MyApp())),
  );
  // TODO: Remove this line after sending the first sample event to sentry.
  await Sentry.captureException(Exception('This is a sample exception.'));
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
            
          return ScreenUtilInit(
              designSize: const Size(390, 844), // Tamanho base do seu design no Figma
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
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
      },
    );
  }
}