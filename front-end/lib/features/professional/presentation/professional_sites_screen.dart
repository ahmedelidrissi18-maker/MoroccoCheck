import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/professional_site.dart';
import 'professional_site_status.dart';

class ProfessionalSitesScreen extends StatefulWidget {
  const ProfessionalSitesScreen({super.key});

  @override
  State<ProfessionalSitesScreen> createState() =>
      _ProfessionalSitesScreenState();
}

class _ProfessionalSitesScreenState extends State<ProfessionalSitesScreen> {
  final ApiService _apiService = ApiService();
  List<ProfessionalSite> _sites = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedStatus;

  static const List<String> _statusFilters = [
    'PUBLISHED',
    'PENDING_REVIEW',
    'ARCHIVED',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSites();
    });
  }

  Future<void> _loadSites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sites = await _apiService.fetchProfessionalSites(
        queryParameters: <String, dynamic>{
          'limit': 50,
          if (_selectedStatus != null) 'status': _selectedStatus,
        },
      );
      if (!mounted) return;

      setState(() {
        _sites = sites;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _openCreateScreen() async {
    final created = await context.push<bool>('/professional/sites/new');
    if (created == true && mounted) {
      await _loadSites();
    }
  }

  Future<void> _openDetailScreen(ProfessionalSite site) async {
    await context.push('/professional/sites/${site.id}');
    if (mounted) {
      await _loadSites();
    }
  }

  Future<void> _openEditScreen(ProfessionalSite site) async {
    final updated = await context.push<bool>(
      '/professional/sites/${site.id}/edit',
      extra: site,
    );
    if (updated == true && mounted) {
      await _loadSites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes etablissements')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateScreen,
        label: const Text('Ajouter'),
        icon: const Icon(Icons.add_business),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSites,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Espace professionnel',
                          style: AppTextStyles.heading2.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Suivez vos lieux, ouvrez leur fiche proprietaire pour voir les details et modifiez rapidement les informations quand une correction est necessaire.',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_sites.length} lieu${_sites.length > 1 ? 'x' : ''} affiche${_sites.length > 1 ? 's' : ''}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('Tous', _selectedStatus == null, () {
                          setState(() {
                            _selectedStatus = null;
                          });
                          _loadSites();
                        }),
                        const SizedBox(width: 8),
                        ..._statusFilters.map(
                          (status) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterChip(
                              _statusFilterLabel(status),
                              _selectedStatus == status,
                              () {
                                setState(() {
                                  _selectedStatus = status;
                                });
                                _loadSites();
                              },
                            ),
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
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _error!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  if (_sites.isEmpty && _error == null)
                    EmptyStateWidget(
                      icon: Icons.storefront_outlined,
                      title: 'Aucun lieu pour le moment',
                      message:
                          'Commencez par soumettre votre premier lieu. Les statuts de publication et de validation apparaitront ici.',
                      primaryAction: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openCreateScreen,
                          icon: const Icon(Icons.add_business),
                          label: const Text('Ajouter un etablissement'),
                        ),
                      ),
                    )
                  else
                    ..._sites.map((site) {
                      final publication = publicationStatusInfo(site.status);
                      final verification = verificationStatusInfo(
                        site.verificationStatus,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _openDetailScreen(site),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            site.name,
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${site.categoryName} - ${site.city}',
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      site.rating > 0
                                          ? site.rating.toStringAsFixed(1)
                                          : 'N/A',
                                      style: AppTextStyles.heading2.copyWith(
                                        fontSize: 18,
                                        color: Colors.amber.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    StatusChip(
                                      icon: publication.icon,
                                      label: publication.label,
                                      tone: _publicationTone(site.status),
                                      size: StatusChipSize.small,
                                    ),
                                    StatusChip(
                                      icon: verification.icon,
                                      label: verification.label,
                                      tone: _verificationTone(
                                        site.verificationStatus,
                                      ),
                                      size: StatusChipSize.small,
                                    ),
                                    _StatusPill(
                                      label:
                                          'Fraicheur ${site.freshnessScore}%',
                                      color: AppColors.secondary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (site.address.isNotEmpty)
                                  Text(
                                    site.address,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _openEditScreen(site),
                                      icon: const Icon(Icons.edit_outlined),
                                      label: const Text('Modifier'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  String _statusFilterLabel(String status) {
    switch (status) {
      case 'PUBLISHED':
        return 'Publies';
      case 'PENDING_REVIEW':
        return 'En attente';
      case 'ARCHIVED':
        return 'Archives';
      default:
        return status;
    }
  }

  StatusChipTone _publicationTone(String status) {
    switch (status) {
      case 'PUBLISHED':
        return StatusChipTone.success;
      case 'PENDING_REVIEW':
        return StatusChipTone.warning;
      default:
        return StatusChipTone.defaultTone;
    }
  }

  StatusChipTone _verificationTone(String status) {
    switch (status) {
      case 'VERIFIED':
        return StatusChipTone.success;
      case 'PENDING':
        return StatusChipTone.warning;
      case 'REJECTED':
        return StatusChipTone.danger;
      default:
        return StatusChipTone.defaultTone;
    }
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: AppTextStyles.caption.copyWith(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

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
