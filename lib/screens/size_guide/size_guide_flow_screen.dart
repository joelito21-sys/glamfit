import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'size_guide_screen.dart';
import 'measurements_screen.dart';
import 'body_shape_screen.dart';

class SizeGuideResult {
  final String recommendedSize;
  final SizeMeasurements measurements;
  final String bodyShape;
  const SizeGuideResult({required this.recommendedSize, required this.measurements, required this.bodyShape});
}

class SizeGuideFlowScreen extends StatefulWidget {
  final List<String> availableSizes;
  const SizeGuideFlowScreen({super.key, this.availableSizes = const ['XS', 'S', 'M', 'L', 'XL']});
  @override
  State<SizeGuideFlowScreen> createState() => _SizeGuideFlowScreenState();
}

class _SizeGuideFlowScreenState extends State<SizeGuideFlowScreen> {
  int _step = 0;
  SizeMeasurements? _measurements;
  String? _bodyShape;
  late String _recommendedSize;

  @override
  void initState() {
	super.initState();
	_recommendedSize = widget.availableSizes.isNotEmpty ? widget.availableSizes.first : 'M';
  }

  void _complete(String bodyShape) {
	final measurements = _measurements!;
	_bodyShape = bodyShape;
	const limits = {
	  'XXS': [30.0, 23.0, 32.0],
	  'XS': [32.0, 25.0, 34.0],
	  'S': [34.0, 27.0, 36.0],
	  'M': [36.0, 29.0, 38.0],
	  'L': [38.0, 31.0, 40.0],
	  'XL': [41.0, 34.0, 43.0],
	  'XXL': [44.0, 37.0, 46.0],
	};
	var bestSize = widget.availableSizes.last;
	var bestScore = double.infinity;
	for (final size in widget.availableSizes) {
	  final chart = limits[size.toUpperCase()];
	  if (chart == null) continue;
	  final score = [
		measurements.bust / chart[0],
		measurements.waist / chart[1],
		measurements.hips / chart[2],
	  ].reduce((a, b) => a > b ? a : b);
	  if (score < bestScore) {
		bestScore = score;
		bestSize = size;
	  }
	  if (score <= 1) break;
	}
	_recommendedSize = bestSize;
	setState(() => _step = 3);
  }

  @override
  Widget build(BuildContext context) {
	return Scaffold(
	  body: IndexedStack(index: _step, children: [
		SizeGuideScreen(onNext: () => setState(() => _step = 1)),
		MeasurementsScreen(onNext: (value) => setState(() { _measurements = value; _step = 2; })),
		BodyShapeScreen(onNext: _complete),
		_ResultScreen(recommendedSize: _recommendedSize, measurements: _measurements, bodyShape: _bodyShape ?? '', onUseSize: () => Navigator.pop(context, SizeGuideResult(recommendedSize: _recommendedSize, measurements: _measurements!, bodyShape: _bodyShape ?? ''))),
	  ]),
	);
  }
}

class _ResultScreen extends StatelessWidget {
  final String recommendedSize;
	final SizeMeasurements? measurements;
  final String bodyShape;
  final VoidCallback onUseSize;
  const _ResultScreen({required this.recommendedSize, required this.measurements, required this.bodyShape, required this.onUseSize});

  @override
  Widget build(BuildContext context) {
	return Scaffold(
	  appBar: AppBar(title: const Text('Your Size Result'), backgroundColor: AppColors.scaffoldBg, elevation: 0, centerTitle: true),
	  body: Padding(
		padding: const EdgeInsets.all(24),
		child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
		  const SizedBox(height: 32),
		  const Icon(Icons.checkroom_rounded, size: 64, color: AppColors.primary),
		  const SizedBox(height: 20),
		  const Text('Recommended size', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppColors.mediumGray)),
		  Text(recommendedSize, textAlign: TextAlign.center, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
		  const SizedBox(height: 20),
			Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surfaceBg, borderRadius: BorderRadius.circular(16)), child: Text('Bust: ${measurements?.bust.toStringAsFixed(0)} ${measurements?.unit}\nWaist: ${measurements?.waist.toStringAsFixed(0)} ${measurements?.unit}\nHips: ${measurements?.hips.toStringAsFixed(0)} ${measurements?.unit}\nBody shape: $bodyShape', style: const TextStyle(color: AppColors.darkGray, height: 1.5))),
		  const Spacer(),
		  SizedBox(height: 54, child: ElevatedButton(onPressed: onUseSize, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF111111)), child: Text('Use size $recommendedSize'))),
		]),
	  ),
	);
  }
}
