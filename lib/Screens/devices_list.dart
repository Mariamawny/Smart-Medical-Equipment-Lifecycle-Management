import 'package:flutter/material.dart';
import 'package:ed_app/state/app_state.dart';
import 'device_profile1.dart';
import 'qr_scanner.dart';

class DevicesList extends StatefulWidget {
  const DevicesList({super.key});

  @override
  State<DevicesList> createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  String searchQuery = "";
  String statusFilter = "All";
  int? _hoveredCardIndex;

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "ED Equipment Inventory",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF0E4F87)),
            tooltip: "Scan Device QR Code",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScannerScreen()),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          // Filter devices
          final filteredDevices = appState.devices.where((device) {
            final matchesSearch = device.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                device.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
                device.room.toLowerCase().contains(searchQuery.toLowerCase()) ||
                device.brand.toLowerCase().contains(searchQuery.toLowerCase()) ||
                device.model.toLowerCase().contains(searchQuery.toLowerCase());

            final matchesStatus = statusFilter == "All" || device.status == statusFilter;

            return matchesSearch && matchesStatus;
          }).toList();

          final double paddingValue = isMobile ? 16.0 : 20.0;
          final double availableWidth = screenWidth - (paddingValue * 2);
          final double cardWidth = isMobile
              ? availableWidth
              : (screenWidth < 900 ? (availableWidth - 16) / 2 : 360.0);

          return SingleChildScrollView(
            padding: EdgeInsets.all(paddingValue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search and Filter Controls (Responsive)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: isMobile
                      ? Column(
                          children: [
                            // Search field
                            TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search by ID, name, room...",
                                prefixIcon: const Icon(Icons.search, size: 20),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                fillColor: const Color(0xFFF1F5F9),
                                filled: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Filter dropdown
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7F1FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: statusFilter,
                                  isExpanded: true,
                                  items: ["All", "Working", "Maintenance", "Critical"].map((String val) {
                                    return DropdownMenuItem<String>(
                                      value: val,
                                      child: Text("Filter: $val", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D4C82))),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        statusFilter = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Search by ID, name, room...",
                                  prefixIcon: const Icon(Icons.search, size: 20),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  fillColor: const Color(0xFFF1F5F9),
                                  filled: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7F1FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: statusFilter,
                                  items: ["All", "Working", "Maintenance", "Critical"].map((String val) {
                                    return DropdownMenuItem<String>(
                                      value: val,
                                      child: Text("Filter: $val", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D4C82))),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        statusFilter = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 20),

                if (filteredDevices.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.device_unknown, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text("No devices match your criteria", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: List.generate(filteredDevices.length, (index) {
                      final device = filteredDevices[index];
                      final isHovered = _hoveredCardIndex == index;
                      final ai = device.aiPrediction;
                      final int risk = ai['riskPercent'];

                      Color statusColor = Colors.green;
                      if (device.status == 'Maintenance') {
                        statusColor = Colors.orange;
                      }
                      if (device.status == 'Critical') {
                        statusColor = Colors.red;
                      }

                      Color riskColor = Colors.green;
                      if (risk > 70) {
                        riskColor = Colors.red;
                      } else if (risk > 40) {
                        riskColor = Colors.orange;
                      }

                      return MouseRegion(
                        onEnter: (_) => setState(() => _hoveredCardIndex = index),
                        onExit: (_) => setState(() => _hoveredCardIndex = null),
                        cursor: SystemMouseCursors.click,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 300,
                          width: cardWidth,
                          padding: const EdgeInsets.all(18),
                          transform: isHovered
                              ? (Matrix4.identity()..translate(0, -6, 0))
                              : Matrix4.identity(),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: isHovered ? 0.25 : 0.1),
                                blurRadius: isHovered ? 16.0 : 8.0,
                                offset: Offset(0, isHovered ? 8.0 : 4.0),
                              ),
                            ],
                            border: Border.all(
                              color: device.status == 'Critical' ? Colors.red.withValues(alpha: 0.3) : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        device.type == "Ventilator"
                                            ? Icons.air
                                            : device.type == "Defibrillator"
                                                ? Icons.bolt
                                                : device.type == "Patient Monitor"
                                                    ? Icons.monitor_heart
                                                    : Icons.settings,
                                        color: statusColor,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          device.id,
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          device.name,
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),

                              // Stats
                              _infoRow("Location", "📍 ${device.room}"),
                              const SizedBox(height: 6),
                              _infoRow("Status", device.status, badgeColor: statusColor),
                              const SizedBox(height: 6),
                              _infoRow("Usage Hours", "${device.usageHours} hrs"),
                              const SizedBox(height: 6),
                              _infoRow(
                                "AI Failure Risk",
                                "$risk%",
                                badgeColor: riskColor,
                                bold: true,
                              ),

                              const Spacer(),

                              // Button
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DeviceProfile(deviceId: device.id),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 36,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD7F1FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "View Profile & Action Details →",
                                      style: TextStyle(
                                        color: Color(0xFF0E4F87),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? badgeColor, bool bold = false}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const Spacer(),
        if (badgeColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }
}
