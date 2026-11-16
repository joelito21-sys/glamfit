import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_session.dart';
import '../../core/state/notification_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/app_motion.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/notification_model.dart';
import '../../models/sms_notification_model.dart';
import '../../services/sms_notification_service.dart';
import '../auth/auth_flow_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationStore store = NotificationStore.instance;

  @override
  void initState() {
    super.initState();
    store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(store.load(AuthScope.of(context).accessToken));
  }

  int get _unreadCount => store.unreadCount;

  void _markAllRead() {
    unawaited(store.markAllRead());
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthScope.of(context);
    if (!session.isLoggedIn) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Notifications',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              Expanded(
                child: EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No alerts yet',
                  subtitle:
                      'Sign in to get booking updates, pickup reminders, and payment notices.',
                  actionText: 'Sign In',
                  onAction: () => AuthGate.requireLogin(
                    context,
                    prompt: 'Sign in to view notifications',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    if (_unreadCount > 0) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_unreadCount new',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (_unreadCount > 0)
                      TextButton(onPressed: _markAllRead, child: const Text('Mark all read')),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.lightGray),
                  ),
                  child: TabBar(
                    labelColor: AppColors.charcoal,
                    unselectedLabelColor: AppColors.mediumGray,
                    indicator: BoxDecoration(
                      color: AppColors.roseRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Alerts'),
                      Tab(text: 'SMS'),
                      Tab(text: 'Preferences'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  children: [
                    _AlertsTab(store: store),
                    _SmsHistoryTab(token: session.accessToken!),
                    _SmsPreferencesTab(token: session.accessToken!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertsTab extends StatelessWidget {
  final NotificationStore store;
  const _AlertsTab({required this.store});

  @override
  Widget build(BuildContext context) {
    if (store.isLoading && store.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (store.error != null && store.items.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load notifications',
        subtitle: store.error!,
        actionText: 'Retry',
        onAction: () => unawaited(store.refresh()),
      );
    }
    if (store.items.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'No notifications',
        subtitle: 'You\'re all caught up!',
      );
    }
    return RefreshIndicator(
      color: AppColors.roseRed,
      onRefresh: () => store.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: store.items.length,
        itemBuilder: (context, index) {
          final notification = store.items[index];
          return _NotificationTile(
            notification: notification,
            onTap: () {
              if (!notification.isRead) unawaited(store.markRead(notification.id));
            },
            onDismiss: () => unawaited(store.dismiss(notification.id)),
          );
        },
      ),
    );
  }
}

class _SmsHistoryTab extends StatefulWidget {
  final String token;
  const _SmsHistoryTab({required this.token});

  @override
  State<_SmsHistoryTab> createState() => _SmsHistoryTabState();
}

class _SmsHistoryTabState extends State<_SmsHistoryTab> {
  final _service = SmsNotificationApiService();
  bool _loading = true;
  String? _error;
  List<SmsNotificationModel> _items = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await _service.fetchHistory(widget.token);
      if (!mounted) return;
      setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EmptyState(
        icon: Icons.sms_failed_outlined,
        title: 'Could not load SMS history',
        subtitle: _error!,
        actionText: 'Retry',
        onAction: _load,
      );
    }
    if (_items.isEmpty) {
      return const EmptyState(
        icon: Icons.sms_outlined,
        title: 'No SMS notifications',
        subtitle: 'Your booking, payment, and delivery SMS updates will appear here.',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: _items.length,
        itemBuilder: (context, index) => _SmsTile(item: _items[index]),
      ),
    );
  }
}

class _SmsTile extends StatelessWidget {
  final SmsNotificationModel item;
  const _SmsTile({required this.item});

  Color _statusColor(String s) {
    switch (s) {
      case 'delivered':
      case 'sent':
      case 'accepted':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _typeLabel(String t) {
    return t.replaceAll('_', ' ').replaceAllMapped(RegExp(r'\b\w'), (m) => m.group(0)!.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightPink,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _typeLabel(item.notificationType),
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(item.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor(item.status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.message, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.darkGray)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              Text(DateFormat('MMM d, yyyy h:mm a').format(item.createdAt), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.mediumGray)),
              if (item.relatedBookingId != null)
                Text('Booking #${item.relatedBookingId}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.mediumGray)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmsPreferencesTab extends StatefulWidget {
  final String token;
  const _SmsPreferencesTab({required this.token});

  @override
  State<_SmsPreferencesTab> createState() => _SmsPreferencesTabState();
}

class _SmsPreferencesTabState extends State<_SmsPreferencesTab> {
  final _service = SmsNotificationApiService();
  bool _loading = true;
  bool _saving = false;
  String? _error;
  SmsPreferencesModel _prefs = SmsPreferencesModel.defaults();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await _service.getPreferences(widget.token);
      if (!mounted) return;
      setState(() { _prefs = prefs; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  Future<void> _save(SmsPreferencesModel next) async {
    setState(() { _prefs = next; _saving = true; });
    try {
      final saved = await _service.updatePreferences(widget.token, next);
      if (!mounted) return;
      setState(() { _prefs = saved; _saving = false; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SMS preferences updated')));
    } catch (e) {
      if (!mounted) return;
      setState(() { _saving = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save preferences: ${e.toString().replaceFirst('Exception: ', '')}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EmptyState(
        icon: Icons.settings_outlined,
        title: 'Could not load preferences',
        subtitle: _error!,
        actionText: 'Retry',
        onAction: _load,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        if (_saving) const LinearProgressIndicator(minHeight: 2),
        SwitchListTile.adaptive(
          title: const Text('Enable SMS notifications'),
          subtitle: const Text('Master control for SMS alerts to your number'),
          value: _prefs.smsEnabled,
          onChanged: (v) => _save(_prefs.copyWith(smsEnabled: v)),
        ),
        const Divider(),
        SwitchListTile.adaptive(
          title: const Text('Booking updates'),
          value: _prefs.bookingUpdates,
          onChanged: _prefs.smsEnabled ? (v) => _save(_prefs.copyWith(bookingUpdates: v)) : null,
        ),
        SwitchListTile.adaptive(
          title: const Text('Payment updates'),
          value: _prefs.paymentUpdates,
          onChanged: _prefs.smsEnabled ? (v) => _save(_prefs.copyWith(paymentUpdates: v)) : null,
        ),
        SwitchListTile.adaptive(
          title: const Text('Delivery updates'),
          value: _prefs.deliveryUpdates,
          onChanged: _prefs.smsEnabled ? (v) => _save(_prefs.copyWith(deliveryUpdates: v)) : null,
        ),
        SwitchListTile.adaptive(
          title: const Text('Return reminders'),
          value: _prefs.returnReminders,
          onChanged: _prefs.smsEnabled ? (v) => _save(_prefs.copyWith(returnReminders: v)) : null,
        ),
        SwitchListTile.adaptive(
          title: const Text('Promotional messages'),
          subtitle: const Text('Optional offers and promotions (separate consent)'),
          value: _prefs.promotionalMessages,
          onChanged: _prefs.smsEnabled ? (v) => _save(_prefs.copyWith(promotionalMessages: v)) : null,
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({required this.notification, required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      child: Pressable(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? AppColors.lightPink : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(16),
            border: notification.isRead ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            boxShadow: [BoxShadow(color: AppColors.charcoal.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: _getTypeColor(notification.type).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(_getTypeIcon(notification.type), size: 22, color: _getTypeColor(notification.type)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(fontSize: 13, fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600, color: AppColors.charcoal),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notification.body, style: TextStyle(fontSize: 12, color: AppColors.darkGray), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(_formatTime(notification.createdAt), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.mediumGray)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.bookingReceived: return Icons.receipt_long_rounded;
      case NotificationType.bookingApproved: return Icons.check_circle_rounded;
      case NotificationType.bookingRejected: return Icons.cancel_rounded;
      case NotificationType.paymentVerified: return Icons.verified_rounded;
      case NotificationType.pickupReminder: return Icons.inventory_2_rounded;
      case NotificationType.returnReminder: return Icons.event_note_rounded;
      case NotificationType.returnDueSoon: return Icons.timer_rounded;
      case NotificationType.overdue: return Icons.warning_amber_rounded;
      case NotificationType.depositSettled: return Icons.account_balance_wallet_rounded;
      case NotificationType.general: return Icons.auto_awesome;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.bookingApproved: return AppColors.success;
      case NotificationType.bookingRejected: return AppColors.error;
      case NotificationType.paymentVerified: return AppColors.info;
      case NotificationType.pickupReminder: return AppColors.statusReady;
      case NotificationType.returnReminder:
      case NotificationType.returnDueSoon: return AppColors.warning;
      case NotificationType.overdue: return AppColors.error;
      case NotificationType.depositSettled: return AppColors.success;
      case NotificationType.general: return AppColors.primary;
      default: return AppColors.primary;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(date);
  }
}
