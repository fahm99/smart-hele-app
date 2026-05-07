import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_data_provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme/app_colors.dart';

class FallAlertOverlay extends StatelessWidget {
  const FallAlertOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorProvider = context.watch<SensorDataProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (!sensorProvider.isFallPending) return const SizedBox.shrink();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        color: Colors.black.withOpacity(0.85),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'FALL DETECTED!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Alerting admin and emergency services in...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Countdown Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: sensorProvider.fallCountdown / 5,
                        strokeWidth: 12,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.error),
                      ),
                    ),
                    Text(
                      '${sensorProvider.fallCountdown}',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 80),
                
                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: ElevatedButton(
                    onPressed: () => sensorProvider.cancelFallAlert(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 10,
                    ),
                    child: const Text(
                      'I AM OKAY',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Immediate Trigger Button
                TextButton(
                  onPressed: () {
                    sensorProvider.cancelFallAlert(); // stop timer
                    sensorProvider.confirmFallAlert(authProvider.user?.id ?? 'unknown');
                  },
                  child: const Text(
                    'SEND ALERT NOW',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
