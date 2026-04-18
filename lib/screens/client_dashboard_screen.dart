import 'dart:io';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'client_login_screen.dart';
import 'client_profile_setup_screen.dart';

/// Client Dashboard shown after successful login.
class ClientDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> client;

  const ClientDashboardScreen({super.key, required this.client});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> _client;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _client = widget.client;
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profilePath = _client['profile_pic_path'] as String? ?? '';
    final hasImage = profilePath.isNotEmpty && File(profilePath).existsSync();
    final name = _client['name'] as String? ?? 'User';

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        backgroundColor: AppTheme.primaryDark,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.backgroundGradient,
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: AppTheme.surfaceCard,
                      backgroundImage: hasImage ? FileImage(File(profilePath)) : null,
                      child: hasImage
                          ? null
                          : Text(
                              name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    accountName: Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    accountEmail: Text(_client['username'] ?? '', style: const TextStyle(color: AppTheme.textSecondary)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard_rounded, color: AppTheme.textPrimary),
                    title: const Text('Dashboard', style: TextStyle(color: AppTheme.textPrimary)),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_rounded, color: AppTheme.textPrimary),
                    title: const Text('Edit Profile', style: TextStyle(color: AppTheme.textPrimary)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 400),
                          reverseTransitionDuration: const Duration(milliseconds: 350),
                          pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
                            opacity: animation,
                            child: ClientProfileSetupScreen(client: _client),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.surfaceCard, thickness: 1, height: 1),
            SafeArea(
              top: false,
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppTheme.error),
                title: const Text('Logout', style: TextStyle(color: AppTheme.error)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppTheme.surfaceCard,
                      title: const Text('Confirm Logout',
                          style: TextStyle(color: AppTheme.textPrimary)),
                      content: const Text('Are you sure you want to log out?',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, secondaryAnimation) => const ClientLoginScreen(),
                                transitionDuration: const Duration(milliseconds: 400),
                                transitionsBuilder: (_, animation, secondaryAnimation, child) =>
                                    FadeTransition(opacity: animation, child: child),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text('Logout',
                              style: TextStyle(color: AppTheme.error)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('My Dashboard'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Welcome Header ──
                FadeTransition(
                  opacity: _animController,
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: hasImage ? null : AppTheme.accentGradient,
                          image: hasImage
                              ? DecorationImage(
                                  image: FileImage(File(profilePath)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentPurple.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: hasImage
                            ? null
                            : Center(
                                child: Text(
                                  name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Goal Card ──
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: _animController, curve: Curves.easeOutCubic)),
                  child: FadeTransition(
                    opacity: _animController,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.glassMorphism(opacity: 0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppTheme.accentGradient.createShader(bounds),
                                child: const Icon(Icons.flag_circle_rounded,
                                    color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Current Goal',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _client['goal'] as String? ?? 'Keep pushing forward!',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Stats Grid ──
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: _animController, curve: Curves.easeOutCubic)),
                  child: FadeTransition(
                    opacity: _animController,
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard(
                          'Age',
                          '${_client['age'] ?? '-'}',
                          'years',
                          Icons.cake_rounded,
                          AppTheme.accentGradient,
                        ),
                        _buildStatCard(
                          'Weight',
                          '${_client['weight'] ?? '-'}',
                          'kg',
                          Icons.monitor_weight_rounded,
                          AppTheme.pinkGradient,
                        ),
                        _buildStatCard(
                          'Height',
                          '${_client['height'] ?? '-'}',
                          'cm',
                          Icons.height_rounded,
                          AppTheme.cardGradient,
                        ),
                        _buildStatCard(
                          'BMI',
                          _calculateBMI(
                              _client['weight'] as num?, _client['height'] as num?),
                          '',
                          Icons.favorite_rounded,
                          AppTheme.accentGradient,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _calculateBMI(num? weight, num? heightCm) {
    if (weight == null || heightCm == null || heightCm == 0) return '-';
    final heightM = heightCm / 100;
    final bmi = weight / (heightM * heightM);
    return bmi.toStringAsFixed(1);
  }

  Widget _buildStatCard(
      String label, String value, String unit, IconData icon, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassMorphism(opacity: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentCyan.withValues(alpha: 0.8), size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
