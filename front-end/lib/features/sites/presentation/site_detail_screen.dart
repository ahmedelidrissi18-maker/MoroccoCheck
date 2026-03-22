import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/user.dart';
import '../../auth/presentation/auth_provider.dart';
import 'models/site_photo.dart';
import 'reviews_list.dart';
import 'sites/site.dart';
import 'sites_provider.dart';

class SiteDetailScreen extends StatefulWidget {
  final String? siteId;
  final ApiService? apiService;

  const SiteDetailScreen({super.key, this.siteId, this.apiService});

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen>
    with SingleTickerProviderStateMixin {
  static const Set<String> _checkinAllowedRoles = <String>{
    'CONTRIBUTOR',
    'PROFESSIONAL',
    'MODERATOR',
    'ADMIN',
  };

  late final ApiService _apiService;
  late TabController _tabController;

  Site? _site;
  List<SitePhoto> _photos = [];
  bool _isLoading = true;
  bool _isPhotosLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _tabController = TabController(length: 3, vsync: this);
    _loadSite();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSite() async {
    if (widget.siteId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Site introuvable';
      });
      return;
    }

    final sitesProvider = context.read<SitesProvider>();
    final cachedSite = sitesProvider.getSiteById(widget.siteId!);

    if (cachedSite != null) {
      setState(() {
        _site = cachedSite;
        _isLoading = false;
      });
    }

    try {
      final site = await _apiService.fetchSiteDetail(widget.siteId!);
      if (!mounted) return;

      setState(() {
        _site = site;
        _error = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = _site == null ? e.toString() : null;
      });
    }

    await _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (widget.siteId == null) return;

    setState(() {
      _isPhotosLoading = true;
    });

    try {
      final photos = await _apiService.fetchSitePhotos(widget.siteId!);
      if (!mounted) return;

      setState(() {
        _photos = photos;
        _isPhotosLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _photos = [];
        _isPhotosLoading = false;
      });
    }
  }

  Future<void> _refreshSite() async {
    await _loadSite();
  }

  void _handleCheckIn() {
    if (_site != null) {
      context.push('/checkin/${_site!.id}');
    }
  }

  Future<void> _handleAddReview() async {
    if (_site == null) return;

    await context.push('/review/${_site!.id}');
    if (!mounted) return;
    await _loadSite();
  }

  bool _canUserSubmitCheckin(User? user) {
    return user != null && _checkinAllowedRoles.contains(user.role);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.user;
    final isAuthenticated = authProvider.isAuthenticated;
    final canSubmitCheckin = _canUserSubmitCheckin(currentUser);

    if (_isLoading && _site == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Details du site'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_site == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Details du site'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'Impossible de charger ce site.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadSite,
                  child: const Text('Reessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final site = _site!;
    final freshnessColor = AppColors.getMarkerColor(site.freshnessScore);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshSite,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  tooltip: 'Rafraichir',
                  onPressed: _refreshSite,
                  icon: const Icon(Icons.refresh),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    site.imageUrl.isNotEmpty
                        ? Image.network(
                            site.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _heroChip(
                                icon: Icons.category_outlined,
                                label: site.category,
                              ),
                              _heroChip(
                                icon: Icons.place_outlined,
                                label: site.city.isNotEmpty
                                    ? site.city
                                    : (site.region.isNotEmpty
                                          ? site.region
                                          : 'Lieu'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            site.name,
                            style: AppTextStyles.heading1.copyWith(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MetricCard(
                          icon: Icons.star_rounded,
                          label: 'Note',
                          value: site.rating.toStringAsFixed(1),
                          accentColor: Colors.amber.shade700,
                        ),
                        _MetricCard(
                          icon: Icons.verified_outlined,
                          label: 'Fraicheur',
                          value: '${site.freshnessScore}%',
                          accentColor: freshnessColor,
                        ),
                        _MetricCard(
                          icon: Icons.photo_library_outlined,
                          label: 'Photos',
                          value: '${_photos.length}',
                          accentColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: canSubmitCheckin ? _handleCheckIn : null,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Check-in'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isAuthenticated
                                ? _handleAddReview
                                : null,
                            icon: const Icon(Icons.rate_review),
                            label: const Text('Ajouter un avis'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isAuthenticated)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Connectez-vous pour contribuer',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Le check-in et la publication d avis sont reserves aux utilisateurs connectes.',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () => context.push('/login'),
                                      child: const Text('Se connecter'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isAuthenticated && !canSubmitCheckin)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Le check-in est reserve aux comptes contributeur, professionnel, moderateur ou admin. Vous pouvez quand meme publier un avis.',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _error!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Info'),
                      Tab(text: 'Avis'),
                      Tab(text: 'Photos'),
                    ],
                  ),
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildInfoTab(site),
                        ReviewsList(siteId: site.id),
                        _buildPhotosTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[300],
      child: Icon(Icons.place, size: 64, color: Colors.grey[600]),
    );
  }

  Widget _heroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
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

  Widget _buildInfoTab(Site site) {
    final location = [
      site.address,
      site.city,
      site.region,
    ].where((item) => item.isNotEmpty).join(', ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSection(
            title: 'Description',
            child: Text(
              site.description.isNotEmpty
                  ? site.description
                  : 'Aucune description disponible pour ce lieu.',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Localisation',
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.pin_drop_outlined,
                  'Adresse',
                  location.isNotEmpty ? location : 'Non renseignee',
                ),
                _buildDetailRow(
                  Icons.my_location_outlined,
                  'Coordonnees',
                  '${site.latitude.toStringAsFixed(4)}, ${site.longitude.toStringAsFixed(4)}',
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.push('/map'),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Voir sur la carte'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Resume',
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.category_outlined,
                  'Categorie',
                  site.category,
                ),
                _buildDetailRow(
                  Icons.star_outline,
                  'Note moyenne',
                  site.rating.toStringAsFixed(1),
                ),
                _buildDetailRow(
                  Icons.verified_outlined,
                  'Score de fraicheur',
                  '${site.freshnessScore}%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    if (_isPhotosLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_photos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 56,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'Aucune photo disponible',
                style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 6),
              Text(
                'Le lieu est deja accessible, mais la galerie sera plus riche quand la communaute ajoutera davantage de contenus.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        final imageUrl = photo.thumbnailUrl?.isNotEmpty == true
            ? photo.thumbnailUrl!
            : photo.imageUrl;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPhotoPlaceholder(),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              if (photo.isPrimary)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Principale',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.image, size: 48, color: Colors.grey[600]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.heading2.copyWith(fontSize: 22)),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.heading2.copyWith(fontSize: 20)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
