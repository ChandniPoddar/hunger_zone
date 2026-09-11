import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/notification_service.dart';
import 'live_track_screen.dart';
import 'history_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    final history = await NotificationService.getNotificationHistory();
    if (mounted) {
      setState(() {
        _notifications = history;
        _loading = false;
      });
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Clear All Notifications?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          "Are you sure you want to remove all notifications from your history?",
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              "Clear All",
              style: GoogleFonts.poppins(color: const Color(0xFFFF4B4B), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await NotificationService.clearNotificationHistory();
      if (mounted) {
        setState(() => _notifications = []);
      }
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "";
    try {
      final dateTime = DateTime.parse(isoString);
      final diff = DateTime.now().difference(dateTime);

      if (diff.inMinutes < 1) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      if (diff.inDays < 7) return "${diff.inDays}d ago";
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (_) {
      return "";
    }
  }

  IconData _getNotificationIcon(String title, String body) {
    final text = "$title $body".toLowerCase();
    if (text.contains("ready")) return Icons.celebration_rounded;
    if (text.contains("preparing") || text.contains("kitchen")) return Icons.soup_kitchen_rounded;
    if (text.contains("accepted") || text.contains("confirmed")) return Icons.check_circle_outline_rounded;
    if (text.contains("completed")) return Icons.task_alt_rounded;
    if (text.contains("rejected") || text.contains("cancelled")) return Icons.cancel_outlined;
    if (text.contains("order")) return Icons.receipt_long_rounded;
    return Icons.notifications_active_outlined;
  }

  Color _getIconColor(String title, String body) {
    final text = "$title $body".toLowerCase();
    if (text.contains("ready")) return const Color(0xFF28A745);
    if (text.contains("preparing")) return const Color(0xFFFF9800);
    if (text.contains("accepted") || text.contains("confirmed")) return const Color(0xFF17A2B8);
    if (text.contains("completed")) return const Color(0xFF28A745);
    if (text.contains("rejected") || text.contains("cancelled")) return const Color(0xFFDC3545);
    return const Color(0xFFFF4B4B);
  }

  void _handleTap(Map<String, dynamic> item) {
    final text = "${item['title'] ?? ''} ${item['body'] ?? ''}".toLowerCase();
    if (text.contains("ready") || text.contains("preparing") || text.contains("accepted") || text.contains("confirmed")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveTrackScreen()));
    } else if (text.contains("completed") || text.contains("order")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Color(0xFFFF4B4B)),
              tooltip: "Clear All",
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4B4B)),
              ),
            )
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: const Color(0xFFFF4B4B),
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      final title = item['title'] ?? 'Notification';
                      final body = item['body'] ?? '';
                      final timeStr = _formatTime(item['timestamp']);
                      final icon = _getNotificationIcon(title, body);
                      final iconColor = _getIconColor(title, body);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
                        ),
                        child: InkWell(
                          onTap: () => _handleTap(item),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: iconColor, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: const Color(0xFF1A1A2E),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (timeStr.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              timeStr,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        body,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          color: const Color(0xFF495057),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4B4B).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 46,
                color: Color(0xFFFF4B4B),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No Notifications Yet",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You're all caught up! Updates regarding your canteen orders and statuses will appear here.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
