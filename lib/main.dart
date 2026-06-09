import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/app_config/app_config_cubit.dart';
import 'package:restaurantmobile/presentation/blocs/cart/cart_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/datafono/dataphone_payment_screen.dart';
import 'package:restaurantmobile/presentation/blocs/datafono/payment_success_screen.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_screen.dart';
import 'package:restaurantmobile/presentation/blocs/welcome/welcome_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppConfigCubit()..loadConfiguration()),
        BlocProvider(
          create: (_) =>
              CartBloc(), // 👈 3. El carrito ahora es global y persistente
        ),
      ],
      child: BlocBuilder<AppConfigCubit, AppConfigState>(
        builder: (context, state) {
          return MaterialApp(
            title: state.restaurantName.isNotEmpty
                ? state.restaurantName
                : 'Kiosko',
            debugShowCheckedModeBanner: false,
            theme: state.themeData,
            home: const WelcomeScreen(),
            routes: {
              '/menu': (context) => const MenuScreen(),
              '/dataphone_payment': (context) {
                // Recuperamos el total enviado por los argumentos de la navegación
                final total =
                    ModalRoute.of(context)!.settings.arguments as double;
                return DataphonePaymentScreen(totalAmount: total);
              },
              '/payment_success': (context) => const PaymentSuccessScreen(),
            },
          );
        },
      ),
    );
  }
}
