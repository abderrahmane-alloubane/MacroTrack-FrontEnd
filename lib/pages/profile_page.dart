import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _calorieController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _message;

  double _proteinRatio = 30;
  double _fatRatio = 30;
  double _carbsRatio = 40;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getProfile();
      _nameController.text = data['name'] as String? ?? '';
      _calorieController.text = (data['dailyCalorieGoal'] as int? ?? 2000).toString();
      setState(() {
        _proteinRatio = (data['proteinRatio'] as num?)?.toDouble() ?? 30;
        _fatRatio = (data['fatRatio'] as num?)?.toDouble() ?? 30;
        _carbsRatio = (data['carbsRatio'] as num?)?.toDouble() ?? 40;
      });
    } catch (e) {
      _nameController.text = 'Erreur de chargement du profil';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _message = null;
    });
    try {
      final calorieGoal = int.tryParse(_calorieController.text);
      await ApiService.updateProfile(
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        dailyCalorieGoal: calorieGoal,
        proteinRatio: _proteinRatio,
        fatRatio: _fatRatio,
        carbsRatio: _carbsRatio,
      );
      setState(() => _message = 'Profil enregistré !');
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      setState(() => _message = 'Échec de l\'enregistrement : $e');
    }
    setState(() => _isSaving = false);
  }

  void _onRatioChanged(String changed, double newValue) {
    final oldTotal = _proteinRatio + _fatRatio + _carbsRatio;
    final remaining = 100 - newValue;

    setState(() {
      if (changed == 'protein') {
        _proteinRatio = newValue;
        if (oldTotal > 0) {
          final other = _fatRatio + _carbsRatio;
          if (other > 0) {
            _fatRatio = (_fatRatio / other) * remaining;
            _carbsRatio = (_carbsRatio / other) * remaining;
          } else {
            _fatRatio = remaining / 2;
            _carbsRatio = remaining / 2;
          }
        }
      } else if (changed == 'fat') {
        _fatRatio = newValue;
        if (oldTotal > 0) {
          final other = _proteinRatio + _carbsRatio;
          if (other > 0) {
            _proteinRatio = (_proteinRatio / other) * remaining;
            _carbsRatio = (_carbsRatio / other) * remaining;
          } else {
            _proteinRatio = remaining / 2;
            _carbsRatio = remaining / 2;
          }
        }
      } else if (changed == 'carbs') {
        _carbsRatio = newValue;
        if (oldTotal > 0) {
          final other = _proteinRatio + _fatRatio;
          if (other > 0) {
            _proteinRatio = (_proteinRatio / other) * remaining;
            _fatRatio = (_fatRatio / other) * remaining;
          } else {
            _proteinRatio = remaining / 2;
            _fatRatio = remaining / 2;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informations personnelles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600, color: AppColors.textWhite)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: AppColors.textWhite),
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      labelStyle: TextStyle(color: AppColors.textGray),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textDarkGray)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryBlue)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _calorieController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.textWhite),
                    decoration: InputDecoration(
                      labelText: 'Objectif calorique journalier',
                      labelStyle: TextStyle(color: AppColors.textGray),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textDarkGray)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryBlue)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ratios de macronutriments',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600, color: AppColors.textWhite)),
                  const SizedBox(height: 4),
                  Text('Ajustez le pourcentage de chaque macronutriment',
                    style: TextStyle(color: AppColors.textGray, fontSize: 13)),
                  const SizedBox(height: 20),
                  _ratioSlider('Protéines', _proteinRatio, AppColors.proteinColor, 'protein', 'g'),
                  const SizedBox(height: 16),
                  _ratioSlider('Lipides', _fatRatio, AppColors.fatColor, 'fat', 'g'),
                  const SizedBox(height: 16),
                  _ratioSlider('Glucides', _carbsRatio, AppColors.carbColor, 'carbs', 'g'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                          style: TextStyle(color: AppColors.textGray, fontWeight: FontWeight.w600)),
                        Text('${(_proteinRatio + _fatRatio + _carbsRatio).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: (_proteinRatio + _fatRatio + _carbsRatio).round() == 100
                                ? AppColors.successGreen
                                : AppColors.errorRed,
                            fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _macroPreview('Protéines', _proteinRatio, ApiService.dailyCalorieGoal, 4,
                          AppColors.proteinColor),
                      const SizedBox(width: 8),
                      _macroPreview('Lipides', _fatRatio, ApiService.dailyCalorieGoal, 9,
                          AppColors.fatColor),
                      const SizedBox(width: 8),
                      _macroPreview('Glucides', _carbsRatio, ApiService.dailyCalorieGoal, 4,
                          AppColors.carbColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_message!,
                style: TextStyle(
                  color: _message!.startsWith('Failed')
                      ? AppColors.errorRed
                      : AppColors.successGreen,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enregistrer les modifications', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratioSlider(String label, double value, Color color, String key, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: AppColors.textWhite)),
            Text('${value.toStringAsFixed(0)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: value,
            min: 5,
            max: 85,
            divisions: 16,
            onChanged: (v) => _onRatioChanged(key, v),
          ),
        ),
      ],
    );
  }

  Widget _macroPreview(String label, double ratio, int calorieGoal, int calPerGram, Color color) {
    final grams = (calorieGoal * (ratio / 100)) / calPerGram;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text('${grams.toStringAsFixed(0)}g',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: AppColors.textGray, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
