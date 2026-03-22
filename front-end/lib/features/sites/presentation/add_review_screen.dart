import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/api_service.dart';
import '../../auth/presentation/auth_provider.dart';
import 'sites/site.dart';
import 'sites_provider.dart';

class AddReviewScreen extends StatefulWidget {
  final String? siteId;

  const AddReviewScreen({super.key, this.siteId});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final ApiService _apiService = ApiService();

  Site? _site;
  int _rating = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSite();
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

  String? _validateComment(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Le commentaire est obligatoire (min 20 caracteres)';
    }
    if (text.length < 20) {
      return 'Le commentaire doit contenir au moins 20 caracteres';
    }
    if (text.length > 4000) {
      return 'Le commentaire ne peut pas depasser 4000 caracteres';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();
    final router = GoRouter.of(context);

    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Veuillez selectionner une note'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_site == null) {
        throw ApiException(message: 'Site invalide');
      }

      final result = await _apiService.submitReview(
        siteId: _site!.id,
        rating: _rating,
        content: _commentController.text.trim(),
      );

      if (!mounted) return;
      await authProvider.refreshUser();
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.isPendingModeration
                ? 'Avis envoye. Il sera visible apres moderation.'
                : 'Avis publie avec succes.',
          ),
          backgroundColor: AppColors.secondary,
        ),
      );
      router.pop();
    } catch (e) {
      if (!mounted) return;
      String message = 'Erreur lors de la publication de l avis.';
      if (e is ApiException) {
        if (e.isUnauthorized) {
          message = 'Votre session a expire. Reconnectez-vous pour continuer.';
        } else if (e.statusCode == 409 ||
            e.message.toLowerCase().contains('deja')) {
          message = 'Vous avez deja publie un avis pour ce site.';
        } else if (e.statusCode == 400) {
          message = 'Votre avis est invalide. Verifiez la note et le contenu.';
        } else if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.message.toLowerCase().contains('connexion')) {
          message = 'Pas de connexion internet. Reessayez.';
        } else if (e.message.isNotEmpty) {
          message = e.message;
        }
      }
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
      if (e is ApiException && e.isUnauthorized) {
        authProvider.clearError();
        router.go('/login');
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
    if (_site == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ajouter un avis')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un avis'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.place, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _site!.name,
                              style: AppTextStyles.heading2.copyWith(
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _site!.category,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Votre note',
                style: AppTextStyles.heading2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Center(child: _buildRatingBar()),
              if (_rating == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Veuillez selectionner une note',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                maxLength: 4000,
                validator: _validateComment,
                decoration: InputDecoration(
                  hintText: 'Decrivez votre experience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Photo (bientot disponible)',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Le backend n expose pas encore l upload de photo pour les avis. '
                        'L avis est actuellement envoye en texte uniquement.',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                      : const Text('Publier l avis'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: _isLoading
              ? null
              : () {
                  setState(() {
                    _rating = starIndex;
                  });
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starIndex <= _rating ? Icons.star : Icons.star_border,
              size: 42,
              color: starIndex <= _rating ? Colors.amber : Colors.grey[400],
            ),
          ),
        );
      }),
    );
  }
}
