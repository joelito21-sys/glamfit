import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BodyShapeScreen extends StatefulWidget {
  final ValueChanged<String>? onNext;
  const BodyShapeScreen({super.key, this.onNext});

  @override
  State<BodyShapeScreen> createState() => _BodyShapeScreenState();
}

class _BodyShapeScreenState extends State<BodyShapeScreen> {
  String? _selectedShape;
  final List<Map<String, String>> _shapes = const [
    {'name': 'Hourglass', 'icon': '\u25CF', 'desc': 'Balanced bust and hips, defined waist'},
    {'name': 'Pear', 'icon': '\u25CF', 'desc': 'Wider hips than bust'},
    {'name': 'Apple', 'icon': '\u25CF', 'desc': 'Fuller midsection'},
    {'name': 'Rectangle', 'icon': '\u25CF', 'desc': 'Straight silhouette'},
    {'name': 'Inverted Triangle', 'icon': '\u25CF', 'desc': 'Broader shoulders than hips'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Body Shape'), backgroundColor: AppColors.scaffoldBg, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: AppColors.charcoal)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('What is your body shape?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: _shapes.length,
              itemBuilder: (context, index) {
                final shape = _shapes[index];
                final isSelected = _selectedShape == shape['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedShape = shape['name']),
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? AppColors.primary : AppColors.lightGray, width: isSelected ? 2 : 1)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? AppColors.primary : AppColors.primarySurface), child: Icon(Icons.accessibility_new_rounded, size: 28, color: isSelected ? Colors.white : AppColors.charcoal)),
                        const SizedBox(height: 12),
                        Text(shape['name'] ?? '', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                        const SizedBox(height: 4),
                        Text(shape['desc'] ?? '', style: TextStyle(fontSize: 11, color: AppColors.mediumGray), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedShape == null ? null : () => widget.onNext?.call(_selectedShape!),
                style: ElevatedButton.styleFrom(backgroundColor: _selectedShape == null ? AppColors.darkSurface : Colors.white, foregroundColor: _selectedShape == null ? AppColors.mediumGray : const Color(0xFF111111), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                child: const Text('Continue (3/3)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
