import 'package:flutter/material.dart';
import '../../domain/entities/font_entity.dart';

/// Panel showing detailed font information.
class FontDetailsPanel extends StatelessWidget {
  final FontEntity font;

  const FontDetailsPanel({super.key, required this.font});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Font Details',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'Family', value: font.family),
          _DetailRow(label: 'Style', value: font.style),
          _DetailRow(
            label: 'Weight',
            value: '${font.weightName} (${font.weight})',
          ),
          _DetailRow(label: 'Slant', value: font.slantName),
          _DetailRow(label: 'Category', value: font.category.displayName),
          _DetailRow(label: 'Format', value: font.fileExtension.toUpperCase()),
          _DetailRow(label: 'File', value: font.filePath, isPath: true),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPath;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isPath = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontFamily: isPath ? 'monospace' : null,
              ),
              maxLines: isPath ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
