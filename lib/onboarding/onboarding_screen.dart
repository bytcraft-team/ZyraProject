import 'package:flutter/material.dart';
import 'package:zyra/onboarding/cycle_dashboard.dart';
import 'package:zyra/onboarding/onboarding_model.dart';
import 'package:zyra/onboarding/onboarding_service.dart';
import 'package:zyra/pregnancy/pregnancy_tracker_screen.dart';

class _TrimesterTheme {
  final Color iconBg,
      titleColor,
      subColor,
      ringColor,
      fillColor,
      labelColor,
      arrowColor;
  const _TrimesterTheme({
    required this.iconBg,
    required this.titleColor,
    required this.subColor,
    required this.ringColor,
    required this.fillColor,
    required this.labelColor,
    required this.arrowColor,
  });
}

const _t1 = _TrimesterTheme(
  iconBg: Color(0xFFF1E7FA), // Light lavender
  titleColor: Color(0xFF9C27E8), // Purple
  subColor: Color(0xFFC86CF3), // Soft purple
  ringColor: Color(0xFFC86CF3), // Soft purple
  fillColor: Color(0xFFF1E7FA), // Light lavender
  labelColor: Color(0xFF9C27E8), // Purple
  arrowColor: Color(0xFFC86CF3), // Soft purple
);

const _t2 = _TrimesterTheme(
  iconBg: Color(0xFFFDECF5), // Light pink background
  titleColor: Color(0xFFE91E8F), // Primary pink
  subColor: Color(0xFFFF2DA3), // Gradient pink
  ringColor: Color(0xFFFF2DA3), // Gradient pink
  fillColor: Color(0xFFFFF5F8), // Very light pink
  labelColor: Color(0xFFE91E8F), // Primary pink
  arrowColor: Color(0xFFF8DDE8), // Calendar pink circles
);

const _t3 = _TrimesterTheme(
  iconBg: Color(0xFFFAD7E8), // Bottom navbar active bg
  titleColor: Color(0xFFE91E8F), // Primary pink
  subColor: Color(0xFFC86CF3), // Soft purple
  ringColor: Color(0xFFF8DDE8), // Calendar pink circles
  fillColor: Color(0xFFFFF5F8), // Very light pink
  labelColor: Color(0xFF9C27E8), // Purple
  arrowColor: Color(0xFFF8DDE8), // Calendar pink circles
);

