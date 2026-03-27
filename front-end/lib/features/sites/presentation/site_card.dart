import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'sites/site.dart';

class SiteCard extends StatefulWidget {
  final Site site;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const SiteCard({
    super.key,
    required this.site,
    this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  State<SiteCard> createState() => _SiteCardState();
}

class _SiteCardState extends State<SiteCard> {
  late final PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant SiteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.site.id != widget.site.id) {
      _currentImageIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.site;
    final freshnessColor = AppColors.getMarkerColor(site.freshnessScore);
    final badges = _buildBadges(site);
    final imageUrls = _imageUrlsFor(site);
    final locationLabel = [
      if (site.city.isNotEmpty) site.city,
      if (site.region.isNotEmpty) site.region,
    ].join(', ');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    child: SizedBox(
                      height: 240,
                      width: double.infinity,
                      child: imageUrls.isNotEmpty
                          ? PageView.builder(
                              controller: _pageController,
                              itemCount: imageUrls.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Image.network(
                                  imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholderImage();
                                  },
                                );
                              },
                            )
                          : _buildPlaceholderImage(),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.10),
                            Colors.black.withValues(alpha: 0.50),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        site.subcategory ?? site.category,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryDeep,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _FavoriteButton(
                          isFavorite: widget.isFavorite,
                          onTap: widget.onToggleFavorite,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: freshnessColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${site.freshnessScore}% fiable',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    locationLabel.isEmpty
                                        ? 'Maroc'
                                        : locationLabel,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.favorite_outline_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${site.favoritesCount + (widget.isFavorite ? 1 : 0)}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (imageUrls.length > 1) ...[
                          const SizedBox(height: 12),
                          _PhotoDots(
                            count: imageUrls.length,
                            currentIndex: _currentImageIndex,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            site.name,
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: 22,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppColors.accentGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                site.rating.toStringAsFixed(1),
                                style: AppTextStyles.bodyStrong.copyWith(
                                  color: AppColors.primaryDeep,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _RatingDots(rating: site.rating),
                        if (site.hasDistance)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F3FF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.near_me_outlined,
                                  size: 14,
                                  color: AppColors.primaryDeep,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  site.formattedDistance,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primaryDeep,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          site.totalReviews > 0
                              ? '${site.totalReviews} avis voyageurs'
                              : 'Selection voyage',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      site.description.isEmpty
                          ? 'Une adresse a garder dans votre itineraire, avec une fiche claire et rapide a consulter.'
                          : site.description,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: badges
                            .map((badge) => _SiteBadgeChip(badge: badge))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoPill(
                          icon: Icons.category_outlined,
                          label: site.category,
                        ),
                        _InfoPill(
                          icon: site.totalReviews > 0
                              ? Icons.rate_review_outlined
                              : Icons.verified_outlined,
                          label: site.totalReviews > 0
                              ? '${site.totalReviews} avis'
                              : _verificationLabel(site.verificationStatus),
                        ),
                        if (site.hasDistance)
                          _InfoPill(
                            icon: Icons.route_outlined,
                            label: site.formattedDistance,
                          ),
                        if (site.priceRange != null &&
                            site.priceRange!.isNotEmpty)
                          _InfoPill(
                            icon: Icons.payments_outlined,
                            label: _formatPriceRange(site.priceRange!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB8F2D9), Color(0xFFDCF9EC)],
        ),
      ),
      child: const Icon(
        Icons.travel_explore,
        size: 52,
        color: AppColors.primaryDeep,
      ),
    );
  }

  List<String> _imageUrlsFor(Site site) {
    final urls = <String>[
      ...site.previewPhotos,
      if (site.imageUrl.isNotEmpty) site.imageUrl,
    ];

    final uniqueUrls = <String>[];
    for (final url in urls) {
      if (!uniqueUrls.contains(url)) {
        uniqueUrls.add(url);
      }
    }

    return uniqueUrls;
  }

