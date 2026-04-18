import 'dart:io';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import 'admin_user_detail_screen.dart';

/// Lists every registered user in a beautiful card-based layout.
class AdminListScreen extends StatefulWidget {
  const AdminListScreen({super.key});

  @override
  State<AdminListScreen> createState() => _AdminListScreenState();
}

class _AdminListScreenState extends State<AdminListScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _clientsFuture;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _clientsFuture = DatabaseHelper.instance.getAllClients();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _clientsFuture = DatabaseHelper.instance.getAllClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: AppTheme.glassMorphism(borderRadius: 12, opacity: 0.1),
            child:
                const Icon(Icons.logout_rounded, size: 18),
          ),
          onPressed: () {
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
                      Navigator.pop(context); // close dialog
                      Navigator.pop(context); // pop back to login overlay
                    },
                    child: const Text('Logout',
                        style: TextStyle(color: AppTheme.error)),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration:
                  AppTheme.glassMorphism(borderRadius: 12, opacity: 0.1),
              child: const Icon(Icons.refresh_rounded, size: 20),
            ),
            onPressed: _refresh,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _clientsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentCyan),
                );
              }

              final clients = snapshot.data ?? [];

              if (clients.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header stats ──
                  _buildStatsRow(clients.length),
                  const SizedBox(height: 8),
                  // ── Client list ──
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        return _buildClientCard(client, index);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Stats row ───────────────────────────────────────────────────────────
  Widget _buildStatsRow(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: AppTheme.glassMorphism(opacity: 0.08),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.accentGradient.createShader(bounds),
              child: const Icon(Icons.group_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'Registered Users',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Client card ─────────────────────────────────────────────────────────
  Widget _buildClientCard(Map<String, dynamic> client, int index) {
    final delay = index * 0.1;
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(
        delay.clamp(0.0, 0.9),
        (delay + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    final profilePath = client['profile_pic_path'] as String? ?? '';
    final hasImage = profilePath.isNotEmpty && File(profilePath).existsSync();

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  reverseTransitionDuration: const Duration(milliseconds: 350),
                  pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
                    opacity: animation,
                    child:
                        AdminUserDetailScreen(clientId: client['id'] as int),
                  ),
                ),
              );
              _refresh();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassMorphism(opacity: 0.08),
              child: Row(
                children: [
                  // Avatar
                  Hero(
                    tag: 'avatar_${client['id']}',
                    child: Container(
                      width: 56,
                      height: 56,
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
                            color:
                                AppTheme.accentPurple.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name & goal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client['name'] as String? ?? 'Unknown',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client['goal'] as String? ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.accentGradient.createShader(bounds),
                    child: const Icon(Icons.chevron_right_rounded,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.accentGradient.createShader(bounds),
            child: const Icon(Icons.people_outline_rounded,
                size: 72, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'No users yet',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Users will appear here after they register.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
