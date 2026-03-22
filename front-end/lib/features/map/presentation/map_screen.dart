import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/site_category.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mapProvider = context.read<MapProvider>();
      final sitesProvider = context.read<SitesProvider>();

      await mapProvider.getUserLocation();
      await sitesProvider.getSites();
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
      return Marker(
        point: LatLng(site.latitude, site.longitude),
        width: 46,
        height: 46,
        child: GestureDetector(
          onTap: () => context.push('/site/${site.id}'),
          child: Icon(
            Icons.location_on,
            size: 42,
            color: _markerColorForScore(site.freshnessScore),
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
          width: 46,
          height: 46,
          child: const Icon(
            Icons.my_location,
            size: 32,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return markers;
  }

  Future<void> _centerOnUserLocation() async {
    final mapProvider = context.read<MapProvider>();

    await mapProvider.getUserLocation();
    if (!mounted) return;

    final position = mapProvider.currentPosition;
    if (position != null) {
      _mapController.move(LatLng(position.latitude, position.longitude), 15);
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedSubcategoryId = null;
      _selectedLegacySubcategory = null;
      _freshnessFilter = _FreshnessFilter.all;
    });
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Explorer la carte'),
            actions: [
              IconButton(
                icon: const Icon(Icons.restart_alt),
                onPressed: _resetFilters,
                tooltip: 'Reinitialiser les filtres',
              ),
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _centerOnUserLocation,
                tooltip: 'Centrer sur ma position',
              ),
            ],
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: currentPosition != null ? 13 : 11.5,
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
              _buildFilterPanel(sitesProvider),
              if (mapProvider.isLoading || sitesProvider.isLoading)
                const Positioned(
                  top: 180,
                  left: 12,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Chargement...', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ),
                ),
              if (mapProvider.error != null || sitesProvider.error != null)
                Positioned(
                  top: 230,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
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
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: () {
                            mapProvider.clearError();
                            sitesProvider.clearError();
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                right: 82,
                bottom: 20,
                child: _buildSummaryBar(
                  visibleSites,
                  sitesProvider.sites.length,
                ),
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  onPressed: _centerOnUserLocation,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterPanel(SitesProvider sitesProvider) {
    final subcategoryOptions = sitesProvider.getSubcategoryOptionsFor(
      _selectedCategoryId,
    );

    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Card(
        margin: EdgeInsets.zero,
        color: AppColors.surface.withValues(alpha: 0.96),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Filtres de voyage', style: AppTextStyles.bodyStrong),
                  const Spacer(),
                  if (_selectedCategoryId != null ||
                      _selectedSubcategoryId != null ||
                      (_selectedLegacySubcategory != null &&
                          _selectedLegacySubcategory!.isNotEmpty) ||
                      _freshnessFilter != _FreshnessFilter.all)
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Effacer'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip(
                      'Toutes',
                      _selectedCategoryId == null,
                      () {
                        setState(() {
                          _selectedCategoryId = null;
                          _selectedSubcategoryId = null;
                          _selectedLegacySubcategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...sitesProvider.topLevelCategories.map(
                      (SiteCategory category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildCategoryChip(
                          category.name,
                          _selectedCategoryId == category.id,
                          () {
                            setState(() {
                              _selectedCategoryId = category.id;
                              _selectedSubcategoryId = null;
                              _selectedLegacySubcategory = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedCategoryId != null && subcategoryOptions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip(
                          'Toutes sous-categories',
                          _selectedSubcategoryId == null &&
                              (_selectedLegacySubcategory == null ||
                                  _selectedLegacySubcategory!.isEmpty),
                          () {
                            setState(() {
                              _selectedSubcategoryId = null;
                              _selectedLegacySubcategory = null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ...subcategoryOptions.map(
                          (SiteSubcategoryOption option) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCategoryChip(
                              option.label,
                              option.id != null
                                  ? _selectedSubcategoryId == option.id
                                  : _selectedSubcategoryId == null &&
                                        _selectedLegacySubcategory
                                                ?.toLowerCase() ==
                                            option.legacyValue?.toLowerCase(),
                              () {
                                setState(() {
                                  _selectedSubcategoryId = option.id;
                                  _selectedLegacySubcategory =
                                      option.legacyValue;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (sitesProvider.availableCategories.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Categories backend indisponibles pour le moment.',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey[600],
                    ),
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
                      setState(() {
                        _freshnessFilter = _FreshnessFilter.all;
                      });
                    },
                  ),
                  _buildFreshnessChip(
                    label: 'Frais',
                    color: AppColors.freshnessGreen,
                    selected: _freshnessFilter == _FreshnessFilter.fresh,
                    onTap: () {
                      setState(() {
                        _freshnessFilter = _FreshnessFilter.fresh;
                      });
                    },
                  ),
                  _buildFreshnessChip(
                    label: 'Moyen',
                    color: AppColors.freshnessOrange,
                    selected: _freshnessFilter == _FreshnessFilter.moderate,
                    onTap: () {
                      setState(() {
                        _freshnessFilter = _FreshnessFilter.moderate;
                      });
                    },
                  ),
                  _buildFreshnessChip(
                    label: 'A verifier',
                    color: AppColors.freshnessRed,
                    selected: _freshnessFilter == _FreshnessFilter.stale,
                    onTap: () {
                      setState(() {
                        _freshnessFilter = _FreshnessFilter.stale;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface.withValues(alpha: 0.96),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${visibleSites.length} site${visibleSites.length > 1 ? 's' : ''} affiche${visibleSites.length > 1 ? 's' : ''} sur $totalSites',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
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
