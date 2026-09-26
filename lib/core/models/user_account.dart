import 'package:pocket_puja/app.dart';

/// Status of Poojari verification
enum PoojariVerificationStatus {
  underReview,
  verified,
  rejected;

  String get label {
    switch (this) {
      case PoojariVerificationStatus.underReview:
        return 'Under Review';
      case PoojariVerificationStatus.verified:
        return 'Verified';
      case PoojariVerificationStatus.rejected:
        return 'Rejected';
    }
  }

  String get code {
    switch (this) {
      case PoojariVerificationStatus.underReview:
        return 'under_review';
      case PoojariVerificationStatus.verified:
        return 'verified';
      case PoojariVerificationStatus.rejected:
        return 'rejected';
    }
  }

  static PoojariVerificationStatus fromCode(String code) {
    switch (code) {
      case 'verified':
        return PoojariVerificationStatus.verified;
      case 'rejected':
        return PoojariVerificationStatus.rejected;
      case 'under_review':
      default:
        return PoojariVerificationStatus.underReview;
    }
  }
}

/// Profile details for Customer / Devotee matching the inner app profile
class CustomerProfile {
  final String city;
  final String? dob;
  final String? rashi;
  final String? gothram;

  const CustomerProfile({
    this.city = 'Hyderabad',
    this.dob = '15 Aug 1995',
    this.rashi = 'Simha (సింహ)',
    this.gothram = 'Kashyapa (కాశ్యప)',
  });

  CustomerProfile copyWith({
    String? city,
    String? dob,
    String? rashi,
    String? gothram,
  }) {
    return CustomerProfile(
      city: city ?? this.city,
      dob: dob ?? this.dob,
      rashi: rashi ?? this.rashi,
      gothram: gothram ?? this.gothram,
    );
  }
}

/// Profile details submitted during Poojari registration
class PoojariProfile {
  final String? photoPath;
  final String city;
  final String serviceRadius;
  final int experienceYears;
  final String? trainingLineage;
  final List<String> specializations;
  final List<String> languages;
  final String? certificateFileName;
  final String? certificateFilePath;

  const PoojariProfile({
    this.photoPath,
    required this.city,
    required this.serviceRadius,
    required this.experienceYears,
    this.trainingLineage,
    required this.specializations,
    required this.languages,
    this.certificateFileName,
    this.certificateFilePath,
  });

  PoojariProfile copyWith({
    String? photoPath,
    String? city,
    String? serviceRadius,
    int? experienceYears,
    String? trainingLineage,
    List<String>? specializations,
    List<String>? languages,
    String? certificateFileName,
    String? certificateFilePath,
  }) {
    return PoojariProfile(
      photoPath: photoPath ?? this.photoPath,
      city: city ?? this.city,
      serviceRadius: serviceRadius ?? this.serviceRadius,
      experienceYears: experienceYears ?? this.experienceYears,
      trainingLineage: trainingLineage ?? this.trainingLineage,
      specializations: specializations ?? this.specializations,
      languages: languages ?? this.languages,
      certificateFileName: certificateFileName ?? this.certificateFileName,
      certificateFilePath: certificateFilePath ?? this.certificateFilePath,
    );
  }
}

/// User account model for both Customer and Poojari
class UserAccount {
  final String mobile;
  final String fullName;
  final AppRole role;
  final PoojariVerificationStatus poojariStatus;
  final PoojariProfile? poojariProfile;
  final CustomerProfile? customerProfile;

  const UserAccount({
    required this.mobile,
    required this.fullName,
    required this.role,
    this.poojariStatus = PoojariVerificationStatus.underReview,
    this.poojariProfile,
    this.customerProfile,
  });

  bool get isPoojari => role == AppRole.poojari;
  bool get isCustomer => role == AppRole.customer;
  bool get isVerified => poojariStatus == PoojariVerificationStatus.verified;
  bool get isUnderReview => poojariStatus == PoojariVerificationStatus.underReview;

  UserAccount copyWith({
    String? mobile,
    String? fullName,
    AppRole? role,
    PoojariVerificationStatus? poojariStatus,
    PoojariProfile? poojariProfile,
    CustomerProfile? customerProfile,
  }) {
    return UserAccount(
      mobile: mobile ?? this.mobile,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      poojariStatus: poojariStatus ?? this.poojariStatus,
      poojariProfile: poojariProfile ?? this.poojariProfile,
      customerProfile: customerProfile ?? this.customerProfile,
    );
  }
}
