import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/board_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/discovery_provider.dart';
import '../../../domain/entities/pin.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Create screen — matching Figma design.
/// Shows creation menu (Pin, Board, Idea Pin) with photo picker grid.
class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  bool _showPhotoGrid = false;

  // Placeholder list removed, will use discoveryState.creatorIdeas

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final discoveryState = ref.watch(discoveryProvider);
    if (_showPhotoGrid) {
      return _buildPhotoPickerScreen(isDark, discoveryState.creatorIdeas);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PinDimensions.paddingXXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white : PinColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Start creating now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : PinColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balance
                ],
              ),
              const SizedBox(height: 32),

              // Create Pin option
              _CreateOption(
                icon: Icons.push_pin_outlined,
                title: 'Pin',
                subtitle: 'Create a pin from a photo',
                onTap: () {
                  Haptics.light();
                  final auth = ref.read(authProvider);
                  if (!auth.isAuthenticated) {
                    _showAuthPrompt();
                  } else {
                    setState(() => _showPhotoGrid = true);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Create Board option
              _CreateOption(
                icon: Icons.dashboard_outlined,
                title: 'Board',
                subtitle: 'Organize your pins into collections',
                onTap: () {
                  Haptics.heavy();
                  final auth = ref.read(authProvider);
                  if (!auth.isAuthenticated) {
                    _showAuthPrompt();
                  } else {
                    _showCreateBoardDialog();
                  }
                },
              ),
              const SizedBox(height: 12),

              // Create Idea Pin option
              _CreateOption(
                icon: Icons.auto_awesome_outlined,
                title: 'Idea Pin',
                subtitle: 'Create a multi-page visual story',
                onTap: () {
                  Haptics.light();
                  final auth = ref.read(authProvider);
                  if (!auth.isAuthenticated) {
                    _showAuthPrompt();
                  } else {
                    setState(() => _showPhotoGrid = true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPickerScreen(bool isDark, List<Pin> photos) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => setState(() => _showPhotoGrid = false),
          icon: Icon(
            Icons.chevron_left,
            size: 32,
            color: isDark ? Colors.white : PinColors.textPrimary,
          ),
        ),
        title: Text(
          'All photos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : PinColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Next',
              style: TextStyle(
                color: PinColors.pinterestRed,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final pin = photos[index];
          return GestureDetector(
            onTap: () {
              Haptics.light();
              _showPinEditorSheet(pin);
            },
            child: CachedNetworkImage(
              imageUrl: pin.thumbnailUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: PinColors.shimmerBase,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPinEditorSheet(Pin pin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PinDimensions.cardRadiusLarge),
        ),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(PinDimensions.paddingXXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PinColors.borderDefault,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
 
                // Image preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: pin.imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),

                // Title field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Add a title',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : PinColors.textSecondary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : PinColors.textPrimary,
                  ),
                ),

                // Description field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tell everyone what your Pin is about',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : PinColors.textSecondary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : PinColors.textPrimary,
                  ),
                ),
                const Divider(),

                // Destination link
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.link,
                    color: isDark ? Colors.white : PinColors.iconDefault,
                  ),
                  title: Text(
                    'Destination link',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : PinColors.textSecondary,
                    ),
                  ),
                ),
                const Divider(),

                // Board selector
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.dashboard_outlined,
                    color: isDark ? Colors.white : PinColors.iconDefault,
                  ),
                  title: Text(
                    'Board',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : PinColors.textSecondary,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Choose',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : PinColors.textSecondary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: isDark ? Colors.white54 : PinColors.iconSecondary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Publish button
                SizedBox(
                  width: double.infinity,
                  height: PinDimensions.buttonHeightLarge,
                  child: ElevatedButton(
                    onPressed: () {
                      Haptics.heavy();
                      Navigator.pop(context);
                      setState(() => _showPhotoGrid = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Pin published!'),
                          backgroundColor: PinColors.textPrimary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PinColors.pinterestRed,
                      foregroundColor: PinColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PinDimensions.buttonRadius),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Publish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateBoardDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController();
    bool isSecret = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : PinColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PinDimensions.cardRadiusLarge),
          ),
          title: Text(
            'Create board',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : PinColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? Colors.white : PinColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Board name',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : PinColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: PinColors.borderDefault),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: PinColors.pinterestRed, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Keep this board secret',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : PinColors.textPrimary,
                    ),
                  ),
                  Switch.adaptive(
                    value: isSecret,
                    onChanged: (v) => setDialogState(() => isSecret = v),
                    activeTrackColor: PinColors.pinterestRed,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white54 : PinColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Haptics.heavy();
                  ref.read(boardProvider.notifier).createBoard(
                        name: name,
                        isSecret: isSecret,
                      );
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PinColors.pinterestRed,
                foregroundColor: PinColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuthPrompt() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : PinColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PinDimensions.cardRadiusLarge),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(PinDimensions.paddingXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: isDark ? Colors.white54 : PinColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to create',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : PinColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Log in to create pins and boards',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : PinColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: PinDimensions.buttonHeightLarge,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Sign in as guest for demo
                  ref.read(authProvider.notifier).signIn(
                        displayName: 'Guest User',
                        email: 'guest@example.com',
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PinColors.pinterestRed,
                  foregroundColor: PinColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(PinDimensions.buttonRadius),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF222222) : PinColors.backgroundWash,
      borderRadius: BorderRadius.circular(PinDimensions.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(PinDimensions.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(PinDimensions.paddingXL),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: PinColors.pinterestRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: PinColors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : PinColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : PinColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white54 : PinColors.iconSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