  List<_SiteBadgeData> _buildBadges(Site site) {
    final badges = <_SiteBadgeData>[];
    final seasonalBadge = _buildSeasonBadge(site);
    if (seasonalBadge != null) {
      badges.add(seasonalBadge);
    }

    final category = site.category.toLowerCase();
    final subcategory = (site.subcategory ?? '').toLowerCase();
    final amenityText = site.amenities
        .map((item) => item.toLowerCase())
        .join(' ');

    bool matches(List<String> keywords) {
      return keywords.any(
        (keyword) =>
            category.contains(keyword) ||
            subcategory.contains(keyword) ||
            amenityText.contains(keyword),
      );
    }

    void addBadge(_SiteBadgeData badge) {
      if (badges.any((item) => item.label == badge.label)) {
        return;
      }
      badges.add(badge);
    }

    if (matches(['beach', 'plage', 'corniche', 'front de mer'])) {
      addBadge(
        const _SiteBadgeData(
          label: 'plage',
          icon: Icons.waves_rounded,
          backgroundColor: Color(0xFFE0F2FE),
          foregroundColor: Color(0xFF075985),
        ),
      );
    }

    if (matches([
      'museum',
      'historical',
      'religious',
      'culture',
      'artisanat',
      'architecture',
      'medina',
      'site historique',
    ])) {
      addBadge(
        const _SiteBadgeData(
          label: 'culture',
          icon: Icons.museum_outlined,
          backgroundColor: Color(0xFFFFF1D6),
          foregroundColor: Color(0xFF8A5300),
        ),
      );
    }

    if (matches(['shopping', 'souk', 'souvenir', 'boutique', 'marina'])) {
      addBadge(
        const _SiteBadgeData(
          label: 'shopping',
          icon: Icons.shopping_bag_outlined,
          backgroundColor: Color(0xFFFCE7F3),
          foregroundColor: Color(0xFF9D174D),
        ),
      );
    }

    if (matches(['famille', 'family', 'parc']) ||
        category.contains('park') ||
        category.contains('hotel')) {
      addBadge(
        const _SiteBadgeData(
          label: 'famille',
          icon: Icons.family_restroom_outlined,
          backgroundColor: Color(0xFFE9F7EF),
          foregroundColor: Color(0xFF166534),
        ),
      );
    }

    if (category.contains('restaurant') ||
        category.contains('cafe') ||
        matches(['cuisine', 'dessert', 'restaurant', 'terrasse'])) {
      addBadge(
        const _SiteBadgeData(
          label: 'gourmand',
          icon: Icons.restaurant_outlined,
          backgroundColor: Color(0xFFFFEDD5),
          foregroundColor: Color(0xFF9A3412),
        ),
      );
    }

    if (matches(['couple', 'vue marina', 'coucher de soleil', 'spa'])) {
      addBadge(
        const _SiteBadgeData(
          label: 'romantique',
          icon: Icons.nightlight_round,
          backgroundColor: Color(0xFFFFE4E6),
          foregroundColor: Color(0xFFBE123C),
        ),
      );
    }

    if (category.contains('hotel') || matches(['spa', 'thalasso', 'sejour'])) {
      addBadge(
        const _SiteBadgeData(
          label: 'sejour',
          icon: Icons.hotel_outlined,
          backgroundColor: Color(0xFFEDE9FE),
          foregroundColor: Color(0xFF5B21B6),
        ),
      );
    }

    if (site.priceRange == 'LUXURY' || site.priceRange == 'EXPENSIVE') {
      addBadge(
        const _SiteBadgeData(
          label: 'luxe',
          icon: Icons.diamond_outlined,
          backgroundColor: Color(0xFFFFF7D6),
          foregroundColor: Color(0xFF946200),
        ),
      );
    }

    if (category.contains('park') || matches(['jardin', 'nature', 'detente'])) {
      addBadge(
        const _SiteBadgeData(
          label: 'nature',
          icon: Icons.park_outlined,
          backgroundColor: Color(0xFFECFCCB),
          foregroundColor: Color(0xFF3F6212),
        ),
      );
    }

    if (category.contains('entertainment') ||
        matches(['concert', 'festival', 'plein air', 'cabines'])) {
      addBadge(
        const _SiteBadgeData(
          label: 'sortie',
          icon: Icons.celebration_outlined,
          backgroundColor: Color(0xFFFFE4E6),
          foregroundColor: Color(0xFF9F1239),
        ),
      );
    }

    if (site.isAccessible) {
      addBadge(
        const _SiteBadgeData(
          label: 'accessible',
          icon: Icons.accessible_forward_rounded,
          backgroundColor: Color(0xFFE0F2F1),
          foregroundColor: Color(0xFF115E59),
        ),
      );
    }

    return badges.take(5).toList();
  }

