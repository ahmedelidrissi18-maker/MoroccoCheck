import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/site_category.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../sites/presentation/sites/site.dart';
import '../../sites/presentation/sites_provider.dart';
import 'map_provider.dart';

enum _FreshnessFilter { all, fresh, moderate, stale }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _defaultCenter = LatLng(
    AppConstants.focusLatitude,
    AppConstants.focusLongitude,
  );
  final MapController _mapController = MapController();

  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  String? _selectedLegacySubcategory;
  _FreshnessFilter _freshnessFilter = _FreshnessFilter.all;
  Site? _selectedSite;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mapProvider = context.read<MapProvider>();
      final sitesProvider = context.read<SitesProvider>();

      await mapProvider.getUserLocation();
      final position = mapProvider.currentPosition;
      await sitesProvider.getSites(
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
    });
  }

  Color _markerColorForScore(int score) {
    if (score >= 70) return AppColors.freshnessGreen;
    if (score >= 40) return AppColors.freshnessOrange;
    return AppColors.freshnessRed;
  }

  List<Site> _visibleSites(List<Site> sites) {
    return sites.where((site) {
      final matchesCategory =
          _selectedCategoryId == null || site.categoryId == _selectedCategoryId;
      final matchesSubcategory =
          (_selectedSubcategoryId == null &&
              (_selectedLegacySubcategory == null ||
                  _selectedLegacySubcategory!.isEmpty)) ||
          (_selectedSubcategoryId != null &&
              site.subcategoryId == _selectedSubcategoryId) ||
          (_selectedSubcategoryId == null &&
              _selectedLegacySubcategory != null &&
              (site.subcategory ?? '').toLowerCase() ==
                  _selectedLegacySubcategory!.toLowerCase());

      final matchesFreshness = switch (_freshnessFilter) {
        _FreshnessFilter.all => true,
        _FreshnessFilter.fresh => site.freshnessScore >= 70,
        _FreshnessFilter.moderate =>
          site.freshnessScore >= 40 && site.freshnessScore < 70,
        _FreshnessFilter.stale => site.freshnessScore < 40,
      };

      return matchesCategory && matchesFreshness && matchesSubcategory;
    }).toList();
  }

  List<Marker> _buildMarkers(MapProvider mapProvider, List<Site> sites) {
    final List<Marker> markers = sites.map((site) {
      final isSelected = _selectedSite?.id == site.id;
      return Marker(
        point: LatLng(site.latitude, site.longitude),
        width: isSelected ? 92 : 74,
        height: isSelected ? 98 : 82,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedSite = site;
            });
          },
          child: _MapSiteMarker(
            color: _markerColorForScore(site.freshnessScore),
            score: site.freshnessScore,
            isSelected: isSelected,
          ),
        ),
      );
    }).toList();

    if (mapProvider.currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(
            mapProvider.currentPosition!.latitude,
            mapProvider.currentPosition!.longitude,
          ),
          width: 52,
          height: 52,
          child: const _CurrentLocationMarker(),
        ),
      );
    }

    return markers;
  }

  Future<void> _openSiteDetails(Site site) async {
    await context.push('/sites/${site.id}');
  }

  void _clearSelectedSite() {
    if (_selectedSite == null) return;
    setState(() {
      _selectedSite = null;
    });
  }

  void _centerOnSite(Site site) {
    _mapController.move(LatLng(site.latitude, site.longitude), 15.2);
    setState(() {
      _selectedSite = site;
    });
  }

  Future<void> _centerOnUserLocation() async {
    final mapProvider = context.read<MapProvider>();

    await mapProvider.getUserLocation();
    if (!mounted) return;

    final position = mapProvider.currentPosition;
    if (position != null) {
      _mapController.move(LatLng(position.latitude, position.longitude), 15);
      await context.read<SitesProvider>().getSites(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedSubcategoryId = null;
      _selectedLegacySubcategory = null;
      _freshnessFilter = _FreshnessFilter.all;
      _selectedSite = null;
    });
  }

  int get _activeFilterCount {
    var count = 0;
    if (_selectedCategoryId != null) count++;
    if (_selectedSubcategoryId != null ||
        (_selectedLegacySubcategory != null &&
            _selectedLegacySubcategory!.isNotEmpty)) {
      count++;
    }
    if (_freshnessFilter != _FreshnessFilter.all) count++;
    return count;
  }

  Future<void> _openFiltersSheet(SitesProvider sitesProvider) async {
    final colorScheme = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void refreshFilters(VoidCallback update) {
              setState(update);
              setSheetState(() {});
            }

            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.72,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: _buildFilterSheetContent(
                    sitesProvider,
                    refreshFilters,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapProvider, SitesProvider>(
      builder: (context, mapProvider, sitesProvider, child) {
        final currentPosition = mapProvider.currentPosition;
        final center = currentPosition != null
            ? LatLng(currentPosition.latitude, currentPosition.longitude)
            : _defaultCenter;
        final visibleSites = _visibleSites(sitesProvider.sites);
        final selectedSite = _selectedSite != null &&
                visibleSites.any((site) => site.id == _selectedSite!.id)
            ? _selectedSite
            : null;

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: currentPosition != null ? 13 : 11.5,
                  onTap: (_, point) => _clearSelectedSite(),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.mor_che_frontend',
                  ),
                  MarkerLayer(
                    markers: _buildMarkers(mapProvider, visibleSites),
                  ),
                ],
              ),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryDeep.withValues(alpha: 0.18),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.12),
                      ],
                      stops: const [0, 0.18, 0.7, 1],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopPanel(visibleSites.length, sitesProvider.sites.length),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildFloatingActionChip(
                            icon: Icons.tune,
                            label: _activeFilterCount > 0
                                ? 'Filtres ($_activeFilterCount)'
                                : 'Filtres',
                            highlighted: true,
                            onTap: () => _openFiltersSheet(sitesProvider),
                          ),
                          const SizedBox(width: 10),
                          if (_activeFilterCount > 0)
                            Expanded(
                              child: _buildInfoChip(
                                icon: Icons.filter_alt_outlined,
                                label: _activeFilterCount == 1
                                    ? '1 filtre actif'
                                    : '$_activeFilterCount filtres actifs',
                              ),
                            )
                          else
                            Expanded(
                              child: _buildInfoChip(
                                icon: Icons.place_outlined,
                                label: visibleSites.isEmpty
                                    ? 'Aucun site visible'
                                    : '${visibleSites.length} lieux visibles',
                              ),
                            ),
                        ],
                      ),
                      if (mapProvider.isLoading || sitesProvider.isLoading) ...[
                        const SizedBox(height: 12),
                        _buildLoadingPill(),
                      ],
                      if (mapProvider.error != null || sitesProvider.error != null) ...[
                        const SizedBox(height: 12),
                        _buildErrorBanner(mapProvider, sitesProvider),
                      ],
                      const Spacer(),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedSite != null) ...[
                            _buildSelectedSiteCard(selectedSite),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: _buildSummaryBar(
                                  visibleSites,
                                  sitesProvider.sites.length,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildLocationButton(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopPanel(int visibleCount, int totalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explorer la carte',
                  style: AppTextStyles.heading2.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 6),
                Text(
                  visibleCount == totalCount
                      ? '$totalCount lieux visibles autour d Agadir'
                      : '$visibleCount lieux affiches sur $totalCount',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildIconShell(
            icon: Icons.restart_alt,
            onTap: _resetFilters,
            tooltip: 'Reinitialiser les filtres',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSheetContent(
    SitesProvider sitesProvider,
    void Function(VoidCallback update) refreshFilters,
  ) {
    final subcategoryOptions = sitesProvider.getSubcategoryOptionsFor(
      _selectedCategoryId,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tune, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Filtres de voyage', style: AppTextStyles.bodyStrong),
            ),
            if (_activeFilterCount > 0)
              TextButton(
                onPressed: () => refreshFilters(_resetFilters),
                child: const Text('Effacer'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCategoryChip('Toutes', _selectedCategoryId == null, () {
              refreshFilters(() {
                _selectedCategoryId = null;
                _selectedSubcategoryId = null;
                _selectedLegacySubcategory = null;
              });
            }),
            ...sitesProvider.topLevelCategories.map(
              (SiteCategory category) => _buildCategoryChip(
                category.name,
                _selectedCategoryId == category.id,
                () {
                  refreshFilters(() {
                    _selectedCategoryId = category.id;
                    _selectedSubcategoryId = null;
                    _selectedLegacySubcategory = null;
                  });
                },
              ),
            ),
          ],
        ),
        if (_selectedCategoryId != null && subcategoryOptions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Sous-categories',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip(
                'Toutes sous-categories',
                _selectedSubcategoryId == null &&
                    (_selectedLegacySubcategory == null ||
                        _selectedLegacySubcategory!.isEmpty),
                () {
                  refreshFilters(() {
                    _selectedSubcategoryId = null;
                    _selectedLegacySubcategory = null;
                  });
                },
              ),
              ...subcategoryOptions.map(
                (SiteSubcategoryOption option) => _buildCategoryChip(
                  option.label,
                  option.id != null
                      ? _selectedSubcategoryId == option.id
                      : _selectedSubcategoryId == null &&
                            _selectedLegacySubcategory?.toLowerCase() ==
                                option.legacyValue?.toLowerCase(),
                  () {
                    refreshFilters(() {
                      _selectedSubcategoryId = option.id;
                      _selectedLegacySubcategory = option.legacyValue;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
        if (sitesProvider.availableCategories.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Categories backend indisponibles pour le moment.',
              style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
            ),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFreshnessChip(
              label: 'Tous',
              color: Colors.grey,
              selected: _freshnessFilter == _FreshnessFilter.all,
              onTap: () {
                refreshFilters(() {
                  _freshnessFilter = _FreshnessFilter.all;
                });
              },
            ),
            _buildFreshnessChip(
              label: 'Frais',
              color: AppColors.freshnessGreen,
              selected: _freshnessFilter == _FreshnessFilter.fresh,
              onTap: () {
                refreshFilters(() {
                  _freshnessFilter = _FreshnessFilter.fresh;
                });
              },
            ),
            _buildFreshnessChip(
              label: 'Moyen',
              color: AppColors.freshnessOrange,
              selected: _freshnessFilter == _FreshnessFilter.moderate,
              onTap: () {
                refreshFilters(() {
                  _freshnessFilter = _FreshnessFilter.moderate;
                });
              },
            ),
            _buildFreshnessChip(
              label: 'A verifier',
              color: AppColors.freshnessRed,
              selected: _freshnessFilter == _FreshnessFilter.stale,
              onTap: () {
                refreshFilters(() {
                  _freshnessFilter = _FreshnessFilter.stale;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primaryDeep,
      checkmarkColor: Colors.white,
      labelStyle: AppTextStyles.caption.copyWith(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryDeep : AppColors.border,
      ),
    );
  }

  Widget _buildFreshnessChip({
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar(List<Site> visibleSites, int totalSites) {
    final freshCount = visibleSites
        .where((site) => site.freshnessScore >= 70)
        .length;
    final moderateCount = visibleSites
        .where((site) => site.freshnessScore >= 40 && site.freshnessScore < 70)
        .length;
    final staleCount = visibleSites
        .where((site) => site.freshnessScore < 40)
        .length;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${visibleSites.length} site${visibleSites.length > 1 ? 's' : ''}',
            style: AppTextStyles.heading2.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            'Affiches sur $totalSites dans cette vue',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _legendPill(
                label: '$freshCount frais',
                color: AppColors.freshnessGreen,
              ),
              _legendPill(
                label: '$moderateCount moyens',
                color: AppColors.freshnessOrange,
              ),
              _legendPill(
                label: '$staleCount a verifier',
                color: AppColors.freshnessRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSiteCard(Site site) {
    final markerColor = _markerColorForScore(site.freshnessScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 92,
              height: 110,
              child: site.imageUrl.isNotEmpty
                  ? AppNetworkImage(
                      imageUrl: site.imageUrl,
                      fit: BoxFit.cover,
                      fallback: _SelectedSitePlaceholder(color: markerColor),
                    )
                  : _SelectedSitePlaceholder(color: markerColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _legendPill(
                      label: site.category,
                      color: AppColors.primary,
                    ),
                    _legendPill(
                      label: '${site.freshnessScore}% fiable',
                      color: markerColor,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  site.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    if (site.city.isNotEmpty) site.city,
                    if (site.subcategory?.isNotEmpty == true) site.subcategory!,
                  ].join(' - '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _openSiteDetails(site),
                        icon: const Icon(Icons.place_outlined, size: 18),
                        label: const Text('Voir la fiche'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildIconShell(
                      icon: Icons.my_location_outlined,
                      tooltip: 'Centrer sur ce lieu',
                      onTap: () => _centerOnSite(site),
                    ),
                    const SizedBox(width: 6),
                    _buildIconShell(
                      icon: Icons.close,
                      tooltip: 'Fermer',
                      onTap: _clearSelectedSite,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text('Mise a jour de la carte...', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(MapProvider mapProvider, SitesProvider sitesProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF8A2E12).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mapProvider.error ??
                  sitesProvider.error ??
                  'Une erreur est survenue.',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildIconShell(
            icon: Icons.close,
            iconColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.14),
            onTap: () {
              mapProvider.clearError();
              sitesProvider.clearError();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _centerOnUserLocation,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: highlighted
                ? AppColors.primary
                : AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: highlighted ? Colors.white : AppColors.primaryDeep,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: highlighted ? Colors.white : AppColors.primaryDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconShell({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.primaryDeep,
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendPill({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapSiteMarker extends StatelessWidget {
  final Color color;
  final int score;
  final bool isSelected;

  const _MapSiteMarker({
    required this.color,
    required this.score,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: isSelected ? 1.08 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryDeep,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                '$score%',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.16),
                  ),
                ),
              Container(
                width: isSelected ? 46 : 40,
                height: isSelected ? 46 : 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.place_rounded,
                  size: isSelected ? 30 : 26,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 18,
              spreadRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedSitePlaceholder extends StatelessWidget {
  final Color color;

  const _SelectedSitePlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.24),
            AppColors.surfaceAlt,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.place_outlined, color: color, size: 36),
    );
  }
}
