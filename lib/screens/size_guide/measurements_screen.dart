import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SizeMeasurements {
  final double bust;
  final double waist;
  final double hips;
  final String unit;

  const SizeMeasurements({
    required this.bust,
    required this.waist,
    required this.hips,
    required this.unit,
  });
}

class MeasurementsScreen extends StatefulWidget {
  final ValueChanged<SizeMeasurements>? onNext;
  const MeasurementsScreen({super.key, this.onNext});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  String _unit = 'in'; // 'cm' or 'in'
  double _bust = 35;
  double _waist = 28;
  double _hips = 39;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Measurements*'),
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Switch to', style: TextStyle(fontSize: 13, color: AppColors.mediumGray)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _unit == 'in' ? 'in, lb' : 'cm, kg',
                  items: const [
                    DropdownMenuItem(value: 'in, lb', child: Text('in, lb')),
                    DropdownMenuItem(value: 'cm, kg', child: Text('cm, kg')),
                  ],
                  onChanged: (v) => setState(() => _unit = v == 'in, lb' ? 'in' : 'cm'),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _measurementField('Bust*', _bust.toStringAsFixed(0), '$_bust $_unit', 28, 48),
                  const SizedBox(height: 20),
                  _measurementField('Waist*', _waist.toStringAsFixed(0), '$_waist $_unit', 22, 42),
                  const SizedBox(height: 20),
                  _measurementField('Hips*', _hips.toStringAsFixed(0), '$_hips $_unit', 31, 51),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => widget.onNext?.call(
                        SizeMeasurements(bust: _bust, waist: _waist, hips: _hips, unit: _unit),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF111111),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text('Continue (2/3)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _measurementField(String label, String value, String unitText, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 10),
        Center(
          child: Column(
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
              const SizedBox(height: 4),
              Slider(
                value: label == 'Bust*' ? _bust : label == 'Waist*' ? _waist : _hips,
                min: min,
                max: max,
                divisions: (max - min).toInt(),
                activeColor: AppColors.primary,
                inactiveColor: AppColors.lightGray.withValues(alpha: 0.4),
                onChanged: (v) {
                  setState(() {
                    if (label == 'Bust*') {
                      _bust = v;
                    } else if (label == 'Waist*') {
                      _waist = v;
                    } else {
                      _hips = v;
                    }
                  });
                },
              ),
              Text(unitText, style: const TextStyle(fontSize: 12, color: AppColors.mediumGray)),
            ],
          ),
        ),
      ],
    );
  }
}
