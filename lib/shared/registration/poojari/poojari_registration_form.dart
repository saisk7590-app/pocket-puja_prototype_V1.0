import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocket_puja/app.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/customer/data/booking/booking_data.dart';
import 'package:pocket_puja/poojari/shell/poojari_shell.dart';
import 'package:pocket_puja/shared/auth/auth_footer_link.dart';
import 'package:pocket_puja/shared/auth/mobile_number_screen.dart';

/// Screen 5: Poojari Registration Form
/// Comprehensive Vedic profile & credential collection.
class PoojariRegistrationForm extends StatefulWidget {
  final String mobile;
  final String fullName;

  const PoojariRegistrationForm({
    super.key,
    required this.mobile,
    required this.fullName,
  });

  @override
  State<PoojariRegistrationForm> createState() => _PoojariRegistrationFormState();
}

class _PoojariRegistrationFormState extends State<PoojariRegistrationForm> {
  final _cityController = TextEditingController();
  final _experienceController = TextEditingController();
  final _trainingController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedPhoto;
  Uint8List? _pickedPhotoBytes;

  String? _selectedRadius;
  final List<String> _radiusOptions = const ['5km', '10km', '15km', '20km+'];

  // Reusing the exact Pooja types defined in customer booking flow
  late final List<String> _availableSpecializations;
  final Set<String> _selectedSpecializations = {};

  final List<String> _availableLanguages = const ['Telugu', 'English', 'Sanskrit', 'Hindi'];
  final Set<String> _selectedLanguages = {'Telugu', 'Sanskrit'};

