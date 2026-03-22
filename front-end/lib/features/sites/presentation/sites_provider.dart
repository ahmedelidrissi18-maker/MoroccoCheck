import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/site_category.dart';
import 'sites/site.dart';

class SitesProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Site> _allSites = [];
  List<SiteCategory> _availableCategories = [];
  final Set<String> _checkedInSiteIds = <String>{};
  List<Site> get sites => _allSites;
  List<SiteCategory> get availableCategories => _availableCategories;

  List<Site> _filteredSites = [];
  List<Site> get filteredSites => _filteredSites;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;
  int? _selectedSubcategoryId;
  int? get selectedSubcategoryId => _selectedSubcategoryId;
  String? _selectedSubcategory;
  String? get selectedSubcategory => _selectedSubcategory;

  String? get selectedCategoryName {
    if (_selectedCategoryId == null) {
      return null;
    }

    for (final category in _availableCategories) {
      if (category.id == _selectedCategoryId) {
        return category.name;
      }
    }

    for (final site in _allSites) {
      if (site.categoryId == _selectedCategoryId) {
        return site.category;
      }
    }

    return null;
  }

  String? get selectedSubcategoryName {
    for (final option in availableSubcategoryOptions) {
      final matchesId =
          _selectedSubcategoryId != null && option.id == _selectedSubcategoryId;
      final matchesLegacy =
          _selectedSubcategoryId == null &&
          _selectedSubcategory != null &&
          option.legacyValue?.toLowerCase() ==
              _selectedSubcategory!.toLowerCase();

      if (matchesId || matchesLegacy) {
        return option.label;
      }
    }

    return _selectedSubcategory;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;
  Set<String> get checkedInSiteIds => _checkedInSiteIds;

  SitesProvider({
    ApiService? apiService,
    List<Site> initialSites = const <Site>[],
  }) : _apiService = apiService ?? ApiService() {
    _allSites = List<Site>.from(initialSites);
    _filteredSites = List<Site>.from(initialSites);
  }

  List<String> get categories {
    final backendCategories =
        _availableCategories
            .where((category) => category.isTopLevel)
            .map((category) => category.name.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (backendCategories.isNotEmpty) {
      return backendCategories;
    }

    final Set<String> categoriesSet = _allSites
        .map((site) => site.category)
        .where((category) => category.trim().isNotEmpty)
        .toSet();
    return categoriesSet.toList()..sort();
  }

  List<SiteCategory> get topLevelCategories =>
      _availableCategories.where((category) => category.isTopLevel).toList();

  List<SiteCategory> get availableSubcategories =>
      getSubcategoriesFor(_selectedCategoryId);

  List<SiteSubcategoryOption> get availableSubcategoryOptions =>
      getSubcategoryOptionsFor(_selectedCategoryId);

  String get primaryLocationLabel {
    final cities = _allSites
        .map((site) => site.city.trim())
        .where((city) => city.isNotEmpty)
        .toSet();

    if (cities.length == 1) {
      return cities.first;
    }
    if (cities.length > 1) {
      return 'Maroc';
    }
    return 'Maroc';
  }

  String get secondaryLocationLabel {
    final regions = _allSites
        .map((site) => site.region.trim())
        .where((region) => region.isNotEmpty)
        .toSet();

    if (regions.length == 1) {
      return regions.first;
    }
    if (regions.length > 1) {
      return '${regions.length} regions';
    }
    return 'Donnees backend';
  }

  Future<void> getSites({
    String? city,
    int? categoryId,
    int? subcategoryId,
    String? subcategory,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final effectiveCategoryId = categoryId ?? _selectedCategoryId;
      final effectiveSubcategoryId = subcategoryId ?? _selectedSubcategoryId;
      final effectiveSubcategory =
          subcategory ??
          (effectiveSubcategoryId == null ? _selectedSubcategory : null);
      final trimmedCity = city?.trim();
      final trimmedSubcategory = effectiveSubcategory?.trim();

      final queryParameters = <String, dynamic>{
        if (trimmedCity?.isNotEmpty ?? false) 'city': trimmedCity,
        ...?effectiveCategoryId != null
            ? <String, dynamic>{'category_id': effectiveCategoryId}
            : null,
        ...?effectiveSubcategoryId != null
            ? <String, dynamic>{'subcategory_id': effectiveSubcategoryId}
            : null,
        ...?trimmedSubcategory?.isNotEmpty == true
            ? <String, dynamic>{'subcategory': trimmedSubcategory}
            : null,
      };

      _allSites = await _apiService.fetchSites(
        queryParameters: queryParameters,
      );
      try {
        _availableCategories = await _apiService.fetchCategories(
          topLevelOnly: true,
        );
      } catch (_) {
        _availableCategories = const <SiteCategory>[];
      }
      _applyFilters();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  void searchSites(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
  }

  void filterByCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _selectedSubcategoryId = null;
    _selectedSubcategory = null;
    _applyFilters();
  }

  void filterBySubcategory({int? subcategoryId, String? subcategory}) {
    _selectedSubcategoryId = subcategoryId;
    _selectedSubcategory = subcategory?.trim().isEmpty == true
        ? null
        : subcategory?.trim();
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _selectedSubcategoryId = null;
    _selectedSubcategory = null;
    _applyFilters();
  }

  Site? getSiteById(String id) {
    try {
      return _allSites.firstWhere((site) => site.id == id);
    } catch (e) {
      return null;
    }
  }

  List<SiteCategory> getSubcategoriesFor(int? categoryId) {
    if (categoryId == null) {
      return const <SiteCategory>[];
    }

    for (final category in _availableCategories) {
      if (category.id == categoryId) {
        return category.children;
      }
    }

    return const <SiteCategory>[];
  }

  List<SiteSubcategoryOption> getSubcategoryOptionsFor(int? categoryId) {
    if (categoryId == null) {
      return const <SiteSubcategoryOption>[];
    }

    final structured = getSubcategoriesFor(categoryId)
        .map(
          (category) =>
              SiteSubcategoryOption(id: category.id, label: category.name),
        )
        .toList();

    final knownLabels = structured
        .map((option) => option.label.trim().toLowerCase())
        .where((label) => label.isNotEmpty)
        .toSet();

    final legacy =
        _allSites
            .where((site) => site.categoryId == categoryId)
            .map((site) => site.subcategory?.trim())
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .map((value) => value)
            .toSet()
            .where((value) => !knownLabels.contains(value.toLowerCase()))
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return <SiteSubcategoryOption>[
      ...structured,
      ...legacy.map(
        (value) => SiteSubcategoryOption(label: value, legacyValue: value),
      ),
    ];
  }

  void _applyFilters() {
    _filteredSites = _allSites.where((site) {
      final bool matchesSearch =
          _searchQuery.isEmpty ||
          site.name.toLowerCase().contains(_searchQuery) ||
          site.description.toLowerCase().contains(_searchQuery);

      final bool matchesCategory =
          _selectedCategoryId == null || site.categoryId == _selectedCategoryId;
      final bool matchesSubcategory =
          (_selectedSubcategoryId == null &&
              (_selectedSubcategory == null ||
                  _selectedSubcategory!.isEmpty)) ||
          (_selectedSubcategoryId != null &&
              site.subcategoryId == _selectedSubcategoryId) ||
          (_selectedSubcategoryId == null &&
              _selectedSubcategory != null &&
              (site.subcategory ?? '').toLowerCase() ==
                  _selectedSubcategory!.toLowerCase());

      return matchesSearch && matchesCategory && matchesSubcategory;
    }).toList();

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void markSiteCheckedIn(String siteId) {
    _checkedInSiteIds.add(siteId);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
}

class SiteSubcategoryOption {
  final int? id;
  final String label;
  final String? legacyValue;

  const SiteSubcategoryOption({this.id, required this.label, this.legacyValue});
}
