import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final NeoItem item;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCover(),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfo(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: item.coverUrl.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: item.coverUrl,
        width: 80,
        height: 110,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 80,
          height: 110,
          color: Colors.grey[200],
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          return _buildPlaceholder();
        },
      )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 110,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          item.categoryIcon,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Chip(
          label: Text(
            item.categoryName,
            style: const TextStyle(fontSize: 11),
          ),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 4),
        Text(
          item.creatorsText,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.pubDate != null) ...[
          const SizedBox(height: 2),
          Text(
            item.pubDate!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: 6),
        if (item.rating > 0)
          Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 4),
              Text(
                item.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${item.ratingCount})',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
      ],
    );
  }
}