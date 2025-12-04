import 'package:flutter/material.dart';

import '../controllers/profile_controller.dart';
import '../models/profile.dart';
import '../utils/conversion.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileController _profileController = ProfileController();
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late Gender _selectedGender;
  late Climate _selectedClimate;

  @override
  void initState() {
    super.initState();
    final profile = _profileController.profile;
    _weightController = TextEditingController(text: profile.weightInKg.toString())
      ..addListener(_handleFormChange);
    _heightController = TextEditingController(text: profile.heightInCm.toString())
      ..addListener(_handleFormChange);
    _selectedGender = profile.gender;
    _selectedClimate = profile.climate;
  }

  @override
  void dispose() {
    _weightController
      ..removeListener(_handleFormChange)
      ..dispose();
    _heightController
      ..removeListener(_handleFormChange)
      ..dispose();
    super.dispose();
  }

  void _handleFormChange() {
    setState(() {});
  }

  String? _validatePositiveInt(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final weight = int.parse(_weightController.text);
    final height = int.parse(_heightController.text);

    _profileController.saveProfile(
      weightInKg: weight,
      heightInCm: height,
      gender: _selectedGender,
      climate: _selectedClimate,
    );

    Navigator.of(context).pop();
  }

  Profile _buildTempProfile() {
    final profile = _profileController.profile;
    final weight = int.tryParse(_weightController.text);
    final height = int.tryParse(_heightController.text);

    return profile.copyWith(
      weightInKg: weight != null && weight > 0 ? weight : profile.weightInKg,
      heightInCm: height != null && height > 0 ? height : profile.heightInCm,
      gender: _selectedGender,
      climate: _selectedClimate,
    );
  }

  String _genderLabel(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }

  String _climateLabel(Climate climate) {
    switch (climate) {
      case Climate.cold:
        return 'Cold';
      case Climate.temperate:
        return 'Temperate';
      case Climate.hot:
        return 'Hot';
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendation = _buildTempProfile().dailyGoalInLiters();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about yourself',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validatePositiveInt(value, 'Weight'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validatePositiveInt(value, 'Height'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Gender>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                },
                items: Gender.values
                    .map(
                      (gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(_genderLabel(gender)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Climate>(
                value: _selectedClimate,
                decoration: const InputDecoration(
                  labelText: 'Climate',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedClimate = value;
                    });
                  }
                },
                items: Climate.values
                    .map(
                      (climate) => DropdownMenuItem(
                        value: climate,
                        child: Text(_climateLabel(climate)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Current recommendation: ${formatNumberToLiter(recommendation)} per day',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