  String? _pickedCertificateName;
  String? _pickedCertificatePath;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Dynamically extract unique pooja names from Customer booking occasions
    final poojaNames = occasions.expand((occ) => occ.poojas).map((p) => p.name).toSet().toList();
    _availableSpecializations = poojaNames;
    if (_availableSpecializations.isNotEmpty) {
      _selectedSpecializations.add(_availableSpecializations.first);
    }
    _selectedRadius = '10km';
  }

  @override
  void dispose() {
    _cityController.dispose();
    _experienceController.dispose();
    _trainingController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedPhoto = image;
          _pickedPhotoBytes = bytes;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not open gallery: $e');
    }
  }

  Future<void> _pickCertificate() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _pickedCertificateName = file.name;
          _pickedCertificatePath = file.path;
          _errorMessage = null;
        });
      }
    } catch (_) {
      // Fallback: allow picking image if desktop file picker had an issue
      try {
        final XFile? docImage = await _imagePicker.pickImage(source: ImageSource.gallery);
        if (docImage != null) {
          setState(() {
            _pickedCertificateName = docImage.name;
            _pickedCertificatePath = docImage.path;
            _errorMessage = null;
          });
        }
      } catch (err) {
        setState(() => _errorMessage = 'Error selecting certificate: $err');
      }
    }
  }

  void _quickFillDemoPandit() {
    setState(() {
      _cityController.text = 'Hyderabad';
      _experienceController.text = '14';
      _trainingController.text = 'Trained under Sri Sitarama Shastri, Kanchi Kamakoti Peetham';
      _selectedRadius = '15km';
      _selectedSpecializations.addAll(['Ganapathi Homam', 'Satyanarayana Vratam', 'Gruhapravesham']);
      _selectedLanguages.addAll(['Telugu', 'Sanskrit', 'English']);
      _pickedCertificateName = 'vedic_pravesha_certificate.pdf';
      _errorMessage = null;
    });
  }

  void _handleSubmit() {
    // For prototype testing: auto-fill reasonable defaults if omitted
    if (_cityController.text.trim().isEmpty) {
      _cityController.text = 'Hyderabad';
    }
    if (_experienceController.text.trim().isEmpty) {
      _experienceController.text = '10';
    }
    _selectedRadius ??= '10km';
    if (_selectedSpecializations.isEmpty) {
      _selectedSpecializations.add('Ganapathi Homam');
    }
    if (_selectedLanguages.isEmpty) {
      _selectedLanguages.addAll(['Telugu', 'Sanskrit']);
    }
    _pickedCertificateName ??= 'vedic_credentials_proof.pdf';

    final expNum = int.tryParse(_experienceController.text.trim()) ?? 10;

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    final profile = PoojariProfile(
      photoPath: _pickedPhoto?.path,
      city: _cityController.text.trim(),
      serviceRadius: _selectedRadius!,
      experienceYears: expNum,
      trainingLineage: _trainingController.text.trim().isEmpty
          ? 'Trained under Vedic Scholar Lineage'
          : _trainingController.text.trim(),
      specializations: _selectedSpecializations.toList(),
      languages: _selectedLanguages.toList(),
      certificateFileName: _pickedCertificateName,
      certificateFilePath: _pickedCertificatePath,
    );

    // Save Poojari profile to session with status = under_review
    SessionService.instance.registerPoojari(
      mobile: widget.mobile,
      fullName: widget.fullName,
      profile: profile,
    );

    // Direct routing to Poojari Dashboard (PoojariShell) as requested
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => PoojariShell(
          onLogout: () {
            SessionService.instance.logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MobileNumberScreen()),
              (route) => false,
            );
          },
          onSwitchToCustomer: () {
            SessionService.instance.switchRole(AppRole.customer);
          },
        ),
      ),
      (route) => false,
    );
  }

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar & Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                    ),
                    child: const Text(
                      '🪔 VEDIC ONBOARDING',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title & Introduction
              Text(
                'Poojari Credentials',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      shadows: AppTheme.goldGlow,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please provide your Vedic details for verification. You can begin exploring the platform right after submission.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Prototype Quick Fill Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROTOTYPE QUICK FILL',
                            style: TextStyle(
                              color: AppColors.primaryFixed,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Tap to autofill demo Vedic credentials',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _quickFillDemoPandit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Autofill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // -------------------------------------------------------------
              // a. Profile Photo
              // -------------------------------------------------------------
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  children: [
                    Text(
                      'PROFILE PHOTO *',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _pickProfilePhoto,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.12),
                              border: Border.all(
                                color: _pickedPhoto != null || _pickedPhotoBytes != null
                                    ? AppColors.primary
                                    : Colors.white24,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _buildAvatarPreview(),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_library_rounded,
                              size: 16,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _pickProfilePhoto,
                      icon: const Icon(Icons.add_photo_alternate_rounded, size: 16, color: AppColors.primary),
                      label: Text(
                        _pickedPhoto != null ? 'Change Photo' : 'Upload from Gallery',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // b. City / Service Area
              // -------------------------------------------------------------
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CITY / SERVICE AREA *',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _cityController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: const InputDecoration(
                                hintText: 'e.g. Hyderabad, Bengaluru, Vijayawada',
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // c. Service Radius
              // -------------------------------------------------------------
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SERVICE RADIUS *',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Maximum travel distance for performing home pujas',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: _radiusOptions.map((rad) {
                        final isSelected = _selectedRadius == rad;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRadius = rad),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.22)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.white12,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  rad,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.primary : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // d. Years of Experience
              // -------------------------------------------------------------
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YEARS OF EXPERIENCE *',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.workspace_premium_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _experienceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: const InputDecoration(
                                hintText: 'e.g. 10',
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                                suffixText: 'Years',
                                suffixStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // e. Training / Lineage (Optional)
              // -------------------------------------------------------------
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TRAINING & VEDIC LINEAGE',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white70,
                                fontSize: 11,
                                letterSpacing: 1.1,
                              ),
                        ),
                        const Text(
                          '(OPTIONAL)',
                          style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: TextField(
                        controller: _trainingController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Trained under Sri X, Kanchi tradition, Veda Pathashala alumnus',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // f. Specializations (From Customer Booking data)
              // -------------------------------------------------------------
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SPECIALIZATIONS & PUJAS PERFORMED *',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select rituals you specialize in for devotee bookings',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _availableSpecializations.map((spec) {
                        final isSelected = _selectedSpecializations.contains(spec);
                        return FilterChip(
                          label: Text(spec),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedSpecializations.add(spec);
                              } else {
                                _selectedSpecializations.remove(spec);
                              }
                            });
                          },
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          selectedColor: AppColors.primary.withValues(alpha: 0.25),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.white12,
                            width: isSelected ? 1.4 : 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // g. Languages Spoken
              // -------------------------------------------------------------
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LANGUAGES SPOKEN *',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select languages you can fluently converse & perform rituals in',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _availableLanguages.map((lang) {
                        final isSelected = _selectedLanguages.contains(lang);
                        return FilterChip(
                          label: Text(lang),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedLanguages.add(lang);
                              } else {
                                _selectedLanguages.remove(lang);
                              }
                            });
                          },
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          selectedColor: AppColors.primary.withValues(alpha: 0.25),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.white12,
                            width: isSelected ? 1.4 : 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // h. Certificate / ID Upload
              // -------------------------------------------------------------
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CERTIFICATE / ID UPLOAD *',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Veda Pathashala certificate, Temple affiliation, or Govt ID',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    if (_pickedCertificateName != null) ...[
                      // Uploaded state preview row
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.description_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _pickedCertificateName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded, size: 13, color: AppColors.success),
                                      SizedBox(width: 4),
                                      Text(
                                        'Ready for verification review',
                                        style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _pickCertificate,
                              icon: const Icon(Icons.change_circle_outlined, color: AppColors.primary, size: 22),
                              tooltip: 'Change file',
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Empty state tap button
                      GestureDetector(
                        onTap: _pickCertificate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white24,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.upload_file_rounded,
                                  color: AppColors.primary,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Tap to choose PDF or Document Image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Supported formats: PDF, JPG, PNG',
                                style: TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // -------------------------------------------------------------
              // i. Submit Button
              // -------------------------------------------------------------
              PrimaryButton(
                label: 'SUBMIT APPLICATION',
                icon: Icons.check_circle_rounded,
                isLoading: _isSubmitting,
                onTap: _handleSubmit,
              ),

              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Local prototype storage only • No external server uploads',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
              AuthFooterLink.login(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MobileNumberScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    if (_pickedPhotoBytes != null) {
      return Image.memory(
        _pickedPhotoBytes!,
        fit: BoxFit.cover,
        width: 104,
        height: 104,
      );
    } else if (!kIsWeb && _pickedPhoto != null) {
      return Image.file(
        File(_pickedPhoto!.path),
        fit: BoxFit.cover,
        width: 104,
        height: 104,
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_pin_rounded,
            size: 40,
            color: AppColors.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 2),
          const Text(
            'Photo',
            style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
