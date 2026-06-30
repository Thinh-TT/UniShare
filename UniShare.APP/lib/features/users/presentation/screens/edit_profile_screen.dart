import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../reference/presentation/providers/reference_provider.dart';
import '../../../reference/models/school_dto.dart';
import '../../../reference/models/area_dto.dart';
import '../providers/user_provider.dart';
import '../../models/user_profile_dto.dart';
import '../../models/update_profile_request.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedSchoolId;
  String _selectedSchoolName = 'Chọn trường';
  String? _selectedAreaId;
  String _selectedAreaName = 'Chọn khu vực';

  bool _isInitialized = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initForm(UserProfileDto profile) {
    if (_isInitialized) return;
    _isInitialized = true;

    _fullNameController.text = profile.fullName;
    _emailController.text = profile.email;
    _phoneController.text = profile.phoneNumber ?? '';
    _selectedSchoolId = profile.schoolId;
    _selectedAreaId = profile.areaId;
    if (profile.schoolName != null && profile.schoolName!.isNotEmpty) {
      _selectedSchoolName = profile.schoolName!;
    }
    if (profile.areaName != null && profile.areaName!.isNotEmpty) {
      _selectedAreaName = profile.areaName!;
    }
  }

  Future<void> _showSchoolPicker() async {
    final schoolsAsync = ref.read(schoolsProvider);
    final schools = schoolsAsync.valueOrNull;
    if (schools == null || schools.isEmpty) return;

    final selected = await AppBottomSheet.show<SchoolDto>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chọn trường',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: schools.length,
              itemBuilder: (context, index) {
                final school = schools[index];
                final isSelected = school.id == _selectedSchoolId;
                return ListTile(
                  title: Text(school.name),
                  trailing: isSelected
                      ? const Icon(Icons.check,
                          color: AppColors.green)
                      : null,
                  onTap: () => Navigator.pop(context, school),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedSchoolId = selected.id;
        _selectedSchoolName = selected.name;
      });
    }
  }

  Future<void> _showAreaPicker() async {
    final areasAsync = ref.read(areasProvider);
    final areas = areasAsync.valueOrNull;
    if (areas == null || areas.isEmpty) return;

    final selected = await AppBottomSheet.show<AreaDto>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chọn khu vực',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: areas.length,
              itemBuilder: (context, index) {
                final area = areas[index];
                final isSelected = area.id == _selectedAreaId;
                return ListTile(
                  title: Text(area.name),
                  subtitle: area.city != null
                      ? Text(area.city!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: AppColors.neutral500))
                      : null,
                  trailing: isSelected
                      ? const Icon(Icons.check,
                          color: AppColors.green)
                      : null,
                  onTap: () => Navigator.pop(context, area),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedAreaId = selected.id;
        _selectedAreaName = selected.name;
      });
    }
  }

  String? _validateFullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (trimmed.length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null; // optional
    final phoneRegex = RegExp(r'^0\d{9}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Số điện thoại không hợp lệ (bắt đầu bằng 0, 10 chữ số)';
    }
    return null;
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploadingAvatar) return;

    // Show source picker: camera or gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Chọn ảnh đại diện',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.green),
                title: const Text('Chụp ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.green),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    setState(() => _isUploadingAvatar = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        if (mounted) setState(() => _isUploadingAvatar = false);
        return;
      }

      // Upload to server
      await ref
          .read(userRepositoryProvider)
          .uploadAvatar(pickedFile.path);

      if (!mounted) return;

      // Delete the temporary file
      try {
        final file = File(pickedFile.path);
        if (file.existsSync()) file.deleteSync();
      } catch (_) {}

      // Invalidate profile provider so all screens reflect the new avatar
      ref.invalidate(userProfileProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is AppException
          ? e.message
          : 'Tải ảnh lên thất bại. Vui lòng thử lại.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final request = UpdateProfileRequest(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        schoolId: _selectedSchoolId,
        areaId: _selectedAreaId,
      );
      await ref.read(userRepositoryProvider).updateProfile(request);
      ref.invalidate(userProfileProvider); // Refresh profile data

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final message = e is AppException
          ? e.message
          : 'Cập nhật thất bại. Vui lòng thử lại.';
      setState(() => _errorMessage = message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Sửa hồ sơ'),
      ),
      body: profileAsync.when(
        loading: () =>
            const LoadingState(message: 'Đang tải thông tin...'),
        error: (error, _) => ErrorState(
          message: 'Không thể tải thông tin hồ sơ.\n${error.toString()}',
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        data: (profile) {
          // Initialize form on first load
          Future.microtask(() => _initForm(profile));

          return _buildForm(context, profile);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, UserProfileDto profile) {
    return AbsorbPointer(
      absorbing: _isSaving,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar with upload overlay
              Center(
                child: Stack(
                  children: [
                    UserAvatar(
                      avatarUrl: profile.avatarUrl,
                      fullName: profile.fullName,
                      reputationScore: profile.reputationScore,
                      size: 80,
                      mediaBaseUrl: ref.read(appConfigProvider).mediaBaseUrl,
                    ),
                    if (_isUploadingAvatar)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                child: Text(
                  'Thay đổi ảnh đại diện',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Full name
              AppInput(
                label: 'Họ tên',
                hintText: 'Nhập họ tên đầy đủ',
                controller: _fullNameController,
                validator: _validateFullName,
              ),
              const SizedBox(height: 16),

              // Email (disabled - cannot change)
              AppInput(
                label: 'Email',
                hintText: 'Email không thể thay đổi',
                controller: _emailController,
                enabled: false,
              ),
              const SizedBox(height: 16),

              // Phone
              AppInput(
                label: 'Số điện thoại',
                hintText: 'Không bắt buộc',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),

              // School picker
              _buildPickerTile(
                context: context,
                label: 'Trường học',
                currentValue: _selectedSchoolName,
                icon: Icons.school,
                onTap: _isSaving ? null : _showSchoolPicker,
              ),
              const SizedBox(height: 12),

              // Area picker
              _buildPickerTile(
                context: context,
                label: 'Khu vực',
                currentValue: _selectedAreaName,
                icon: Icons.location_on,
                onTap: _isSaving ? null : _showAreaPicker,
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.danger),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),

              // Save button
              AppButton(
                label: 'Lưu thay đổi',
                onPressed: _handleSave,
                isLoading: _isSaving,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required BuildContext context,
    required String label,
    required String currentValue,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.neutral500),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    currentValue,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _isSelected(currentValue)
                              ? null
                              : AppColors.neutral500,
                        ),
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.neutral200),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isSelected(String value) {
    return value != 'Chọn trường' && value != 'Chọn khu vực';
  }
}
