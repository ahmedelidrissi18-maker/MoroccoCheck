import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/user.dart';
import '../../auth/presentation/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _badges = [];
  bool _isExtrasLoading = false;
  String? _extrasError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _refreshProfile(context.read<AuthProvider>());
    });
  }

  Future<void> _refreshProfile(AuthProvider authProvider) async {
    setState(() {
      _isExtrasLoading = true;
      _extrasError = null;
    });

    try {
      await authProvider.refreshUser();
      final stats = await _apiService.fetchMyStats();
      final badges = await _apiService.fetchMyBadges();

      if (!mounted) return;

      setState(() {
        _stats = stats;
        _badges = badges;
        _isExtrasLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isExtrasLoading = false;
        _extrasError = e.toString();
      });
    }
  }

  int _readInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  String _readString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = '$value'.trim();
    return text.isEmpty ? fallback : text;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, data) => MapEntry(key.toString(), data));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: authProvider.isLoading && user == null
              ? const Center(child: CircularProgressIndicator())
              : user == null
              ? _buildEmptyState(authProvider)
              : _buildContent(context, authProvider, user),
        );
      },
    );
  }

  Widget _buildEmptyState(AuthProvider authProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off_outlined, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Aucun profil charge', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(
              authProvider.error ??
                  'Connecte-toi pour recuperer tes informations.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AuthProvider authProvider,
    User user,
  ) {
    final points = _asMap(_stats?['points']);
    final activity = _asMap(_stats?['activity']);
    final achievements = _asMap(_stats?['achievements']);
    final social = _asMap(_stats?['social']);
    final recentActivity =
        (_stats?['recent_activity'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (item) =>
                  item.map((key, value) => MapEntry(key.toString(), value)),
            )
            .toList();

    final totalPoints = _readInt(points?['total'], fallback: user.points);
    final level = _readInt(points?['level'], fallback: user.level);
    final nextLevelAt = _readInt(
      points?['next_level_at'],
      fallback: level * 100,
    );
    final progress = (_readInt(points?['progress_to_next_level']) / 100)
        .clamp(0, 1)
        .toDouble();
    final rank = _readString(points?['rank'], fallback: user.rank ?? 'BRONZE');
    final canManageSites =
        user.role == 'PROFESSIONAL' ||
        user.role == 'MODERATOR' ||
        user.role == 'ADMIN';

    return RefreshIndicator(
      onRefresh: () => _refreshProfile(authProvider),
      child: ListView(
        children: [
          _buildHeader(user, rank),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatCard('$totalPoints', 'pts'),
                _buildStatCard(
                  '${_readInt(activity?['checkins_count'], fallback: user.checkinsCount)}',
                  'check-ins',
                ),
                _buildStatCard(
                  '${_readInt(activity?['reviews_count'], fallback: user.reviewsCount)}',
                  'avis',
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.military_tech, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Niveau $level',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        rank,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      color: Colors.amber,
                      backgroundColor: const Color(0xFFE5E7EB),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$totalPoints / $nextLevelAt points',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Modifier mon profil'),
                  subtitle: const Text(
                    'Mettre a jour vos informations personnelles',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/edit', extra: user),
                ),
                _buildInfoTile(Icons.workspace_premium_outlined, 'Rang', rank),
                _buildInfoTile(
                  Icons.badge_outlined,
                  'Role',
                  user.role ?? 'TOURIST',
                ),
                _buildInfoTile(
                  Icons.verified_user_outlined,
                  'Statut',
                  user.status ?? 'ACTIVE',
                ),
                _buildInfoTile(
                  Icons.emoji_events_outlined,
                  'Badges',
                  '${_readInt(achievements?['badges_earned'], fallback: user.badgeCount)} / ${_readInt(achievements?['total_badges'])}',
                ),
                _buildInfoTile(
                  Icons.favorite_outline,
                  'Favoris',
                  '${_readInt(social?['favorites_count'])}',
                ),
                _buildInfoTile(
                  Icons.thumb_up_alt_outlined,
                  'Avis utiles',
                  '${_readInt(social?['reviews_helpful_count'])}',
                ),
                if ((user.phoneNumber ?? '').isNotEmpty)
                  _buildInfoTile(
                    Icons.phone_outlined,
                    'Telephone',
                    user.phoneNumber!,
                  ),
                if ((user.nationality ?? '').isNotEmpty)
                  _buildInfoTile(
                    Icons.flag_outlined,
                    'Nationalite',
                    user.nationality!,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(
                  Icons.leaderboard,
                  color: AppColors.primary,
                ),
                title: const Text('Voir le leaderboard'),
                subtitle: const Text(
                  'Consulter le classement reel des contributeurs',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/leaderboard'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(
                  Icons.workspace_premium_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Voir tous les badges'),
                subtitle: const Text(
                  'Consulter le catalogue global et ses conditions',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile/badges'),
              ),
            ),
          ),
          if (canManageSites)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.primary,
                      ),
                      title: const Text('Mes etablissements'),
                      subtitle: const Text(
                        'Voir les lieux publics rattaches a votre compte',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/professional/sites'),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.add_business_outlined,
                        color: AppColors.primary,
                      ),
                      title: const Text('Ajouter un lieu'),
                      subtitle: const Text(
                        'Soumettre un nouvel etablissement au backend',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/professional/sites/new'),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Mes badges',
              style: AppTextStyles.heading2.copyWith(fontSize: 20),
            ),
          ),
          if ((user.bio ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bio',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.bio!,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          _badges.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _isExtrasLoading
                        ? 'Chargement des badges...'
                        : 'Aucun badge obtenu pour le moment.',
                    style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _badges.length > 6 ? 6 : _badges.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.9,
                        ),
                    itemBuilder: (context, index) {
                      final badge = _badges[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            child: Icon(
                              Icons.workspace_premium,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _readString(badge['name'], fallback: 'Badge'),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _readString(badge['rarity'], fallback: 'STANDARD'),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Activite recente',
              style: AppTextStyles.heading2.copyWith(fontSize: 20),
            ),
          ),
          const SizedBox(height: 8),
          if (recentActivity.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _isExtrasLoading
                    ? 'Chargement de l activite...'
                    : 'Aucune activite recente.',
                style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
              ),
            )
          else
            ...recentActivity.take(5).map((item) {
              final type = _readString(item['type'], fallback: 'ACTION');
              final isCheckin = type == 'CHECKIN';
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: isCheckin
                      ? Colors.green.withValues(alpha: 0.18)
                      : Colors.blue.withValues(alpha: 0.18),
                  child: Icon(
                    isCheckin ? Icons.location_on : Icons.rate_review,
                    size: 18,
                    color: isCheckin ? Colors.green : Colors.blue,
                  ),
                ),
                title: Text(_readString(item['site_name'], fallback: 'Site')),
                subtitle: Text(
                  '${type == 'CHECKIN' ? 'Check-in' : 'Avis'} - +${_readInt(item['points_earned'])} pts',
                ),
              );
            }),
          if (authProvider.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                authProvider.error!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          if (_extrasError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _extrasError!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Rafraichir le profil'),
            onTap: _isExtrasLoading
                ? null
                : () => _refreshProfile(authProvider),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Se deconnecter',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Confirmation'),
                    content: const Text('Voulez-vous vous deconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Deconnexion'),
                      ),
                    ],
                  );
                },
              );
              if (shouldLogout == true && context.mounted) {
                await context.read<AuthProvider>().logout(context: context);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(User user, String rank) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF0F766E)],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            backgroundImage:
                user.profilePicture != null && user.profilePicture!.isNotEmpty
                ? NetworkImage(user.profilePicture!)
                : null,
            child: user.profilePicture == null || user.profilePicture!.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 40)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  user.email,
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rank,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                value,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                  fontSize: 22,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: Text(
        value,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
