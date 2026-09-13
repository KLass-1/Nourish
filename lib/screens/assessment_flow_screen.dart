import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../widgets/assessment_progress_bar.dart';
import '../widgets/custom_card.dart';
import '../data/mock_data.dart';

class AssessmentFlowScreen extends StatefulWidget {
  const AssessmentFlowScreen({super.key});

  @override
  State<AssessmentFlowScreen> createState() => _AssessmentFlowScreenState();
}

class _AssessmentFlowScreenState extends State<AssessmentFlowScreen> {
  int _currentStep = 1;
  final int _totalSteps = 4;

  // Form keys and Controllers for Step 1
  final _formKeyStep1 = GlobalKey<FormState>();
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  // Gender selection state
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    // Load values from AppState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = AppStateProvider.of(context);
      _ageController.text = state.currentAssessment.age.toString();
      _heightController.text = state.currentAssessment.height.toString();
      _weightController.text = state.currentAssessment.weight.toString();
      setState(() {
        _selectedGender = state.currentAssessment.gender;
      });
    });

    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _selectedGender = 'Male';
  }

  // Loading state for Gemini analysis
  bool _isLoading = false;

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_isLoading) return;

    if (_currentStep == 1) {
      if (_formKeyStep1.currentState!.validate()) {
        final state = AppStateProvider.of(context);
        state.currentAssessment.age = int.parse(_ageController.text);
        state.currentAssessment.height = double.parse(_heightController.text);
        state.currentAssessment.weight = double.parse(_weightController.text);
        state.currentAssessment.gender = _selectedGender;
        
        setState(() {
          _currentStep++;
        });
      }
    } else if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Step 4: Submit for AI analysis
      _submitAssessment();
    }
  }

  Future<void> _submitAssessment() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final state = AppStateProvider.of(context);

    try {
      await state.submitAssessmentAsync();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, AppRoutes.assessmentResult);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      final errorMessage = error.toString().replaceFirst('Exception: ', '');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Analysis Notice',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            errorMessage,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                // Fallback to local rule engine so user is never blocked
                state.submitAssessment();
                Navigator.pushReplacementNamed(context, AppRoutes.assessmentResult);
              },
              child: const Text('Use Offline Estimate', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                _submitAssessment();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  void _prevStep() {
    if (_isLoading) return;

    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('New Assessment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _isLoading ? null : _prevStep,
          ),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Top Static Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: AssessmentProgressBar(
                      currentStep: _currentStep,
                      totalSteps: _totalSteps,
                    ),
                  ),
                  const Divider(),

                  // Page content Area
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(20.0),
                      child: _buildStepContent(state),
                    ),
                  ),

                  // Bottom Navigation buttons
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        if (_currentStep > 1) ...[
                          Expanded(
                            child: CustomButton(
                              text: 'Back',
                              onPressed: _isLoading ? null : _prevStep,
                              isSecondary: true,
                            ),
                          ),
                          const SizedBox(width: 14),
                        ],
                        Expanded(
                          child: CustomButton(
                            text: _isLoading
                                ? 'Analyzing...'
                                : (_currentStep == _totalSteps ? 'Submit Assessment' : 'Next Step'),
                            onPressed: _isLoading ? null : _nextStep,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Loading overlay during Gemini analysis
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Analyzing your responses...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Connecting with Gemini to estimate potential nutrient gaps.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(AppState state) {
    switch (_currentStep) {
      case 1:
        return _buildStep1BasicInfo();
      case 2:
        return _buildStep2DietLifestyle(state);
      case 3:
        return _buildStep3Symptoms(state);
      case 4:
        return _buildStep4Review(state);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Step 1: Basic Information ---
  Widget _buildStep1BasicInfo() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'We use these metrics to calibrate default nutritional allowances.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Age Input
          CustomInput(
            label: 'Age',
            hintText: 'Enter your age',
            controller: _ageController,
            keyboardType: TextInputType.number,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Age is required';
              final parsed = int.tryParse(val);
              if (parsed == null || parsed <= 0 || parsed > 120) return 'Please enter a valid age';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Gender Selection Label
          const Text(
            'Gender',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Gender Choices row
          Row(
            children: ['Male', 'Female', 'Other'].map((gender) {
              final isSelected = _selectedGender == gender;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryLight : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        gender,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Height & Weight row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomInput(
                  label: 'Height',
                  hintText: 'e.g. 175',
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  suffixText: 'cm',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    final parsed = double.tryParse(val);
                    if (parsed == null || parsed < 50 || parsed > 250) return 'Invalid height';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomInput(
                  label: 'Weight',
                  hintText: 'e.g. 70',
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  suffixText: 'kg',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    final parsed = double.tryParse(val);
                    if (parsed == null || parsed < 20 || parsed > 300) return 'Invalid weight';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Step 2: Diet & Lifestyle ---
  Widget _buildStep2DietLifestyle(AppState state) {
    final answers = state.currentAssessment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diet & Lifestyle habits',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select parameters that closest reflect your typical week.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Diet Type Section
        _buildChoiceSection(
          title: 'Dietary Preference',
          options: MockData.dietTypes,
          selectedOption: answers.dietType,
          onSelected: (option) {
            setState(() {
              answers.dietType = option;
            });
          },
        ),
        const SizedBox(height: 24),

        // Water Intake Section
        _buildChoiceSection(
          title: 'Daily Water Intake',
          options: MockData.waterIntakes,
          selectedOption: answers.waterIntake,
          onSelected: (option) {
            setState(() {
              answers.waterIntake = option;
            });
          },
        ),
        const SizedBox(height: 24),

        // Exercise Frequency Section
        _buildChoiceSection(
          title: 'Physical Activity Frequency',
          options: MockData.exerciseFrequencies,
          selectedOption: answers.exerciseFrequency,
          onSelected: (option) {
            setState(() {
              answers.exerciseFrequency = option;
            });
          },
        ),
        const SizedBox(height: 24),

        // Sunlight Exposure Section
        _buildChoiceSection(
          title: 'Direct Sunlight Exposure',
          options: MockData.sunlightExposures,
          selectedOption: answers.sunlightExposure,
          onSelected: (option) {
            setState(() {
              answers.sunlightExposure = option;
            });
          },
        ),
        const SizedBox(height: 24),

        // Sleep Duration Slider
        const Text(
          'Average Daily Sleep',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: answers.sleepDuration,
                min: 4.0,
                max: 12.0,
                divisions: 16,
                activeColor: AppTheme.primary,
                inactiveColor: AppTheme.border,
                onChanged: (val) {
                  setState(() {
                    answers.sleepDuration = val;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${answers.sleepDuration.toStringAsFixed(1)} hrs',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceSection({
    required String title,
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: options.map((option) {
            final isSelected = selectedOption == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              selectedColor: AppTheme.primaryLight,
              disabledColor: AppTheme.surface,
              backgroundColor: AppTheme.surface,
              checkmarkColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                  width: 1.0,
                ),
              ),
              onSelected: (bool selected) {
                if (selected) {
                  onSelected(option);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Step 3: Symptoms ---
  Widget _buildStep3Symptoms(AppState state) {
    final answers = state.currentAssessment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Symptom Check',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select symptoms you have experienced recently.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 18),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: MockData.symptomsList.length,
          itemBuilder: (context, index) {
            final symptom = MockData.symptomsList[index];
            final isSelected = answers.symptoms.contains(symptom);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: CheckboxListTile(
                title: Text(
                  symptom,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                value: isSelected,
                activeColor: AppTheme.primary,
                checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                tileColor: isSelected ? AppTheme.primaryLight.withOpacity(0.1) : AppTheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary.withOpacity(0.3) : AppTheme.border,
                  ),
                ),
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked == true) {
                      if (!answers.symptoms.contains(symptom)) {
                        answers.symptoms.add(symptom);
                      }
                    } else {
                      answers.symptoms.remove(symptom);
                    }
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // --- Step 4: Review ---
  Widget _buildStep4Review(AppState state) {
    final answers = state.currentAssessment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review assessment details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Confirm that the entries below are accurate before calculating results.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Section: Profile
        _buildReviewSection(
          title: 'Basic Information',
          children: [
            _buildReviewRow('Age', '${answers.age} years old'),
            _buildReviewRow('Gender', answers.gender),
            _buildReviewRow('Height', '${answers.height} cm'),
            _buildReviewRow('Weight', '${answers.weight} kg'),
          ],
        ),
        const SizedBox(height: 18),

        // Section: Lifestyle
        _buildReviewSection(
          title: 'Diet & Lifestyle',
          children: [
            _buildReviewRow('Dietary Preference', answers.dietType),
            _buildReviewRow('Water Intake', answers.waterIntake),
            _buildReviewRow('Average Sleep', '${answers.sleepDuration.toStringAsFixed(1)} hours'),
            _buildReviewRow('Physical Activity', answers.exerciseFrequency),
            _buildReviewRow('Sunlight Exposure', answers.sunlightExposure),
          ],
        ),
        const SizedBox(height: 18),

        // Section: Symptoms
        _buildReviewSection(
          title: 'Logged Symptoms',
          children: [
            if (answers.symptoms.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'No symptoms selected.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: answers.symptoms.map((symptom) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        symptom,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewSection({
    required String title,
    required List<Widget> children,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
