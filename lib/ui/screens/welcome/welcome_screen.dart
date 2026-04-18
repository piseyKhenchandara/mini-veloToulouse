import 'package:flutter/material.dart';
import 'package:mini_velo/ui/screens/shell/main_shell.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              _BikeHeader(),
              const SizedBox(height: 32),
              _MapCard(),
              const Spacer(),
              PrimaryButton(
                label: 'Explore Map',
                icon: Icons.map_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MainShell()),
                  );
                },
              ),
              const SizedBox(height: 18),
              const Spacer(),
              _Footer(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _BikeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/ride.png', width: 72, height: 72),
        const SizedBox(height: 16),
        const Text(
          'KONG JOUL',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your city, your ride, your way',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textDark,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _MapCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        'assets/images/location.png',
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      '© Official-City-Service | VeloToulouse',
      style: TextStyle(
        fontSize: 11,
        color: AppColors.textMuted,
        letterSpacing: 0.3,
      ),
    );
  }
}
