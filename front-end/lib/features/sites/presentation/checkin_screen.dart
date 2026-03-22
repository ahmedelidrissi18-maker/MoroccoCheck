import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/location/location_service.dart';
import '../../../core/location/location_utils.dart';
import '../../../core/network/api_service.dart';
import '../../auth/presentation/auth_provider.dart';
import 'sites_provider.dart';
import 'sites/site.dart';

class CheckinScreen extends StatefulWidget {
  final String? siteId;
  final bool skipLocationCheckForTest;
  final double? mockDistanceForTest;

  const CheckinScreen({
    super.key,
    this.siteId,
    this.skipLocationCheckForTest = false,
    this.mockDistanceForTest,
  });

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  static const Set<String> _allowedRoles = <String>{
    'CONTRIBUTOR',
    'PROFESSIONAL',
    'MODERATOR',
    'ADMIN',
  };

  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();

  Site? _site;
  Position? _userPosition;
  double? _distance;
  bool _isLoading = false;
  bool _isCheckingLocation = true;
  bool _showSuccessAnimation = false;
  String? _error;
  String? _selectedStatus = 'OPEN';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSite();
      if (!mounted) return;

      if (widget.skipLocationCheckForTest) {
        setState(() {
          _isCheckingLocation = false;
          _distance = widget.mockDistanceForTest ?? 245.0;
          if (_distance! > 100) {
            _error =
                'Vous etes trop loin du site. Distance: ${formatDistance(_distance!)}. Vous devez etre a moins de 100 metres pour effectuer un check-in.';
          }
        });
      } else {
        await _checkUserLocation();
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadSite() async {
    if (widget.siteId == null) {
      return;
    }

    final sitesProvider = context.read<SitesProvider>();
    final cachedSite = sitesProvider.getSiteById(widget.siteId!);
    if (cachedSite != null) {
      setState(() {
        _site = cachedSite;
      });
      return;
    }

    try {
      if (sitesProvider.sites.isEmpty) {
        await sitesProvider.getSites();
      }

      final providerSite = sitesProvider.getSiteById(widget.siteId!);
      if (providerSite != null) {
        if (!mounted) return;
        setState(() {
          _site = providerSite;
        });
        return;
      }

      final apiSite = await _apiService.fetchSiteDetail(widget.siteId!);
      if (!mounted) return;
      setState(() {
        _site = apiSite;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _site = null;
      });
    }
  }

  Future<void> _checkUserLocation() async {
    setState(() {
      _isCheckingLocation = true;
      _error = null;
    });

    try {
      // Request permission
      await _locationService.requestPermission();

      // Get current position
      final position = await _locationService.getCurrentPosition(
        accuracy: LocationAccuracy.high,
      );

      if (mounted && _site != null) {
        // Calculate distance
        final distance = calculateDistance(
          position.latitude,
          position.longitude,
          _site!.latitude,
          _site!.longitude,
        );

        setState(() {
          _userPosition = position;
          _distance = distance;
          _isCheckingLocation = false;

          // Check if distance is within 100m
          if (distance > 100) {
            _error =
                'Vous êtes trop loin du site. Distance: ${formatDistance(distance)}. Vous devez être à moins de 100 mètres pour effectuer un check-in.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingLocation = false;
          _error =
              'Impossible de verifier votre position. Activez la localisation puis reessayez.';
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider?>();
    final router = GoRouter.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_distance == null || _distance! > 100) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez vous rapprocher du site pour effectuer un check-in.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_site == null || _userPosition == null) {
        throw ApiException(message: 'Site ou position invalide');
      }

      await _apiService.submitCheckin(
        siteId: _site!.id,
        latitude: _userPosition!.latitude,
        longitude: _userPosition!.longitude,
        status: _selectedStatus,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;

      context.read<SitesProvider>().markSiteCheckedIn(_site!.id);
      await context.read<AuthProvider>().refreshUser();

      setState(() {
        _isLoading = false;
        _showSuccessAnimation = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      String message = 'Erreur lors du check-in.';
      if (e is ApiException) {
        if (e.isUnauthorized) {
          message = 'Votre session a expire. Reconnectez-vous pour continuer.';
        } else if (e.code == 'ROLE_NOT_ALLOWED' || e.isForbidden) {
          message =
              'Le check-in est reserve aux comptes contributeur, professionnel, moderateur ou admin.';
        } else if (e.code == 'CHECKIN_TOO_FAR') {
          message = 'Distance trop grande. Approchez-vous a moins de 100 m.';
        } else if (e.statusCode == 409 ||
            e.message.toLowerCase().contains('deja')) {
          message =
              'Vous avez deja enregistre un check-in pour ce site aujourd hui.';
        } else if (e.statusCode == 400) {
          message = 'Les donnees du check-in sont invalides.';
        } else if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          message = 'Pas de connexion internet. Reessayez.';
        } else if (e.message.isNotEmpty) {
          message = e.message;
        }
      }
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
        if (e is ApiException && e.isUnauthorized) {
          authProvider?.clearError();
          router.go('/login');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider?>()?.user;
    final canSubmitCheckin =
        currentUser == null || _allowedRoles.contains(currentUser.role);

    if (_site == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Check-in'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Check-in'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Site info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_site!.name, style: AppTextStyles.heading2),
                        const SizedBox(height: 8),
                        Text(
                          _site!.category,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Location checking
                if (_isCheckingLocation)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Vérification de votre position...',
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Distance info
                if (_distance != null && !_isCheckingLocation)
                  Card(
                    color: _distance! <= 100
                        ? AppColors.secondary.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            _distance! <= 100
                                ? Icons.check_circle
                                : Icons.error,
                            color: _distance! <= 100
                                ? AppColors.secondary
                                : AppColors.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Distance: ${formatDistance(_distance!)}',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_distance! <= 100)
                                  Text(
                                    'Vous êtes à proximité du site',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Error message
                if (_error != null && !_isCheckingLocation)
                  Card(
                    color: AppColors.error.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_outline, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _checkUserLocation,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!canSubmitCheckin)
                  Card(
                    color: AppColors.error.withValues(alpha: 0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, color: AppColors.error),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Le backend reserve le check-in aux comptes contributeur, professionnel, moderateur ou admin.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Form (only show if distance is valid)
                if (_distance != null &&
                    _distance! <= 100 &&
                    _error == null &&
                    canSubmitCheckin)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'Statut du site',
                          style: AppTextStyles.heading2.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 12),
                        // Status selection
                        RadioGroup<String>(
                          groupValue: _selectedStatus,
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                          child: Column(
                            children: ['OPEN', 'CLOSED', 'UNDER_CONSTRUCTION']
                                .map((status) {
                                  return RadioListTile<String>(
                                    title: Text(_getStatusLabel(status)),
                                    value: status,
                                    selected: _selectedStatus == status,
                                    activeColor: AppColors.primary,
                                  );
                                })
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Comment field
                        Text(
                          'Commentaire (optionnel)',
                          style: AppTextStyles.heading2.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _commentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Ajoutez un commentaire sur l\'état du site...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Soumettre le check-in',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Success animation overlay
        if (_showSuccessAnimation)
          _SuccessAnimationOverlay(
            onAnimationComplete: () {
              setState(() {
                _showSuccessAnimation = false;
              });
            },
          ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'OPEN':
        return 'Ouvert';
      case 'CLOSED':
        return 'Fermé';
      case 'UNDER_CONSTRUCTION':
        return 'En construction';
      default:
        return status;
    }
  }
}

/// Success animation overlay widget
class _SuccessAnimationOverlay extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const _SuccessAnimationOverlay({required this.onAnimationComplete});

  @override
  State<_SuccessAnimationOverlay> createState() =>
      _SuccessAnimationOverlayState();
}

class _SuccessAnimationOverlayState extends State<_SuccessAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pointsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _pointsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onAnimationComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Success message
                  Text(
                    'Check-in réussi!',
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 24,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Points animation
                  AnimatedBuilder(
                    animation: _pointsAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pointsAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, -20 * (1 - _pointsAnimation.value)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.stars,
                                  color: AppColors.secondary,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+10 points',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
