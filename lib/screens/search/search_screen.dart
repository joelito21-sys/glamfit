import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/app_motion.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/gown_image.dart';
import '../../data/gown_catalog.dart';
import '../../models/gown_model.dart';
import '../detail/gown_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedSort;
  RangeValues _priceRange = const RangeValues(0, 5000);
  List<String> _selectedSizes = [];
  bool _showFilters = false;

  final List<String> _allSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _sortOptions = [
    'Popular',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
    'Rating',
  ];
  final List<String> _recentSearches = [
    'Wedding gown',
    'Evening dress',
    'Debut',
    'Filipiniana',
  ];

  @override
  void initState() {
    super.initState();
    GownCatalog.instance.addListener(_onCatalogChanged);
    unawaited(GownCatalog.instance.load());
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  void _onCatalogChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GownCatalog.instance.removeListener(_onCatalogChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  List<GownModel> get _filteredGowns {
    var gowns = GownCatalog.instance.gowns.where((g) {
      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!g.name.toLowerCase().contains(query) &&
            !g.category.toLowerCase().contains(query) &&
            !g.designer.toLowerCase().contains(query) &&
            !g.description.toLowerCase().contains(query)) {
          return false;
        }
      }
      // Category filter
      if (_selectedCategory != null && g.category != _selectedCategory) {
        return false;
      }
      // Price filter
      if (g.rentalPrice < _priceRange.start || g.rentalPrice > _priceRange.end) {
        return false;
      }
      // Size filter
      if (_selectedSizes.isNotEmpty &&
          !_selectedSizes.any((s) => g.sizes.contains(s))) {
        return false;
      }
      return true;
    }).toList();

    // Sort
    switch (_selectedSort) {
      case 'Popular':
        gowns.sort((a, b) => b.rentalCount.compareTo(a.rentalCount));
        break;
      case 'Price: Low to High':
        gowns.sort((a, b) => a.rentalPrice.compareTo(b.rentalPrice));
        break;
      case 'Price: High to Low':
        gowns.sort((a, b) => b.rentalPrice.compareTo(a.rentalPrice));
        break;
      case 'Newest':
        gowns.sort((a, b) => (b.isNew ? 1 : 0).compareTo(a.isNew ? 1 : 0));
        break;
      case 'Rating':
        gowns.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return gowns;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_priceRange.start > 0 || _priceRange.end < 5000) count++;
    if (_selectedSizes.isNotEmpty) count++;
    if (_selectedSort != null) count++;
    return count;
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedSort = null;
      _priceRange = const RangeValues(0, 5000);
      _selectedSizes = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Search Header
              _buildSearchHeader(),
              // Active filters chips
              if (_activeFilterCount > 0) _buildActiveFilters(),
              // Filters panel
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildFiltersPanel(),
                crossFadeState: _showFilters
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              // Results
              Expanded(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          Pressable(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Search field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search gowns, designers...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.mediumGray,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.mediumGray,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () => setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          }),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.mediumGray,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button
          Pressable(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: _showFilters || _activeFilterCount > 0
                    ? AppColors.primaryGradient
                    : null,
                color: _showFilters || _activeFilterCount > 0
                    ? null
                    : AppColors.surfaceBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: _showFilters || _activeFilterCount > 0
                        ? AppColors.white
                        : AppColors.charcoal,
                  ),
                  if (_activeFilterCount > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        width: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$_activeFilterCount',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedCategory != null)
            _filterChip(
              _selectedCategory!,
              () => setState(() => _selectedCategory = null),
            ),
          if (_selectedSort != null)
            _filterChip(
              _selectedSort!,
              () => setState(() => _selectedSort = null),
            ),
          if (_selectedSizes.isNotEmpty)
            _filterChip(
              'Sizes: ${_selectedSizes.join(", ")}',
              () => setState(() => _selectedSizes = []),
            ),
          if (_priceRange.start > 0 || _priceRange.end < 5000)
            _filterChip(
              '₱${_priceRange.start.toInt()} - ₱${_priceRange.end.toInt()}',
              () => setState(() => _priceRange = const RangeValues(0, 5000)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Pressable(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          Text(
            'Category',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GownCatalog.instance.categories.map((cat) {
              final isSelected = _selectedCategory == cat.name;
              return GestureDetector(
                onTap: () => setState(
                  () => _selectedCategory = isSelected ? null : cat.name,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : AppColors.surfaceBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Price Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Range',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              Text(
                '₱${_priceRange.start.toInt()} - ₱${_priceRange.end.toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.lightGray,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 8,
              ),
            ),
            child: RangeSlider(
              values: _priceRange,
              min: 0,
              max: 5000,
              divisions: 50,
              onChanged: (v) => setState(() => _priceRange = v),
            ),
          ),

          const SizedBox(height: 12),

          // Sizes
          Text(
            'Sizes',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _allSizes.map((size) {
              final isSelected = _selectedSizes.contains(size);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selectedSizes.remove(size);
                    } else {
                      _selectedSizes.add(size);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : AppColors.surfaceBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        size,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.darkGray,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Sort
          Text(
            'Sort By',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sortOptions.map((opt) {
              final isSelected = _selectedSort == opt;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedSort = isSelected ? null : opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : AppColors.surfaceBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    opt,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.darkGray,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final gowns = _filteredGowns;

    if (_searchQuery.isEmpty && _activeFilterCount == 0) {
      return _buildSuggestions();
    }

    if (gowns.isEmpty) {
      if (GownCatalog.instance.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (GownCatalog.instance.error != null) {
        return EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Could not load gowns',
          subtitle: GownCatalog.instance.error!,
          actionText: 'Retry',
          onAction: () => unawaited(GownCatalog.instance.load(refresh: true)),
        );
      }
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Gowns Found',
        subtitle: 'Try adjusting your search or filters',
        actionText: 'Clear Filters',
        onAction: () {
          _clearFilters();
          setState(() {
            _searchController.clear();
            _searchQuery = '';
          });
        },
      );
    }

    return Column(
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Text(
                '${gowns.length} gowns found',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: gowns.length,
            itemBuilder: (context, index) {
              final gown = gowns[index];
              return GownCard(
                gown: gown,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GownDetailScreen(gown: gown),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                Pressable(
                  onTap: () {},
                  child: Text(
                    'Clear',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_recentSearches.map(
              (s) => GestureDetector(
                onTap: () => setState(() {
                  _searchController.text = s;
                  _searchQuery = s;
                }),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        size: 18,
                        color: AppColors.mediumGray,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.north_west_rounded,
                        size: 14,
                        color: AppColors.lightGray,
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ],

          const SizedBox(height: 24),

          // Popular categories
          Text(
            'Popular Categories',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: GownCatalog.instance.categories.map((cat) {
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategory = cat.name;
                  _searchQuery = ' ';
                  _searchController.text = cat.name;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.lightGray.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.charcoal.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.name,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.charcoal,
                            ),
                          ),
                          Text(
                            '${cat.count} gowns',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Trending
          Text(
            'Trending Now 🔥',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          ...GownCatalog.instance.gowns.where((g) => g.isFeatured).take(3).map((
            gown,
          ) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GownDetailScreen(gown: gown)),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.charcoal.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 56,
                        child: GownImage(imagePath: gown.images.first),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gown.name,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${gown.category} • ${gown.designer}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₱${gown.rentalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${gown.rating}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.darkGray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
