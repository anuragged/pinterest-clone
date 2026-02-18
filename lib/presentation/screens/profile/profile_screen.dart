import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Your account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // ── Profile Entry ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: InkWell(
              onTap: () => context.push('/profile/details'),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: PinColors.backgroundSecondary,
                    backgroundImage: authState.avatarUrl != null 
                        ? NetworkImage(authState.avatarUrl!) 
                        : null,
                    child: authState.avatarUrl == null 
                        ? const Icon(Icons.person, color: Colors.grey, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.displayName ?? 'Anurag',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'View profile',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Settings Subheader ──
          _buildSubHeader('Settings'),
          _buildListItem('Account management', onTap: () {}),
          _buildListItem('Profile visibility', onTap: () {}),
          _buildListItem('Refine your recommendations', onTap: () {
            context.push('/refine-recommendations');
          }),
          _buildListItem('Claimed external accounts', onTap: () {}),
          _buildListItem('Social permissions', onTap: () {}),
          _buildListItem('Notifications', onTap: () {}),
          _buildListItem('Privacy and data', onTap: () {}),
          _buildListItem('Reports and violations centre', onTap: () {}),

          const SizedBox(height: 20),

          // ── Login ──
          _buildSubHeader('Login'),
          _buildListItem('Add account', onTap: () {}),
          _buildListItem('Security', onTap: () {}),
          
          _buildSimpleItem('Log out', onTap: () {
            ref.read(authProvider.notifier).signOut();
            context.go('/welcome');
          }),

          const SizedBox(height: 20),

          // ── Support ──
          _buildSubHeader('Support'),
          _buildListItem('Help Centre', onTap: () {}),
          _buildListItem('Terms of Service', onTap: () {}),
          _buildListItem('Privacy Policy', onTap: () {}),
          _buildListItem('About', onTap: () {}),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSubHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildListItem(String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        Haptics.light();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleItem(String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        Haptics.light();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
