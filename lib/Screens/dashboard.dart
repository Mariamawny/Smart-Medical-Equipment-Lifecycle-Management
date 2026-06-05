import 'package:flutter/material.dart';
import 'package:ed_app/state/app_state.dart';
import 'devices_list.dart';
import 'add_device.dart';
import 'maintenance_history.dart';
import 'admin_panel.dart';
import 'hospital_map.dart';
import 'chatbot.dart';
import 'spare_parts.dart';
import 'incident_report.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int? hoveredLargeCardIndex;
  int? hoveredSmallCardIndex;

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1100;

    final largeCardWidth = isSmallScreen 
        ? (screenWidth - 72 - 20) / 2
        : (screenWidth * 0.55 - 40) / 3;

    final smallCardWidth = isSmallScreen
        ? (screenWidth - 72 - 20) / 2
        : (screenWidth * 0.55 - 60) / 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF0E4F87),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('⚕️', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "ED Equipment Control Center",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final workingCount = appState.workingDevicesCount;
          final maintCount = appState.maintenanceDevicesCount;
          final criticalCount = appState.criticalDevicesCount;

          // Main left content column
          final leftContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= Large Cards =================
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  animatedLargeCard(
                    index: 0,
                    width: largeCardWidth,
                    color: const Color(0xFFD7F1FF),
                    emoji: "✔️",
                    number: "$workingCount",
                    title: "Working Devices",
                  ),
                  animatedLargeCard(
                    index: 1,
                    width: largeCardWidth,
                    color: Colors.white,
                    emoji: "🔧",
                    number: "$maintCount",
                    title: "Under Maintenance",
                  ),
                  animatedLargeCard(
                    index: 2,
                    width: largeCardWidth,
                    color: Colors.white,
                    emoji: "⚠️",
                    number: "$criticalCount",
                    title: "Critical Issues",
                    textColor: criticalCount > 0 ? Colors.red.shade700 : Colors.black,
                  ),
                ],
              ),

              const SizedBox(height: 36),

              /// ================= Quick Actions =================
              const Text(
                "Quick Actions Panel",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _actionBtn(
                    index: 0,
                    width: smallCardWidth,
                    emoji: "➕",
                    title: "Register Device",
                    page: const AddDevice(),
                  ),
                  _actionBtn(
                    index: 1,
                    width: smallCardWidth,
                    emoji: "📱",
                    title: "Device List",
                    page: const DevicesList(),
                  ),
                  _actionBtn(
                    index: 2,
                    width: smallCardWidth,
                    emoji: "🗺️",
                    title: "Hospital Map",
                    page: const HospitalMap(),
                  ),
                  _actionBtn(
                    index: 3,
                    width: smallCardWidth,
                    emoji: "💬",
                    title: "AI Assistant",
                    page: const ChatbotScreen(),
                  ),
                  _actionBtn(
                    index: 4,
                    width: smallCardWidth,
                    emoji: "📦",
                    title: "Spare Parts",
                    page: const SparePartsScreen(),
                  ),
                  _actionBtn(
                    index: 5,
                    width: smallCardWidth,
                    emoji: "📄",
                    title: "Tickets Log",
                    page: const MaintenanceHistory(),
                  ),
                  _actionBtn(
                    index: 6,
                    width: smallCardWidth,
                    emoji: "📊",
                    title: "Analytics KPIs",
                    page: const AdminPanel(),
                  ),
                  _actionBtn(
                    index: 7,
                    width: smallCardWidth,
                    emoji: "🚨",
                    title: "Report Portal",
                    page: const IncidentReportScreen(),
                    customBgColor: const Color.fromARGB(255, 139, 10, 10),
                  ),
                ],
              ),
            ],
          );

          // Notifications Feed
          final rightContent = Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F3FC),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: Color(0xFF0E4F87)),
                    SizedBox(width: 10),
                    Text(
                      "Live Operations Feed",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0E4F87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: appState.notifications.isEmpty
                      ? const Center(child: Text("No alerts today", style: TextStyle(color: Colors.grey)))
                      : ListView.separated(
                          itemCount: appState.notifications.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final text = appState.notifications[index];
                            final isUrgent = text.contains("URGENT") || text.contains("ALERT") || text.contains("STOCK ALERT") || text.contains("CRITICAL");

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUrgent ? const Color(0xFFFFECEF) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isUrgent ? Colors.red.shade300 : Colors.white,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    isUrgent ? Icons.error_outline : Icons.info_outline,
                                    color: isUrgent ? Colors.red.shade700 : Colors.blue.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      text,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                                        color: isUrgent ? Colors.red.shade900 : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      leftContent,
                      const SizedBox(height: 36),
                      rightContent,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 8,
                        child: leftContent,
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        flex: 4,
                        child: rightContent,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  /// ================= Large Card =================
  Widget animatedLargeCard({
    required int index,
    required double width,
    required Color color,
    required String emoji,
    required String number,
    required String title,
    Color? textColor,
  }) {
    final isHovered = hoveredLargeCardIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hoveredLargeCardIndex = index),
      onExit: (_) => setState(() => hoveredLargeCardIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, isHovered ? -8 : 0, 0),
        width: width,
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isHovered ? 0.12 : 0.05),
              blurRadius: isHovered ? 20 : 10,
              offset: Offset(0, isHovered ? 12 : 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            const Spacer(),
            Text(
              number,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  /// ================= Quick Action Button =================
  Widget _actionBtn({
    required int index,
    required double width,
    required String emoji,
    required String title,
    required Widget page,
    Color? customBgColor,
  }) {
    final isHovered = hoveredSmallCardIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hoveredSmallCardIndex = index),
      onExit: (_) => setState(() => hoveredSmallCardIndex = null),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, isHovered ? -4.0 : 0.0)
            ..scale(isHovered ? 1.02 : 1.0),
          width: width,
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: customBgColor ?? 
                (isHovered
                    ? const Color(0xFF0C4678)
                    : const Color(0xFF0E4F87)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
