import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/haptics.dart';
import '../../../domain/entities/board.dart';
import '../../../domain/entities/pin.dart';
import '../../providers/board_provider.dart';

/// "Select or reorder" pins screen — Figma Section 3: Bookmark & Collections
/// Allows multi-selecting pins to move or delete.
class SelectPinsScreen extends ConsumerStatefulWidget {
  final Board board;

  const SelectPinsScreen({
    super.key,
    required this.board,
  });

  @override
  ConsumerState<SelectPinsScreen> createState() => _SelectPinsScreenState();
}

class _SelectPinsScreenState extends ConsumerState<SelectPinsScreen> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.white : PinColors.textPrimary,
          ),
        ),
        title: Text(
          _selectedIds.isEmpty 
              ? 'Select Pins' 
              : '${_selectedIds.length} selected',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : PinColors.textPrimary,
          ),
        ),
        actions: [
          if (_selectedIds.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _selectedIds.clear());
              },
              child: const Text('Deselect all'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: widget.board.pinIds.length,
              itemBuilder: (context, index) {
                final pinId = widget.board.pinIds[index];
                final imageUrl = widget.board.coverImageUrls.length > index 
                    ? widget.board.coverImageUrls[index] 
                    : 'https://via.placeholder.com/150';
                final isSelected = _selectedIds.contains(pinId);

                return GestureDetector(
                  onTap: () {
                    Haptics.light();
                    setState(() {
                      if (isSelected) {
                        _selectedIds.remove(pinId);
                      } else {
                        _selectedIds.add(pinId);
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Opacity(
                            opacity: isSelected ? 0.6 : 1.0,
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: PinColors.pinterestRed,
                            child: Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                        )
                      else
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Bottom Actions
          if (_selectedIds.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.drive_file_move_outlined,
                    label: 'Move',
                    onTap: () {
                      Haptics.medium();
                      // Move logic
                    },
                    isDark: isDark,
                  ),
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    onTap: _deleteSelected,
                    isDark: isDark,
                    color: PinColors.pinterestRed,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: color ?? (isDark ? Colors.white : PinColors.textPrimary)),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color ?? (isDark ? Colors.white70 : PinColors.textSecondary),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _deleteSelected() {
    // Confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${_selectedIds.length} pins?'),
        content: const Text('This will remove these pins from the board. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // Delete logic
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: PinColors.pinterestRed)),
          ),
        ],
      ),
    );
  }
}
