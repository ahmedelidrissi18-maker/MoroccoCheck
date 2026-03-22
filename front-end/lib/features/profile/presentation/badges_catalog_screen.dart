import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/api_service.dart';
import 'models/badge_catalog_item.dart';

class BadgesCatalogScreen extends StatefulWidget {
  const BadgesCatalogScreen({super.key});

  @override
  State<BadgesCatalogScreen> createState() => _BadgesCatalogScreenState();
}

class _BadgesCatalogScreenState extends State<BadgesCatalogScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _error;
  List<BadgeCatalogItem> _badges = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBadges();
    });
  }

  Future<void> _loadBadges() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final badges = await _apiService.fetchBadgesCatalog();
      if (!mounted) return;

      setState(() {
        _badges = badges;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue des badges')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBadges,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debloquez vos prochains badges',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_badges.length} badges actifs disponibles dans cette version.',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _error!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    )
                  else if (_badges.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        'Aucun badge n est disponible pour le moment.',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ..._badges.map(_buildBadgeCard),
                ],
              ),
            ),
    );
  }

  Widget _buildBadgeCard(BadgeCatalogItem badge) {
    final rarityColor = _rarityColor(badge.rarity);
    final criteria = <String>[
      if (badge.requiredCheckins > 0) '${badge.requiredCheckins} check-ins',
      if (badge.requiredReviews > 0) '${badge.requiredReviews} avis',
      if (badge.requiredPoints > 0) '${badge.requiredPoints} points',
      if (badge.requiredLevel > 0) 'Niveau ${badge.requiredLevel}',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: rarityColor.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    color: rarityColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badge.name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.description,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _BadgePill(label: badge.rarity, color: rarityColor),
                _BadgePill(label: badge.category, color: AppColors.primary),
                _BadgePill(
                  label: '${badge.pointsReward} pts bonus',
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              criteria.isEmpty
                  ? 'Aucune condition detaillee exposee par le backend.'
                  : 'Conditions: ${criteria.join(' · ')}',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Attribue ${badge.totalAwarded} fois',
              style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'LEGENDARY':
        return Colors.deepOrange;
      case 'EPIC':
        return Colors.purple;
      case 'RARE':
        return Colors.indigo;
      case 'UNCOMMON':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

class _BadgePill extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
