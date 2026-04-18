import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import 'client_dashboard_screen.dart';

/// Setup profile screen forces new users to finish filling out their
/// details after registration completes.
class ClientProfileSetupScreen extends StatefulWidget {
  final Map<String, dynamic> client;

  const ClientProfileSetupScreen({super.key, required this.client});

  @override
  State<ClientProfileSetupScreen> createState() =>
      _ClientProfileSetupScreenState();
}

class _ClientProfileSetupScreenState extends State<ClientProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();

  File? _pickedImage;
  bool _isSaving = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    _populateFields();
  }

  void _populateFields() {
    final client = widget.client;
    final name = client['name'] as String? ?? '';
    
    // Only pre-fill if it's an existing filled profile (name is not empty dummy)
    if (name.isNotEmpty) {
      _nameCtrl.text = name;
      
      final age = client['age'] as int? ?? 0;
      if (age > 0) _ageCtrl.text = age.toString();

      final weight = client['weight'] as num? ?? 0;
      if (weight > 0) _weightCtrl.text = weight.toString();

      final height = client['height'] as num? ?? 0;
      if (height > 0) _heightCtrl.text = height.toString();

      final goal = client['goal'] as String? ?? '';
      if (goal.isNotEmpty) _goalCtrl.text = goal;

      final profilePic = client['profile_pic_path'] as String? ?? '';
      if (profilePic.isNotEmpty) {
        final file = File(profilePic);
        if (file.existsSync()) _pickedImage = file;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _goalCtrl.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Image capture ───────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (xfile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}${p.extension(xfile.path)}';
    final savedImage =
        await File(xfile.path).copy(p.join(appDir.path, fileName));

    setState(() => _pickedImage = savedImage);
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Photo Source',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _sourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      gradient: AppTheme.accentGradient,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _sourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      gradient: AppTheme.pinkGradient,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Save profile ────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedUser = Map<String, dynamic>.from(widget.client);
      updatedUser['name'] = _nameCtrl.text.trim();
      updatedUser['age'] = int.parse(_ageCtrl.text.trim());
      updatedUser['weight'] = double.parse(_weightCtrl.text.trim());
      updatedUser['height'] = double.parse(_heightCtrl.text.trim());
      updatedUser['goal'] = _goalCtrl.text.trim();
      updatedUser['profile_pic_path'] = _pickedImage?.path ?? '';

      await DatabaseHelper.instance.updateUser(updatedUser);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: ClientDashboardScreen(client: updatedUser),
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isEdit = (widget.client['name'] as String? ?? '').isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Profile' : 'Setup Profile'),
        automaticallyImplyLeading: isEdit,
        leading: isEdit
            ? IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: AppTheme.glassMorphism(borderRadius: 12, opacity: 0.1),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Tell us about yourself to complete your profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ── Profile picture ──
                    _buildAvatarSection(),
                    const SizedBox(height: 32),
                    // ── Form fields ──
                    _buildField(_nameCtrl, 'Full Name', Icons.person_rounded),
                    const SizedBox(height: 16),
                    _buildField(_ageCtrl, 'Age', Icons.cake_rounded,
                        keyboard: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildField(
                        _weightCtrl, 'Weight (kg)', Icons.monitor_weight_rounded,
                        keyboard:
                            const TextInputType.numberWithOptions(decimal: true)),
                    const SizedBox(height: 16),
                    _buildField(
                        _heightCtrl, 'Height (cm)', Icons.height_rounded,
                        keyboard:
                            const TextInputType.numberWithOptions(decimal: true)),
                    const SizedBox(height: 16),
                    _buildField(
                        _goalCtrl, 'Fitness Goal', Icons.flag_rounded,
                        maxLines: 2),
                    const SizedBox(height: 36),
                    // ── Submit ──
                    GradientButton(
                      text: isEdit ? 'Save Changes' : 'Complete Setup',
                      icon: Icons.check_circle_rounded,
                      onPressed: _saveProfile,
                      isLoading: _isSaving,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Reusable field builder ──────────────────────────────────────────────
  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: AppTheme.inputDecoration(label: label, icon: icon),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return '$label is required';
        }
        if (keyboard == TextInputType.number) {
          if (int.tryParse(val.trim()) == null) return 'Enter a valid number';
        }
        if (keyboard ==
            const TextInputType.numberWithOptions(decimal: true)) {
          if (double.tryParse(val.trim()) == null) {
            return 'Enter a valid number';
          }
        }
        return null;
      },
    );
  }

  // ── Avatar section ──────────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _pickedImage == null
                      ? AppTheme.accentGradient
                      : null,
                  image: _pickedImage != null
                      ? DecorationImage(
                          image: FileImage(_pickedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPurple.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _pickedImage == null
                    ? const Icon(Icons.person_rounded,
                        size: 48, color: Colors.white70)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.pinkGradient,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    size: 18, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _pickedImage == null ? 'Tap to add photo' : 'Tap to change photo',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
