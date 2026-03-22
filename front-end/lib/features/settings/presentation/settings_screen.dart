import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/location/location_service.dart';
import '../../../core/storage/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();

  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _preciseLocationEnabled = true;
  bool _technicalInfoVisible = false;
  bool _locationServiceEnabled = false;
  LocationPermission? _locationPermission;
  String _preferredLanguage = 'fr';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    final locationEnabled = await _locationService.isLocationServiceEnabled();
    final permission = await _locationService.checkPermission();

    if (!mounted) return;

    setState(() {
      _preferredLanguage = _storageService.getPreferredLanguage();
      _notificationsEnabled = _storageService.getNotificationsEnabled();
      _preciseLocationEnabled = _storageService.getPreciseLocationEnabled();
      _technicalInfoVisible = _storageService.getTechnicalInfoVisible();
      _locationServiceEnabled = locationEnabled;
      _locationPermission = permission;
      _isLoading = false;
    });
  }

  Future<void> _updateLanguage(String value) async {
    await _storageService.savePreferredLanguage(value);
    if (!mounted) return;

    setState(() {
      _preferredLanguage = value;
    });

    _showInfoSnack(
      'Preference de langue enregistree. La traduction complete arrivera dans une prochaine iteration.',
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    await _storageService.saveNotificationsEnabled(value);
    if (!mounted) return;

    setState(() {
      _notificationsEnabled = value;
    });

    _showInfoSnack(
      value
          ? 'Les notifications locales sont activees pour votre appareil.'
          : 'Les notifications locales sont desactivees pour votre appareil.',
    );
  }

  Future<void> _togglePreciseLocation(bool value) async {
    await _storageService.savePreciseLocationEnabled(value);
    if (!mounted) return;

    setState(() {
      _preciseLocationEnabled = value;
    });

    _showInfoSnack(
      value
          ? 'La localisation precise est privilegiee pour les parcours terrain.'
          : 'L application privilegiera des parcours sans localisation fine quand c est possible.',
    );
  }

  Future<void> _toggleTechnicalInfo(bool value) async {
    await _storageService.saveTechnicalInfoVisible(value);
    if (!mounted) return;

    setState(() {
      _technicalInfoVisible = value;
    });
  }

  Future<void> _openLocationSettings() async {
    final opened = await _locationService.openLocationSettings();
    if (!mounted) return;

    if (opened) {
      _showInfoSnack('Ouverture des reglages de localisation.');
    } else {
      _showInfoSnack(
        'Impossible d ouvrir automatiquement les reglages de localisation.',
      );
    }

    await _loadSettings();
  }

  Future<void> _openAppSettings() async {
    final opened = await _locationService.openAppSettings();
    if (!mounted) return;

    if (opened) {
      _showInfoSnack('Ouverture des reglages de l application.');
    } else {
      _showInfoSnack(
        'Impossible d ouvrir automatiquement les reglages de l application.',
      );
    }

    await _loadSettings();
  }

  Future<void> _resetPreferences() async {
    await _storageService.resetAppPreferences();
    await _loadSettings();
    if (!mounted) return;

    _showInfoSnack('Les preferences locales ont ete reinitialisees.');
  }

  Future<void> _copySupportEmail() async {
    await Clipboard.setData(
      const ClipboardData(text: AppConstants.supportEmail),
    );
    if (!mounted) return;

    _showInfoSnack('Adresse de support copiee.');
  }

  void _showPrivacyDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confidentialite'),
        content: const Text(
          'Cette version stocke localement vos preferences et vos jetons de session. Les donnees de contribution, de profil et d activite sont transmises au backend MoroccoCheck lorsque vous utilisez les parcours relies a l API.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showInfoSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reglages')),
      body: RefreshIndicator(
        onRefresh: _loadSettings,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0F766E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Preferences de l application',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Personnalisez votre experience locale autour de ${AppConstants.focusCity}, gelez vos preferences et gardez un oeil sur l etat de la localisation.',
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Preferences',
              icon: Icons.settings_suggest_outlined,
              children: [
                _LanguageTile(
                  value: _preferredLanguage,
                  onChanged: _updateLanguage,
                ),
                SwitchListTile(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeThumbColor: AppColors.primary,
                  title: const Text('Notifications'),
                  subtitle: const Text(
                    'Conserver les rappels et retours locaux sur cet appareil',
                  ),
                ),
                SwitchListTile(
                  value: _preciseLocationEnabled,
                  onChanged: _togglePreciseLocation,
                  activeThumbColor: AppColors.primary,
                  title: const Text('Localisation precise'),
                  subtitle: const Text(
                    'Favoriser une position fine pour les parcours carte et check-in',
                  ),
                ),
                SwitchListTile(
                  value: _technicalInfoVisible,
                  onChanged: _toggleTechnicalInfo,
                  activeThumbColor: AppColors.primary,
                  title: const Text('Afficher les details techniques'),
                  subtitle: const Text(
                    'Montrer la configuration locale et les infos de debug utiles',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Localisation',
              icon: Icons.location_on_outlined,
              children: [
                _StatusRow(
                  label: 'Service de localisation',
                  state: _locationServiceEnabled ? 'Actif' : 'Desactive',
                  color: _locationServiceEnabled
                      ? AppColors.secondary
                      : Colors.orange,
                ),
                _StatusRow(
                  label: 'Permission actuelle',
                  state: _permissionLabel(_locationPermission),
                  color: _permissionColor(_locationPermission),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.gps_fixed_outlined),
                  title: const Text('Ouvrir les reglages de localisation'),
                  subtitle: const Text(
                    'Activez le GPS ou ajustez les services de position du telephone',
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: _openLocationSettings,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.app_settings_alt_outlined),
                  title: const Text('Ouvrir les reglages de l application'),
                  subtitle: const Text(
                    'Gerez les permissions de MoroccoCheck sur cet appareil',
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: _openAppSettings,
                ),
              ],
            ),
            if (_technicalInfoVisible) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Configuration locale',
                icon: Icons.memory_outlined,
                children: [
                  _InfoRow(
                    label: 'Ville active',
                    value: AppConstants.focusCity,
                  ),
                  _InfoRow(label: 'Region', value: AppConstants.focusRegion),
                  _InfoRow(label: 'API', value: AppConstants.baseUrl),
                  _InfoRow(
                    label: 'Coordonnees',
                    value:
                        '${AppConstants.focusLatitude}, ${AppConstants.focusLongitude}',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _SectionCard(
              title: 'A propos',
              icon: Icons.info_outline,
              children: [
                _InfoRow(label: 'Version', value: AppConstants.appVersion),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Politique de confidentialite'),
                  subtitle: const Text(
                    'Lire un resume des donnees utilisees par cette version',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPrivacyDialog,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.support_agent_outlined),
                  title: const Text('Support'),
                  subtitle: Text(AppConstants.supportEmail),
                  trailing: const Icon(Icons.copy_outlined),
                  onTap: _copySupportEmail,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.cleaning_services_outlined,
                    color: AppColors.error,
                  ),
                  title: const Text('Reinitialiser les preferences'),
                  subtitle: const Text(
                    'Remettre les options locales a leur valeur par defaut',
                  ),
                  trailing: const Icon(Icons.restore_outlined),
                  onTap: _resetPreferences,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _permissionLabel(LocationPermission? permission) {
    switch (permission) {
      case LocationPermission.always:
        return 'Toujours autorisee';
      case LocationPermission.whileInUse:
        return 'Autorisee pendant l usage';
      case LocationPermission.deniedForever:
        return 'Refusee definitivement';
      case LocationPermission.denied:
        return 'Refusee';
      case LocationPermission.unableToDetermine:
        return 'Indeterminee';
      case null:
        return 'Indisponible';
    }
  }

  Color _permissionColor(LocationPermission? permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return AppColors.secondary;
      case LocationPermission.deniedForever:
        return AppColors.error;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
      case null:
        return Colors.orange;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.heading2.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String state;
  final Color color;

  const _StatusRow({
    required this.label,
    required this.state,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              state,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _LanguageTile({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.language_outlined),
      title: const Text('Langue preferee'),
      subtitle: const Text(
        'Le choix est memorise localement pour les futures iterations multilingues',
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: (nextValue) {
          if (nextValue != null) {
            onChanged(nextValue);
          }
        },
        items: const [
          DropdownMenuItem(value: 'fr', child: Text('Francais')),
          DropdownMenuItem(value: 'ar', child: Text('Arabe')),
          DropdownMenuItem(value: 'en', child: Text('Anglais')),
        ],
      ),
    );
  }
}
