import 'dart:io';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../theme/app_theme.dart';

/// Shows full details for a single user when the admin taps a card in the
/// AdminListScreen.
class AdminUserDetailScreen extends StatelessWidget {
  final int clientId;

  const AdminUserDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: AppTheme.glassMorphism(borderRadius: 12, opacity: 0.1),
            child:
                const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: AppTheme.glassMorphism(borderRadius: 12, opacity: 0.1),
              child: const Icon(Icons.delete_forever_rounded, size: 20, color: AppTheme.error),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.surfaceCard,
                  title: const Text('Delete User',
                      style: TextStyle(color: AppTheme.textPrimary)),
                  content: const Text('Are you sure you want to permanently delete this user?',
                      style: TextStyle(color: AppTheme.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); // close dialog
                        await DatabaseHelper.instance.deleteUser(clientId);
                        if (context.mounted) {
                          Navigator.pop(context); // back to admin list
                        }
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: AppTheme.error)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: DatabaseHelper.instance.getClientById(clientId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.accentCyan),
              );
            }

            final client = snapshot.data;
            if (client == null) {
              return const Center(
                child: Text(
                  'User not found.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
              );
            }

            final profilePath =
                client['profile_pic_path'] as String? ?? '';
            final hasImage =
                profilePath.isNotEmpty && File(profilePath).existsSync();

            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // ── Profile image ──
                    Hero(
                      tag: 'avatar_$clientId',
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:
                              hasImage ? null : AppTheme.accentGradient,
                          image: hasImage
                              ? DecorationImage(
                                  image: FileImage(File(profilePath)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentPurple
                                  .withValues(alpha: 0.45),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: hasImage
                            ? null
                            : Center(
                                child: Text(
                                  (client['name'] as String? ?? '?')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 56,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ── Name ──
                    Text(
                      client['name'] as String? ?? 'Unknown',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // ── Role badge ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'USER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // ── Info card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.glassMorphism(opacity: 0.08),
                      child: Column(
                        children: [
                          _infoRow(
                            Icons.person_rounded,
                            'Full Name',
                            client['name'] as String? ?? '',
                          ),
                          _divider(),
                          _infoRow(
                            Icons.cake_rounded,
                            'Age',
                            '${client['age']} years',
                          ),
                          _divider(),
                          _infoRow(
                            Icons.monitor_weight_rounded,
                            'Weight',
                            '${client['weight']} kg',
                          ),
                          _divider(),
                          _infoRow(
                            Icons.height_rounded,
                            'Height',
                            '${client['height']} cm',
                          ),
                          _divider(),
                          _infoRow(
                            Icons.flag_rounded,
                            'Fitness Goal',
                            client['goal'] as String? ?? '',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.accentGradient.createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.06),
      height: 1,
    );
  }
}
