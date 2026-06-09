import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantmobile/presentation/blocs/app_config/app_config_cubit.dart';
import 'package:restaurantmobile/presentation/blocs/welcome/bloc/welcome_bloc.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios del Cubit global para redibujar la pantalla entera si cambia el idioma o el tema
    return BlocBuilder<AppConfigCubit, AppConfigState>(
      builder: (context, configState) {
        if (configState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Proveemos el WelcomeBloc únicamente a la vista interna
        return BlocProvider(
          create: (_) => WelcomeBloc(),
          child: _WelcomeScreenView(configState: configState),
        );
      },
    );
  }
}

class _WelcomeScreenView extends StatelessWidget {
  final AppConfigState configState;

  const _WelcomeScreenView({required this.configState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configCubit = context.read<AppConfigCubit>();

    return BlocListener<WelcomeBloc, WelcomeState>(
      listener: (context, state) {
        if (state is WelcomeNavigateToMenu) {
          // 1. Guardamos la referencia al Bloc antes del async gap
          final welcomeBloc = context.read<WelcomeBloc>();

          Navigator.pushNamed(context, '/menu').then((_) {
            // 2. Usamos la referencia directa sin tocar el context
            welcomeBloc.resetState();
          });
        }
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => context.read<WelcomeBloc>().handleScreenTap(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Fondo (Igual que antes)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),

              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints
                            .maxHeight, // Asegura que ocupe toda la pantalla
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // --- Tus widgets (Icon, Text, Container, etc) ---
                            // Todo tu contenido actual va aquí dentro
                            Icon(
                              Icons.restaurant_menu_rounded,
                              size: 140,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 40),
                            // Título Traducido dinámicamente
                            Text(
                              configCubit.translate('welcome_title'),
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w300,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),

                            // Nombre del Restaurante
                            Text(
                              configState.restaurantName,
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 60),

                            // El botón ahora no causará overflow
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.secondary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Text(
                                configCubit.translate('welcome_call_to_action'),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              configCubit.translate('welcome_subtitle'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Selector de Idioma
              Positioned(
                top: 50,
                right: 30,
                child: Row(
                  children: [
                    _LanguageButton(label: 'ES', locale: 'es'),
                    const SizedBox(width: 10),
                    _LanguageButton(label: 'EN', locale: 'en'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final String locale;

  const _LanguageButton({required this.label, required this.locale});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
      ),
      onPressed: () {
        // Ejecuta el método que lee el nuevo JSON de i18n
        context.read<AppConfigCubit>().loadConfiguration(locale: locale);
      },
      child: Text(label),
    );
  }
}
