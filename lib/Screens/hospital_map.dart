import 'package:flutter/material.dart';
import 'package:ed_app/state/app_state.dart';
import 'device_profile1.dart';

class HospitalMap extends StatefulWidget {
  const HospitalMap({super.key});

  @override
  State<HospitalMap> createState() => _HospitalMapState();
}

class _HospitalMapState extends State<HospitalMap> {
  String? selectedRoom;

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    // Group devices by room
    final Map<String, List<MedicalDevice>> roomDevices = {};
    for (var device in appState.devices) {
      if (!roomDevices.containsKey(device.room)) {
        roomDevices[device.room] = [];
      }
      roomDevices[device.room]!.add(device);
    }

    // List of rooms with their locations on our grid
    final roomsList = [
      {"id": "ER-101", "name": "Emergency Room 101"},
      {"id": "ER-102", "name": "Emergency Room 102"},
      {"id": "ER-203", "name": "Emergency Room 203"},
      {"id": "ICU-02", "name": "Intensive Care Unit 02"},
      {"id": "Triage", "name": "Triage Area"},
      {"id": "Radiology", "name": "Radiology Department"},
    ];

    Color getRoomColor(String roomId) {
      final devices = roomDevices[roomId] ?? [];
      if (devices.isEmpty) return Colors.grey.shade100;
      if (devices.any((d) => d.status == 'Critical')) {
        return const Color(0xFFFFECEF); // Light Red
      }
      if (devices.any((d) => d.status == 'Maintenance')) {
        return const Color(0xFFFFF7E6); // Light Yellow
      }
      return const Color(0xFFE6FFED); // Light Green
    }

    Color getRoomBorderColor(String roomId) {
      final devices = roomDevices[roomId] ?? [];
      if (devices.isEmpty) return Colors.grey.shade300;
      if (devices.any((d) => d.status == 'Critical')) {
        return Colors.red.shade400;
      }
      if (devices.any((d) => d.status == 'Maintenance')) {
        return Colors.orange.shade400;
      }
      return Colors.green.shade400;
    }

    Widget buildFloorPlan() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Emergency Department Layout",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              "Visual representations of department rooms. Click a room to view installed devices.",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            // Room Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 1.3 : 1.25,
              ),
              itemCount: roomsList.length,
              itemBuilder: (context, index) {
                final room = roomsList[index];
                final roomId = room["id"] as String;
                final roomName = room["name"] as String;
                final devices = roomDevices[roomId] ?? [];
                final isSelected = selectedRoom == roomId;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedRoom = roomId;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: getRoomColor(roomId),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue.shade700 : getRoomBorderColor(roomId),
                        width: isSelected ? 3.0 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              roomId,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(
                              roomId == "ICU-02"
                                  ? Icons.local_hospital
                                  : roomId.contains("ER")
                                      ? Icons.emergency
                                      : roomId == "Triage"
                                          ? Icons.assignment
                                          : Icons.biotech,
                              size: 18,
                              color: Colors.grey.shade700,
                            )
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          roomName,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        // Device dots
                        Wrap(
                          spacing: 4,
                          children: devices.map((d) {
                            Color dotColor = Colors.green;
                            if (d.status == 'Maintenance') dotColor = Colors.orange;
                            if (d.status == 'Critical') dotColor = Colors.red;

                            return Tooltip(
                              message: "${d.name} (${d.status})",
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _legendItem(Colors.green, "All Working"),
                _legendItem(Colors.orange, "Under Maintenance"),
                _legendItem(Colors.red, "Critical / Blocked"),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildSideInfoPanel() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: selectedRoom == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      "Select a Room",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Click on any room block above to see details of the devices inside.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    )
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Devices in $selectedRoom",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (roomDevices[selectedRoom!] ?? []).length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final device = roomDevices[selectedRoom!]![index];
                      Color statusColor = Colors.green;
                      if (device.status == 'Maintenance') statusColor = Colors.orange;
                      if (device.status == 'Critical') statusColor = Colors.red;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    device.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    device.status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "ID: ${device.id} | ${device.brand}",
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Failure Risk: ${device.aiPrediction['riskPercent']}%",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: device.aiPrediction['riskPercent'] > 60
                                        ? Colors.red
                                        : Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DeviceProfile(deviceId: device.id),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Details →",
                                    style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Hospital Live Heat Map",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: isMobile
                ? Column(
                    children: [
                      buildFloorPlan(),
                      const SizedBox(height: 16),
                      buildSideInfoPanel(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: buildFloorPlan(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: buildSideInfoPanel(),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}
