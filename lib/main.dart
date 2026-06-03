import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/app_config/app_config_cubit.dart';
import 'package:restaurantmobile/presentation/blocs/menu/menu_screen.dart';
import 'package:restaurantmobile/presentation/blocs/welcome/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppConfigCubit()..loadConfiguration(),
      child: BlocBuilder<AppConfigCubit, AppConfigState>(
        builder: (context, state) {
          return MaterialApp(
            title: state.restaurantName.isNotEmpty ? state.restaurantName : 'Kiosko',
            debugShowCheckedModeBanner: false,
            theme: state.themeData,
            home: const WelcomeScreen(),
            routes: {
              '/menu': (context) => const MenuScreen(),
            },
          );
        },
      ),
    );
  }
}