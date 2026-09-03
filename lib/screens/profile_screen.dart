import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_input.dart';
import '../data/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Avatar & Profile Detail Header Card
              CustomCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.primaryLight,
                      child: Text(
                        state.name.isNotEmpty ? state.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 28,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.dietaryPreference} • ${state.gender}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Quick stats indicators
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _buildStatItem('Age', '${state.age} yrs')),
                        Expanded(child: _buildStatItem('Height', '${state.height.toInt()} cm')),
                        Expanded(child: _buildStatItem('Weight', '${state.weight.toInt()} kg')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Options Card
              CustomCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Icons.edit_rounded,
                      color: AppTheme.primary,
                      title: 'Edit Health Profile',
                      subtitle: 'Update biometrics and dietary pref',
                      onTap: () {
                        _showEditProfileDialog(context, state);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: state.notificationEnabled,
                      activeThumbColor: AppTheme.primary,
                      secondary: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: Colors.blue, size: 18),
                      ),
                      title: const Text(
                        'Daily Reminder Logs',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      subtitle: const Text(
                        'Receive hydration prompts twice daily',
                        style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                      ),
                      onChanged: (val) {
                        state.setNotificationsEnabled(val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: state.weeklyReportEnabled,
                      activeThumbColor: AppTheme.primary,
                      secondary: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.auto_graph_rounded, color: Colors.purple, size: 18),
                      ),
                      title: const Text(
                        'Weekly Deficiency Digest',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      subtitle: const Text(
                        'Get detailed trends in your report inbox',
                        style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                      ),
                      onChanged: (val) {
                        state.setWeeklyReportEnabled(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // About and Miscellaneous settings
              CustomCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Icons.shield_outlined,
                      color: Colors.teal,
                      title: 'Privacy Policy',
                      subtitle: 'View data protection rules',
                      onTap: () {
                        _showInfoDialog(
                          context,
                          title: 'Privacy Policy',
                          content: 'Your nutritional assessment inputs and water tracking metrics are compiled entirely locally on your device. We do not transmit or sell personal health biometrics to third-party endpoints.',
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsItem(
                      icon: Icons.info_outline_rounded,
                      color: Colors.blueGrey,
                      title: 'About Nourish',
                      subtitle: 'Version details and licensing',
                      onTap: () {
                        _showInfoDialog(
                          context,
                          title: 'About Nourish',
                          content: 'Nourish v1.0.0\n\nDesigned as a student academic prototype. Built to assess symptoms, suggest dietary directions, and help catalog everyday hydration targets. Always consult clinical practitioners for medical diagnoses.',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textLight,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textLight,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight, size: 20),
      onTap: onTap,
    );
  }

  void _showInfoDialog(BuildContext context, {required String title, required String content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppState state) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: state.name);
    final ageController = TextEditingController(text: state.age.toString());
    final heightController = TextEditingController(text: state.height.toString());
    final weightController = TextEditingController(text: state.weight.toString());
    String tempDiet = state.dietaryPreference;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomInput(
                      label: 'Name',
                      hintText: 'Enter name',
                      controller: nameController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomInput(
                      label: 'Age',
                      hintText: 'Enter age',
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || int.tryParse(val) == null ? 'Invalid' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: 'Height (cm)',
                            hintText: 'cm',
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomInput(
                            label: 'Weight (kg)',
                            hintText: 'kg',
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Diet Preference',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: tempDiet,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: MockData.dietTypes.map((diet) {
                        return DropdownMenuItem(
                          value: diet,
                          child: Text(diet, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            tempDiet = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textLight)),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    state.updateProfile(
                      newName: nameController.text,
                      newAge: int.parse(ageController.text),
                      newGender: state.gender, // Keep gender or add selector
                      newHeight: double.parse(heightController.text),
                      newWeight: double.parse(weightController.text),
                      newDiet: tempDiet,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }
}
