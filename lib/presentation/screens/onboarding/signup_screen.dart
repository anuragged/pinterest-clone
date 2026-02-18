import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/auth_provider.dart';

/// Sign-up flow matching Figma design exactly.
/// Multi-step form: Email → Password → Age → Gender → Country → Interests.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 6;
  static const int _coreSteps = 3; // Email, Password, Age are shown as 1-3

  // Form data
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  String _selectedCountry = 'United States';
  bool _showPassword = false;
  final Set<String> _selectedInterests = {};

  static const _genderOptions = ['Female', 'Male', 'Specify another'];

  static const _countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'India',
    'Japan',
    'Brazil',
    'Mexico',
  ];

  static const _interestTopics = [
    {'name': 'Architecture', 'image': 'https://images.pexels.com/photos/256150/pexels-photo-256150.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Photography', 'image': 'https://images.pexels.com/photos/1983037/pexels-photo-1983037.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Cars', 'image': 'https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Art', 'image': 'https://images.pexels.com/photos/1183992/pexels-photo-1183992.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Travel', 'image': 'https://images.pexels.com/photos/2662116/pexels-photo-2662116.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Nature', 'image': 'https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Fashion', 'image': 'https://images.pexels.com/photos/1536619/pexels-photo-1536619.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Food', 'image': 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Home Decor', 'image': 'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Fitness', 'image': 'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'DIY', 'image': 'https://images.pexels.com/photos/1109197/pexels-photo-1109197.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Beauty', 'image': 'https://images.pexels.com/photos/2113855/pexels-photo-2113855.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Music', 'image': 'https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Gaming', 'image': 'https://images.pexels.com/photos/3165335/pexels-photo-3165335.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Quotes', 'image': 'https://images.pexels.com/photos/2740956/pexels-photo-2740956.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Animals', 'image': 'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Design', 'image': 'https://images.pexels.com/photos/196644/pexels-photo-196644.jpeg?auto=compress&cs=tinysrgb&w=200'},
    {'name': 'Technology', 'image': 'https://images.pexels.com/photos/546819/pexels-photo-546819.jpeg?auto=compress&cs=tinysrgb&w=200'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeSignUp();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.pop();
    }
  }

  void _completeSignUp() {
    Haptics.heavy();
    final name = _emailController.text.split('@').first;
    ref.read(authProvider.notifier).signIn(
          displayName: name.isNotEmpty ? name : 'User',
          email: _emailController.text,
        );
    context.go('/');
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _emailController.text.contains('@');
      case 1:
        return _passwordController.text.length >= 6;
      case 2:
        return _ageController.text.isNotEmpty &&
            int.tryParse(_ageController.text) != null;
      case 3:
        return _selectedGender != null;
      case 4:
        return true;
      case 5:
        return _selectedInterests.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: _previousStep,
          icon: Icon(
            Icons.chevron_left,
            size: 32,
            color: isDark ? Colors.white : Colors.black54,
          ),
        ),
        title: const Text(
          'Sign up',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Pages ──
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEmailStep(),
                _buildPasswordStep(),
                _buildAgeStep(),
                _buildGenderStep(),
                _buildCountryStep(),
                _buildInterestsStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$step of $total',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildCustomProgressBar(step / total),
        ],
      ),
    );
  }

  Widget _buildCustomProgressBar(double progress) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // Track
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Progress
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Indicator Handle (Pink Circle)
        LayoutBuilder(
          builder: (context, constraints) {
            final leftOffset = constraints.maxWidth * progress - 6;
            return Positioned(
              left: leftOffset,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF00FF), // Magenta/Pink exactly
                    width: 2,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Step 1: Email ──
  Widget _buildEmailStep() {
    return _buildStepLayout(
      title: "What's your email?",
      step: 1,
      total: _coreSteps,
      child: TextField(
        controller: _emailController,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) => setState(() {}),
        cursorColor: Colors.red,
        decoration: _minimalInputDecoration('john.smith@mail.com').copyWith(
          suffixIcon: _emailController.text.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.cancel, color: Colors.black12, size: 24),
                onPressed: () {
                  _emailController.clear();
                  setState(() {});
                },
              )
            : null,
        ),
        style: _inputTextStyle(),
      ),
    );
  }

  // ── Step 2: Password ──
  Widget _buildPasswordStep() {
    return _buildStepLayout(
      title: 'Create a password',
      step: 2,
      total: _coreSteps,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _passwordController,
            autofocus: true,
            obscureText: !_showPassword,
            obscuringCharacter: '●',
            onChanged: (_) => setState(() {}),
            cursorColor: Colors.red,
            decoration: _minimalInputDecoration('••••'),
            style: _inputTextStyle().copyWith(fontSize: 24, letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => setState(() => _showPassword = !_showPassword),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black26,
                        width: 1,
                      ),
                      color: _showPassword ? Colors.black : Colors.transparent,
                    ),
                    child: _showPassword 
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Show password',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Age ──
  Widget _buildAgeStep() {
    final name = _emailController.text.split('@').first;
    return _buildStepLayout(
      title: 'How old are you?',
      subtitle: 'This helps us find you more relevant content. We won’t show it on your profile.',
      step: 3,
      total: _coreSteps,
      headerChild: Row(
        children: [
          Text(
            'Hi $name',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PinColors.pinterestRed,
            ),
          ),
          const SizedBox(width: 4),
           const Icon(Icons.edit, size: 14, color: PinColors.pinterestRed),
        ],
      ),
      child: TextField(
        controller: _ageController,
        autofocus: true,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: _minimalInputDecoration('Age').copyWith(
          counterText: '',
        ),
        cursorColor: Colors.red,
        style: _inputTextStyle(),
        maxLength: 3,
      ),
    );
  }

  // ── Step 4: Gender ──
  Widget _buildGenderStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildStepLayout(
      title: 'What\'s your gender?',
      subtitle: 'This helps us find you more relevant content',
      child: Column(
        children: _genderOptions.map((gender) {
          final isSelected = _selectedGender == gender;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Haptics.light();
                setState(() => _selectedGender = gender);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? PinColors.pinterestRed.withValues(alpha: 0.1)
                      : isDark
                          ? const Color(0xFF222222)
                          : PinColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? PinColors.pinterestRed
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        gender,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : PinColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: PinColors.pinterestRed,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Step 5: Country ──
  Widget _buildCountryStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildStepLayout(
      title: 'Pick your country',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222222) : PinColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedCountry,
            dropdownColor: isDark ? const Color(0xFF333333) : Colors.white,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.white : PinColors.textPrimary,
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : PinColors.textPrimary,
            ),
            items: _countries.map((c) {
              return DropdownMenuItem(value: c, child: Text(c));
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedCountry = v);
            },
          ),
        ),
      ),
    );
  }

  // ── Step 6: Interests ──
  Widget _buildInterestsStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick 1 or more topics you like',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : PinColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll use these to personalize your home feed',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : PinColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_selectedInterests.length} selected',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _selectedInterests.isNotEmpty
                  ? PinColors.success
                  : PinColors.pinterestRed,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: _interestTopics.length,
              itemBuilder: (context, index) {
                final topic = _interestTopics[index];
                final isSelected = _selectedInterests.contains(topic['name']);
                return GestureDetector(
                  onTap: () {
                    Haptics.light();
                    setState(() {
                      if (isSelected) {
                        _selectedInterests.remove(topic['name']);
                      } else {
                        _selectedInterests.add(topic['name']!);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? PinColors.pinterestRed
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            topic['image']!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: PinColors.shimmerBase,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Text(
                              topic['name']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: PinColors.pinterestRed,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: PinDimensions.buttonHeightLarge,
            child: ElevatedButton(
              onPressed: _canProceed ? _completeSignUp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: PinColors.pinterestRed,
                foregroundColor: Colors.white,
                disabledBackgroundColor: PinColors.backgroundWash,
                disabledForegroundColor: PinColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PinDimensions.buttonRadius),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLayout({
    required String title,
    required Widget child,
    String? subtitle,
    Widget? headerChild,
    int? step,
    int? total,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          if (headerChild != null) ...[
            headerChild,
            const SizedBox(height: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -1.0,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 24),
          child,
          const Spacer(),
          if (step != null && total != null) ...[
             _buildStepIndicator(step, total),
             const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _canProceed ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: PinColors.pinterestRed,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFF0F0F0),
                disabledForegroundColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _minimalInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black12,
      ),
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    );
  }

  TextStyle _inputTextStyle() {
    return const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );
  }
}