class OnboardingEntryPage extends StatelessWidget {
  const OnboardingEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_t2.fillColor, _t3.fillColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Welcome to Luna',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _t3.titleColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your journey to calm, confident cycle and pregnancy support begins here.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _t3.titleColor.withOpacity(0.78),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                Expanded(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: _t1.fillColor,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0x26F8DDE8),
                            blurRadius: 26,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.self_improvement,
                            size: 60,
                            color: Color(0xFFE91E8F),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Are you currently pregnant?',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _t3.titleColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Your answer helps us give you the most relevant experience, questions, and guidance.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _t3.titleColor.withOpacity(0.7),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _LargeChoiceButton(
                            icon: Icons.pregnant_woman,
                            label: 'Yes, I am pregnant',
                            gradient: LinearGradient(
                              colors: [_t2.titleColor, _t2.subColor],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OnboardingFlowScreen(
                                    profileType: UserProfileType.pregnancy,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _LargeChoiceButton(
                            icon: Icons.calendar_month,
                            label: 'No, I want period tracking',
                            gradient: LinearGradient(
                              colors: [_t3.titleColor, _t3.subColor],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OnboardingFlowScreen(
                                    profileType: UserProfileType.cycle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Comfort-first onboarding with calm, expert-led questions.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _t3.labelColor.withOpacity(0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key, required this.profileType});

  final UserProfileType profileType;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final TextEditingController _pregnancyWeekController = TextEditingController(
    text: '12',
  );
  final TextEditingController _cycleLengthController = TextEditingController(
    text: '28',
  );
  final TextEditingController _periodDurationController = TextEditingController(
    text: '5',
  );

  int _currentStep = 0;
  int _pregnancyWeek = 12;
  DateTime? _lmpDate;
  bool _firstPregnancy = false;
  bool _weeklyUpdates = true;
  bool _nutritionTips = true;
  int _cycleLength = 28;
  int _periodDuration = 5;
  DateTime? _lastPeriodDate;
  bool _cycleRegular = true;
  bool _remindersEnabled = true;

  bool get _isPregnancyFlow => widget.profileType == UserProfileType.pregnancy;

  int get _totalSteps => 5;

  bool get _isCurrentStepValid {
    if (_isPregnancyFlow) {
      switch (_currentStep) {
        case 0:
          return _pregnancyWeek >= 1 && _pregnancyWeek <= 44;
        case 1:
          return _lmpDate != null;
        case 2:
          return true;
        case 3:
          return true;
        case 4:
          return true;
        default:
          return false;
      }
    }

    switch (_currentStep) {
      case 0:
        return _cycleLength >= 21 && _cycleLength <= 42;
      case 1:
        return _periodDuration >= 2 && _periodDuration <= 12;
      case 2:
        return _lastPeriodDate != null;
      case 3:
        return true;
      case 4:
        return true;
      default:
        return false;
    }
  }

  String get _stepTitle {
    if (_isPregnancyFlow) {
      switch (_currentStep) {
        case 0:
          return 'What is your current pregnancy week?';
        case 1:
          return 'What was the date of your last menstrual period?';
        case 2:
          return 'Is this your first pregnancy?';
        case 3:
          return 'Would you like weekly pregnancy updates?';
        case 4:
          return 'Would you like personalized pregnancy nutrition tips?';
      }
    } else {
      switch (_currentStep) {
        case 0:
          return 'What is your average cycle length?';
        case 1:
          return 'How many days does your period usually last?';
        case 2:
          return 'What was the date of your last period?';
        case 3:
          return 'Is your cycle regular or irregular?';
        case 4:
          return 'Would you like reminders for period and ovulation?';
      }
    }
    return '';
  }

  String get _stepSubtitle {
    if (_isPregnancyFlow) {
      switch (_currentStep) {
        case 0:
          return 'This helps us tailor weekly growth and baby development insights.';
        case 1:
          return 'A precise LMP date improves your due-date predictions.';
        case 2:
          return 'We can personalize support based on prior pregnancy experience.';
        case 3:
          return 'Weekly summaries keep you informed without overwhelming you.';
        case 4:
          return 'Nutrition tips can help you feel nourished through each trimester.';
      }
    } else {
      switch (_currentStep) {
        case 0:
          return 'Typical cycle length helps forecast your next period and fertile window.';
        case 1:
          return 'Knowing your typical flow duration improves period reminders.';
        case 2:
          return 'This date sets the calendar for the next cycle estimate.';
        case 3:
          return 'A regular or irregular cycle changes prediction sensitivity.';
        case 4:
          return 'Reminders help you plan ahead with calm, supportive alerts.';
      }
    }
    return '';
  }

  Future<void> _pickDate(BuildContext context, bool forLmp) async {
    final now = DateTime.now();
    final initialDate = now;
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _t2.titleColor,
              onPrimary: Colors.white,
              onSurface: _t3.titleColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _t2.subColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (forLmp) {
          _lmpDate = picked;
        } else {
          _lastPeriodDate = picked;
        }
      });
    }
  }

  Future<void> _finishOnboarding() async {
    final data = OnboardingData(
      profileType: widget.profileType,
      pregnancyWeek: _pregnancyWeek,
      lastMenstrualPeriodDate: _lmpDate,
      firstPregnancy: _firstPregnancy,
      weeklyUpdates: _weeklyUpdates,
      nutritionTips: _nutritionTips,
      averageCycleLength: _cycleLength,
      periodDuration: _periodDuration,
      lastPeriodDate: _lastPeriodDate,
      cycleRegular: _cycleRegular,
      remindersEnabled: _remindersEnabled,
    );
    await OnboardingService.saveOnboardingData(data);

    if (_isPregnancyFlow) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PregnancyHomePage()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CycleDashboardPage()),
        (route) => false,
      );
    }
  }

  void _goNext() {
    if (_currentStep == _totalSteps - 1) {
      _finishOnboarding();
      return;
    }
    setState(() => _currentStep += 1);
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => _currentStep -= 1);
  }

  @override
  void dispose() {
    _pregnancyWeekController.dispose();
    _cycleLengthController.dispose();
    _periodDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _t2.fillColor,
        foregroundColor: _t3.titleColor,
        elevation: 0,
        title: Text(_isPregnancyFlow ? 'Pregnancy Setup' : 'Cycle Setup'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: _goBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step ${_currentStep + 1} of $_totalSteps',
              style: theme.textTheme.labelLarge?.copyWith(
                color: _t3.labelColor.withOpacity(0.88),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _totalSteps,
                minHeight: 8,
                color: _t2.subColor,
                backgroundColor: _t2.arrowColor,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.2, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _buildStep(context, theme),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isCurrentStepValid ? _goNext : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _t2.titleColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _currentStep == _totalSteps - 1
                          ? 'Finish and continue'
                          : 'Continue',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      key: ValueKey<int>(_currentStep),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _stepTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: _t3.titleColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _stepSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _t3.titleColor.withOpacity(0.78),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 26),
          Card(
            color: _t2.fillColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: _buildStepInput(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepInput(BuildContext context) {
    if (_isPregnancyFlow) {
      switch (_currentStep) {
        case 0:
          return _NumericField(
            controller: _pregnancyWeekController,
            label: 'Pregnancy week',
            suffix: 'weeks',
            onChanged: (value) {
              setState(() {
                _pregnancyWeek = int.tryParse(value) ?? 0;
              });
            },
          );
        case 1:
          return _DatePickerCard(
            label: _lmpDate == null
                ? 'Select LMP date'
                : 'LMP date: ${_formatDate(_lmpDate!)}',
            onTap: () => _pickDate(context, true),
          );
        case 2:
          return _ToggleChoiceGroup(
            options: const ['Yes', 'No'],
            labels: const ['First pregnancy', 'Not first pregnancy'],
            selectedIndex: _firstPregnancy ? 0 : 1,
            onSelected: (index) {
              setState(() {
                _firstPregnancy = index == 0;
              });
            },
          );
        case 3:
          return _ToggleChoiceGroup(
            options: const ['Yes', 'No'],
            labels: const ['Weekly updates on', 'Weekly updates off'],
            selectedIndex: _weeklyUpdates ? 0 : 1,
            onSelected: (index) {
              setState(() {
                _weeklyUpdates = index == 0;
              });
            },
          );
        case 4:
          return _ToggleChoiceGroup(
            options: const ['Yes', 'No'],
            labels: const ['Nutrition tips on', 'Nutrition tips off'],
            selectedIndex: _nutritionTips ? 0 : 1,
            onSelected: (index) {
              setState(() {
                _nutritionTips = index == 0;
              });
            },
          );
      }
    } else {
      switch (_currentStep) {
        case 0:
          return _NumericField(
            controller: _cycleLengthController,
            label: 'Average cycle length',
            suffix: 'days',
            onChanged: (value) {
              setState(() {
                _cycleLength = int.tryParse(value) ?? 0;
              });
            },
          );
        case 1:
          return _NumericField(
            controller: _periodDurationController,
            label: 'Period duration',
            suffix: 'days',
            onChanged: (value) {
              setState(() {
                _periodDuration = int.tryParse(value) ?? 0;
              });
            },
          );
        case 2:
          return _DatePickerCard(
            label: _lastPeriodDate == null
                ? 'Select last period date'
                : 'Date: ${_formatDate(_lastPeriodDate!)}',
            onTap: () => _pickDate(context, false),
          );
        case 3:
          return _ToggleChoiceGroup(
            options: const ['Regular', 'Irregular'],
            labels: const ['Regular cycle', 'Irregular cycle'],
            selectedIndex: _cycleRegular ? 0 : 1,
            onSelected: (index) {
              setState(() {
                _cycleRegular = index == 0;
              });
            },
          );
        case 4:
          return _ToggleChoiceGroup(
            options: const ['Yes', 'No'],
            labels: const ['Reminders enabled', 'Reminders skipped'],
            selectedIndex: _remindersEnabled ? 0 : 1,
            onSelected: (index) {
              setState(() {
                _remindersEnabled = index == 0;
              });
            },
          );
      }
    }

    return const SizedBox.shrink();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}

class _LargeChoiceButton extends StatelessWidget {
  const _LargeChoiceButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style:
            ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ).copyWith(
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.resolveWith(
                (states) => null,
              ),
            ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumericField extends StatelessWidget {
  const _NumericField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final void Function(String) onChanged;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            suffixText: suffix,
            filled: true,
            fillColor: _t2.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            hintText: 'Enter a number',
          ),
        ),
      ],
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  const _DatePickerCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        decoration: BoxDecoration(
          color: _t2.fillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _t2.arrowColor),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFFE91E8F),
              size: 26,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFE91E8F),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleChoiceGroup extends StatelessWidget {
  const _ToggleChoiceGroup({
    required this.options,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> options;
  final List<String> labels;
  final int selectedIndex;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(options.length, (index) {
        final selected = selectedIndex == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: BoxDecoration(
                color: selected ? _t3.titleColor : _t2.fillColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? _t3.subColor : _t2.arrowColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? Colors.white : _t3.titleColor,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          options[index],
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: selected ? Colors.white : _t3.titleColor,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          labels[index],
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: selected
                                    ? Colors.white70
                                    : _t3.labelColor.withOpacity(0.85),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
