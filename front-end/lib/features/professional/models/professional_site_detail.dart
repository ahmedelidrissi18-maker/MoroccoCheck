import '../../sites/presentation/models/review.dart';
import 'professional_site.dart';

class ProfessionalSiteDetail {
  final ProfessionalSite site;
  final List<ProfessionalOpeningHour> openingHours;
  final List<Review> recentReviews;

  const ProfessionalSiteDetail({
    required this.site,
    required this.openingHours,
    required this.recentReviews,
  });

  factory ProfessionalSiteDetail.fromJson(Map<String, dynamic> json) {
    List<ProfessionalOpeningHour> parseOpeningHours(dynamic value) {
      if (value is! List) return const <ProfessionalOpeningHour>[];
      return value
          .whereType<Map>()
          .map(
            (item) => ProfessionalOpeningHour.fromJson(
              item.map((key, data) => MapEntry(key.toString(), data)),
            ),
          )
          .toList();
    }

    List<Review> parseReviews(dynamic value) {
      if (value is! List) return const <Review>[];
      return value
          .whereType<Map>()
          .map(
            (item) => Review.fromJson(
              item.map((key, data) => MapEntry(key.toString(), data)),
            ),
          )
          .toList();
    }

    final siteJson = json['site'] is Map
        ? (json['site'] as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          )
        : json;

    return ProfessionalSiteDetail(
      site: ProfessionalSite.fromJson(siteJson),
      openingHours: parseOpeningHours(json['opening_hours']),
      recentReviews: parseReviews(json['recent_reviews']),
    );
  }
}

class ProfessionalOpeningHour {
  final String dayOfWeek;
  final String? opensAt;
  final String? closesAt;
  final bool isClosed;
  final bool is24Hours;
  final String notes;

  const ProfessionalOpeningHour({
    required this.dayOfWeek,
    required this.opensAt,
    required this.closesAt,
    required this.isClosed,
    required this.is24Hours,
    required this.notes,
  });

  factory ProfessionalOpeningHour.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final text = '$value'.toLowerCase();
      return text == 'true' || text == '1';
    }

    return ProfessionalOpeningHour(
      dayOfWeek: json['day_of_week'] as String? ?? '',
      opensAt: json['opens_at'] as String?,
      closesAt: json['closes_at'] as String?,
      isClosed: parseBool(json['is_closed']),
      is24Hours: parseBool(json['is_24_hours']),
      notes: json['notes'] as String? ?? '',
    );
  }
}
