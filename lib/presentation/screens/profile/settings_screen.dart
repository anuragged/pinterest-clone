import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Your account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Options'),
          _buildSettingItem(
            'Account management',
            onTap: () {},
          ),
          _buildSettingItem(
            'Profile visibility',
            onTap: () {},
          ),
          _buildSettingItem(
            'Theme',
            trailing: Text(
              themeMode == ThemeMode.dark ? 'Dark' : 'Light',
              style: TextStyle(
                color: PinColors.textSecondary,
                fontSize: 14,
              ),
            ),
            onTap: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          _buildSettingItem(
            'Privacy and data',
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader('Login'),
          _buildSettingItem(
            'Add account',
            onTap: () {},
          ),
          _buildSettingItem(
            'Security',
            onTap: () {},
          ),
          _buildSettingItem(
            'Log out',
            onTap: () {},
            showChevron: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: PinColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title, {
    Widget? trailing,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing,
          if (showChevron) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: PinColors.iconSecondary, size: 20),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
