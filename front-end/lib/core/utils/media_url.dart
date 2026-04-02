String buildMediaUrl(String? rawPath) {
  if (rawPath == null || rawPath.trim().isEmpty) return '';
  if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
    return rawPath;
  }
  final base = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5001',
  );
  final clean = rawPath.startsWith('/') ? rawPath : '/$rawPath';
  return '$base$clean';
}

String buildSiteStaticMapUrl({
  required double latitude,
  required double longitude,
  int zoom = 15,
  String size = '1200x700',
}) {
  if (latitude == 0 && longitude == 0) {
    return '';
  }

  return Uri.https(
    'staticmap.openstreetmap.de',
    '/staticmap.php',
    <String, String>{
      'center': '$latitude,$longitude',
      'zoom': '$zoom',
      'size': size,
      'maptype': 'mapnik',
      'markers': '$latitude,$longitude,red-pushpin',
    },
  ).toString();
}
