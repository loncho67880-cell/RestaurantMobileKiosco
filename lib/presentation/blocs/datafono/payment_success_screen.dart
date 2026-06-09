import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/app_config/app_config_cubit.dart';
import 'package:restaurantmobile/presentation/blocs/cart/cart_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/cart/cart_event.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configCubit = context.read<AppConfigCubit>();

    return Scaffold(
      body: SafeArea(
        // Usamos LayoutBuilder para tomar toda la altura disponible
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              // ConstrainBox asegura que el contenido ocupe al menos la altura de la pantalla
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // El Spacer no funciona bien dentro de SingleChildScrollView, 
                    // así que usamos Sizedboxes para dar espacios flexibles
                    const SizedBox(height: 40), 

                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.shade400, width: 3),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 100,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 48),

                    Text(
                      configCubit.translate('payment_success'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      configCubit.translate('success_message'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      configCubit.translate('thank_you'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                    ),

                    const SizedBox(height: 40), // Espacio antes del botón

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<CartBloc>().add(ClearCartEvent()); 
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                        ),
                        child: Text(configCubit.translate('understood'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20), // Margen inferior extra
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}