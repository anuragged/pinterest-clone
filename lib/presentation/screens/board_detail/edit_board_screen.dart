import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/haptics.dart';
import '../../../domain/entities/board.dart';
import '../../providers/board_provider.dart';

/// "Edit board" screen — Figma Section 3: Bookmark & Collections
/// Allows changing board name, description, covers, visibility, and deletion.
class EditBoardScreen extends ConsumerStatefulWidget {
  final Board board;

  const EditBoardScreen({
    super.key,
    required this.board,
  });

  @override
  ConsumerState<EditBoardScreen> createState() => _EditBoardScreenState();
}

class _EditBoardScreenState extends ConsumerState<EditBoardScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late bool _isSecret;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.board.name);
    _descController = TextEditingController(text: widget.board.description ?? '');
    _isSecret = widget.board.isSecret;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.white : PinColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          'Edit board',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : PinColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveBoard,
            child: Text(
              'Done',
              style: TextStyle(
                color: isDark ? Colors.white : PinColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PinDimensions.paddingXXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover images preview
            _buildCoverPreview(isDark),
            const SizedBox(height: 32),

            // Name field
            _buildField(
              label: 'Board name',
              controller: _nameController,
              hint: 'e.g. Dream Home',
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Description field
            _buildField(
              label: 'Description',
              controller: _descController,
              hint: 'What\'s this board about?',
              isDark: isDark,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Settings Section
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white54 : PinColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Secret toggle
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Personalization',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : PinColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'Show recommendations based on this board',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : PinColors.textSecondary,
                ),
              ),
              trailing: Switch.adaptive(
                value: true,
                activeColor: PinColors.pinterestRed,
                onChanged: (v) {},
              ),
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Keep this board secret',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : PinColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'Only you and collaborators can see it',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : PinColors.textSecondary,
                ),
              ),
              trailing: Switch.adaptive(
                value: _isSecret,
                activeColor: PinColors.pinterestRed,
                onChanged: (v) => setState(() => _isSecret = v),
              ),
            ),

            const SizedBox(height: 40),

            // Delete action
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _deleteBoard,
                style: TextButton.styleFrom(
                  backgroundColor: isDark ? Colors.white10 : PinColors.backgroundWash,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Delete board',
                  style: TextStyle(
                    color: PinColors.pinterestRed,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPreview(bool isDark) {
    final images = widget.board.coverImageUrls;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF333333) : PinColors.backgroundWash,
              borderRadius: BorderRadius.circular(20),
            ),
            child: images.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(images.first, fit: BoxFit.cover),
                )
                : Icon(Icons.dashboard_outlined, size: 40, color: isDark ? Colors.white24 : Colors.grey[300]),
          ),
          Positioned(
            bottom: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF444444) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Change cover',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : PinColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : PinColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : PinColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white24 : PinColors.textSecondary.withValues(alpha: 0.5),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isDark ? Colors.white12 : PinColors.borderDefault),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: PinColors.pinterestRed, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _saveBoard() {
    Haptics.medium();
    final updatedBoard = widget.board.copyWith(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      isSecret: _isSecret,
      updatedAt: DateTime.now(),
    );
    ref.read(boardProvider.notifier).updateBoard(updatedBoard);
    Navigator.pop(context);
  }

  void _deleteBoard() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete board?'),
        content: const Text('This will permanently delete the board and all its pins. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(boardProvider.notifier).deleteBoard(widget.board.id);
              Navigator.pop(ctx); // Dialog
              Navigator.pop(context); // Edit Screen
              Navigator.pop(context); // Board Detail
            },
            child: const Text('Delete', style: TextStyle(color: PinColors.pinterestRed)),
          ),
        ],
      ),
    );
  }
}
