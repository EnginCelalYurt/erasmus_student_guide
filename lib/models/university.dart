class UniversityProfile {
  final String name;
  final String nativeName;
  final String shortName;
  final String city;
  final String country;
  final String establishedYear;
  final String studentCount;
  final String websiteUrl;
  final String description;
  final List<CampusLocation> campuses;
  final List<CampusFacility> facilities;
  final List<StudentClub> clubs;
  final List<EmergencyContact> emergencyContacts;

  const UniversityProfile({
    required this.name,
    required this.nativeName,
    required this.shortName,
    required this.city,
    required this.country,
    required this.establishedYear,
    required this.studentCount,
    required this.websiteUrl,
    required this.description,
    required this.campuses,
    required this.facilities,
    required this.clubs,
    required this.emergencyContacts,
  });
}

class CampusLocation {
  final String id;
  final String name;
  final String address;
  final String description;
  final List<String> faculties;
  final String mapsQuery;

  const CampusLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.faculties,
    required this.mapsQuery,
  });
}

class CampusFacility {
  final String id;
  final String name;
  final String category; // 'Library', 'Dining', 'Dorms', 'Sports', 'Admin', 'Medical'
  final String location;
  final String hours;
  final String description;
  final String studentTips;
  final String iconName;
  final String mapsQuery;
  final String? actionLabel;
  final String? actionUrl;

  const CampusFacility({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.hours,
    required this.description,
    required this.studentTips,
    required this.iconName,
    required this.mapsQuery,
    this.actionLabel,
    this.actionUrl,
  });
}

class StudentClub {
  final String id;
  final String name;
  final String category; // 'International', 'Technology', 'Sports', 'Culture'
  final String description;
  final String contact;

  const StudentClub({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.contact,
  });
}

class EmergencyContact {
  final String label;
  final String phone;
  final String subtitle;
  final bool isHighlight;

  const EmergencyContact({
    required this.label,
    required this.phone,
    required this.subtitle,
    this.isHighlight = false,
  });
}
