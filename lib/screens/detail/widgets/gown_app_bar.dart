import 'package:flutter/material.dart';
import '../../../core/state/favorites_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_motion.dart';

/// Circular translucent action button used in the detail-screen app bar.
///
/// Previously the identical decoration was copy-pasted four times inline
/// in the app bar (DRY violation); extracting it keeps every action a
/// one-liner and makes the styling changeable in one place.
class CircleAppBarAction extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final Color? iconColor;
  final Widget? child;

  const CircleAppBarAction({
    super.key,
    this.icon,
    required this.onTap,
    this.margin = const EdgeInsets.all(8),
    this.iconColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.all(10),
        decoration: _decoration,
        child:
            child ?? Icon(icon, size: 20, color: iconColor ?? AppColors.charcoal),
      ),
    );
  }

  BoxDecoration get _decoration => BoxDecoration(
        color: AppColors.lightPink.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      );
}

/// The favorite toggle, with its heart "pop" animation owned here
/// instead of leaking animation concerns into the screen State.
class FavoriteAction extends StatefulWidget {
  final String gownId;
  const FavoriteAction({super.key, required this.gownId});

  @override
  State<FavoriteAction> createState() => _FavoriteActionState();
}

class _FavoriteActionState extends State<FavoriteAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoritesStore.instance.contains(widget.gownId);
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _toggle() {
    FavoritesStore.instance.toggle(widget.gownId);
    setState(
        () => _isFavorite = FavoritesStore.instance.contains(widget.gownId));
    if (_isFavorite) {
      _heartController.forward().then((_) => _heartController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAppBarAction(
      onTap: _toggle,
      child: ScaleTransition(
        scale: _heartScale,
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: _isFavorite ? AppColors.error : AppColors.charcoal,
        ),
      ),
    );
  }
}