  _SiteBadgeData? _buildSeasonBadge(Site site) {
    final category = site.category.toLowerCase();
    final amenities = site.amenities
        .map((item) => item.toLowerCase())
        .join(' ');
    final month = DateTime.now().month;

    if (month >= 3 && month <= 5) {
      if (category.contains('park') || amenities.contains('jardin')) {
        return const _SiteBadgeData(
          label: 'printemps doux',
          icon: Icons.local_florist_outlined,
          backgroundColor: Color(0xFFF0FDF4),
          foregroundColor: Color(0xFF166534),
        );
      }

      return const _SiteBadgeData(
        label: 'printemps balade',
        icon: Icons.wb_sunny_outlined,
        backgroundColor: Color(0xFFF7FEE7),
        foregroundColor: Color(0xFF4D7C0F),
      );
    }

    if (month >= 6 && month <= 8) {
      if (category.contains('beach') || amenities.contains('plage')) {
        return const _SiteBadgeData(
          label: 'ete plage',
          icon: Icons.beach_access_outlined,
          backgroundColor: Color(0xFFE0F2FE),
          foregroundColor: Color(0xFF0369A1),
        );
      }

      return const _SiteBadgeData(
        label: 'soiree d ete',
        icon: Icons.wb_twilight_outlined,
        backgroundColor: Color(0xFFFFEDD5),
        foregroundColor: Color(0xFF9A3412),
      );
    }

    if (month >= 9 && month <= 11) {
      if (category.contains('museum') ||
          category.contains('historical') ||
          amenities.contains('culture')) {
        return const _SiteBadgeData(
          label: 'automne culture',
          icon: Icons.auto_stories_outlined,
          backgroundColor: Color(0xFFFFF1D6),
          foregroundColor: Color(0xFF92400E),
        );
      }

      return const _SiteBadgeData(
        label: 'automne doux',
        icon: Icons.landscape_outlined,
        backgroundColor: Color(0xFFFEF3C7),
        foregroundColor: Color(0xFF92400E),
      );
    }

    return const _SiteBadgeData(
      label: 'hiver lumineux',
      icon: Icons.nights_stay_outlined,
      backgroundColor: Color(0xFFE0E7FF),
      foregroundColor: Color(0xFF3730A3),
    );
  }

  String _verificationLabel(String status) {
    switch (status.toUpperCase()) {
      case 'VERIFIED':
        return 'Verifie';
      case 'REJECTED':
        return 'A revoir';
      default:
        return 'A decouvrir';
    }
  }

  String _formatPriceRange(String value) {
    switch (value.toUpperCase()) {
      case 'BUDGET':
        return 'Petit budget';
      case 'MODERATE':
        return 'Confort';
      case 'EXPENSIVE':
        return 'Premium';
      case 'LUXURY':
        return 'Luxe';
      default:
        return value;
    }
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 20,
            color: isFavorite ? const Color(0xFFBE123C) : AppColors.primaryDeep,
          ),
        ),
      ),
    );
  }
}

class _PhotoDots extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PhotoDots({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
          width: isActive ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _RatingDots extends StatelessWidget {
  final double rating;

  const _RatingDots({required this.rating});

  @override
  Widget build(BuildContext context) {
    final fullDots = rating.clamp(0, 5).floor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < fullDots;
        return Padding(
          padding: EdgeInsets.only(right: index == 4 ? 0 : 4),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: filled ? AppColors.primary : AppColors.border,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primaryDeep),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _SiteBadgeData {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _SiteBadgeData({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

class _SiteBadgeChip extends StatelessWidget {
  final _SiteBadgeData badge;

  const _SiteBadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: badge.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badge.icon, size: 14, color: badge.foregroundColor),
          const SizedBox(width: 6),
          Text(
            badge.label,
            style: AppTextStyles.caption.copyWith(
              color: badge.foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
