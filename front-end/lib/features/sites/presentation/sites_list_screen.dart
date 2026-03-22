import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/site_category.dart';
import 'site_card.dart';
import 'sites_provider.dart';

class SitesListScreen extends StatefulWidget {
  const SitesListScreen({super.key});

  @override
  State<SitesListScreen> createState() => _SitesListScreenState();
}

class _SitesListScreenState extends State<SitesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SitesProvider>().getSites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<SitesProvider>().searchSites(query);
    setState(() {});
  }

  void _onCategorySelected(int? categoryId) {
    context.read<SitesProvider>().filterByCategory(categoryId);
  }

  void _onSubcategorySelected({int? subcategoryId, String? subcategory}) {
    context.read<SitesProvider>().filterBySubcategory(
      subcategoryId: subcategoryId,
      subcategory: subcategory,
    );
  }

  void _onSiteTap(String siteId) {
    context.push('/sites/$siteId');
  }

  Future<void> _refreshSites() async {
    await context.read<SitesProvider>().getSites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorer')),
      body: Consumer<SitesProvider>(
        builder: (context, sitesProvider, child) {
          if (sitesProvider.isLoading && sitesProvider.sites.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sitesProvider.error != null && sitesProvider.sites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      sitesProvider.error!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _refreshSites,
                      child: const Text('Reessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshSites,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                _buildHeroCard(sitesProvider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText:
                            'Rechercher une adresse, une ambiance, une ville...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primaryDeep,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Text(
                    'Categories populaires',
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: 54,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCategoryChip(
                        label: 'Tous',
                        isSelected: sitesProvider.selectedCategoryId == null,
                        onTap: () => _onCategorySelected(null),
                      ),
                      const SizedBox(width: 8),
                      ...sitesProvider.topLevelCategories.map(
                        (SiteCategory category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(
                            label: category.name,
                            isSelected:
                                sitesProvider.selectedCategoryId == category.id,
                            onTap: () => _onCategorySelected(category.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (sitesProvider.availableCategories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(
                      'Les categories backend ne sont pas disponibles pour le moment.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                if (sitesProvider.selectedCategoryId != null &&
                    sitesProvider.availableSubcategoryOptions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: SizedBox(
                      height: 54,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryChip(
                            label: 'Toutes sous-categories',
                            isSelected:
                                sitesProvider.selectedSubcategoryId == null &&
                                (sitesProvider.selectedSubcategory == null ||
                                    sitesProvider.selectedSubcategory!.isEmpty),
                            onTap: () =>
                                _onSubcategorySelected(subcategoryId: null),
                          ),
                          const SizedBox(width: 8),
                          ...sitesProvider.availableSubcategoryOptions.map(
                            (SiteSubcategoryOption option) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildCategoryChip(
                                label: option.label,
                                isSelected: option.id != null
                                    ? sitesProvider.selectedSubcategoryId ==
                                          option.id
                                    : sitesProvider.selectedSubcategoryId ==
                                              null &&
                                          sitesProvider.selectedSubcategory
                                                  ?.toLowerCase() ==
                                              option.legacyValue?.toLowerCase(),
                                onTap: () => _onSubcategorySelected(
                                  subcategoryId: option.id,
                                  subcategory: option.legacyValue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  child: Row(
                    children: [
                      Text(
                        '${sitesProvider.filteredSites.length} resultat${sitesProvider.filteredSites.length > 1 ? 's' : ''}',
                        style: AppTextStyles.bodyStrong.copyWith(fontSize: 18),
                      ),
                      const Spacer(),
                      if (sitesProvider.searchQuery.isNotEmpty ||
                          sitesProvider.selectedCategoryId != null ||
                          sitesProvider.selectedSubcategoryId != null ||
                          (sitesProvider.selectedSubcategory != null &&
                              sitesProvider.selectedSubcategory!.isNotEmpty))
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            sitesProvider.clearFilters();
                            setState(() {});
                          },
                          icon: const Icon(Icons.restart_alt, size: 18),
                          label: const Text('Reinitialiser'),
                        ),
                    ],
                  ),
                ),
                if (sitesProvider.filteredSites.isEmpty)
                  _buildEmptyState()
                else
                  ...sitesProvider.filteredSites.map(
                    (site) =>
                        SiteCard(site: site, onTap: () => _onSiteTap(site.id)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(SitesProvider sitesProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1F1F), Color(0xFF0D3B2A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.travel_explore,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Les adresses qui valent le detour a ${sitesProvider.primaryLocationLabel}',
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Parcourez les lieux verifies, filtrez comme dans une app de voyage et gardez sous la main les spots les mieux notes.',
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _summaryPill(
                icon: Icons.layers_outlined,
                label: '${sitesProvider.categories.length} categories',
              ),
              _summaryPill(
                icon: Icons.verified_outlined,
                label: '${sitesProvider.sites.length} lieux recommandes',
              ),
              _summaryPill(
                icon: Icons.route_outlined,
                label: sitesProvider.secondaryLocationLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun lieu ne correspond pour l\'instant',
            style: AppTextStyles.heading2.copyWith(color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Essaie une autre recherche, retire un filtre ou recharge la liste pour recuperer les derniers sites du backend.',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primaryDeep,
      checkmarkColor: Colors.white,
      labelStyle: AppTextStyles.caption.copyWith(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: isSelected ? AppColors.primaryDeep : AppColors.border,
          width: isSelected ? 0 : 1,
        ),
      ),
    );
  }
}
