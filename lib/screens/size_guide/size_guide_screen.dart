import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SizeGuideScreen extends StatefulWidget {
  final VoidCallback? onNext;
  const SizeGuideScreen({super.key, this.onNext});

  @override
  State<SizeGuideScreen> createState() => _SizeGuideScreenState();
}

class _SizeGuideScreenState extends State<SizeGuideScreen> {
  int _tab = 0; // 0 = Product Chart, 1 = Body Chart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Size Guide'),
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
      ),
      body: Column(
        children: [
          // Switch to unit
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Switch to', style: TextStyle(fontSize: 13, color: AppColors.mediumGray)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: 'Type',
                  items: const [
                    DropdownMenuItem(value: 'Type', child: Text('Type')),
                    DropdownMenuItem(value: 'cm', child: Text('cm')),
                    DropdownMenuItem(value: 'in', child: Text('in')),
                  ],
                  onChanged: (_) {},
                ),
                const Spacer(),
                const Text('cm', style: TextStyle(fontSize: 13, color: AppColors.charcoal)),
                Switch(
                  value: true,
                  onChanged: (_) {},
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _tab == 0 ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Product Chart',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _tab == 0 ? AppColors.charcoal : AppColors.mediumGray,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _tab == 1 ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Body Chart',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _tab == 1 ? AppColors.charcoal : AppColors.mediumGray,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Product Chart
          Expanded(
            child: _tab == 0
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '*This data was obtained from manually measuring the product, it may be off by 0.39-0.79 IN.',
                        ),
                        const SizedBox(height: 12),
                        ..._sizeRows.map((row) => _sizeRow(row[0], row[1])),
                        const SizedBox(height: 24),
                        _expandableSection(
                          'How to measure the product\u2019s size?',
                          'Measure the garment flat: bust across the chest, waist at the narrowest point, hips at the fullest point, and length from shoulder to hem.',
                        ),
                        const SizedBox(height: 24),
                        _expandableSection(
                          'How Buyer\u2019s Reviewed The Fit',
                          'Fits true to size: 100%',
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onNext,
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
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  final List<List<String>> _sizeRows = const [
    ['M', '37.4'],
    ['L', '39.4'],
    ['XL', '41.3'],
  ];

  Widget _sizeRow(String size, String bust) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Size', style: const TextStyle(fontSize: 14, color: AppColors.charcoal)),
                  Text(size, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bust', style: const TextStyle(fontSize: 14, color: AppColors.charcoal)),
                  Text('$bust in', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandableSection(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.mediumGray),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(body, style: const TextStyle(fontSize: 12, color: AppColors.mediumGray, height: 1.5)),
        const SizedBox(height: 16),
      ],
    );
  }
}
