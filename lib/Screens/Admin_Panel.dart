import 'package:flutter/material.dart';
import 'package:ed_app/state/app_state.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Management Analytics & KPIs",
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
          // Sort devices by failures to get top failures
          final sortedDevices = List<MedicalDevice>.from(appState.devices)
            ..sort((a, b) => b.previousFailures.compareTo(a.previousFailures));
          final topFailingDevices = sortedDevices.take(3).toList();

          final availabilityPercent = appState.deviceAvailabilityRate;
          final cost = appState.monthlyMaintenanceCost;
          final mttr = appState.meanTimeToRepairHours;

          // Build KPIs
          final kpis = [
            _kpiCard(
              title: "Device Availability",
              value: "${availabilityPercent.toStringAsFixed(1)}%",
              subtitle: "Target: >95.0%",
              icon: Icons.check_circle_outline,
              color: availabilityPercent >= 95 ? Colors.green : Colors.orange,
              fullWidth: isMobile,
            ),
            _kpiCard(
              title: "MTTR (Repair Time)",
              value: "$mttr hrs",
              subtitle: "15% improvement from last month",
              icon: Icons.timer_outlined,
              color: Colors.blue.shade700,
              fullWidth: isMobile,
            ),
            _kpiCard(
              title: "Maintenance Cost",
              value: "\$${cost.toStringAsFixed(2)}",
              subtitle: "Parts + Overhead",
              icon: Icons.attach_money,
              color: Colors.purple.shade700,
              fullWidth: isMobile,
            ),
          ];

          Widget buildKpiLayout() {
            if (isMobile) {
              return Column(
                children: [
                  kpis[0],
                  const SizedBox(height: 12),
                  kpis[1],
                  const SizedBox(height: 12),
                  kpis[2],
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(child: kpis[0]),
                  const SizedBox(width: 16),
                  Expanded(child: kpis[1]),
                  const SizedBox(width: 16),
                  Expanded(child: kpis[2]),
                ],
              );
            }
          }

          Widget buildMalfunctioningDevices() {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Most Malfunctioning Devices",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Priority replacement candidates based on failure count.",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topFailingDevices.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final device = topFailingDevices[index];
                      final progress = (device.previousFailures / 10).clamp(0.0, 1.0);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "ID: ${device.id} | Room: ${device.room}",
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${device.previousFailures} failures",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 80,
                                  height: 5,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      color: Colors.red,
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                  ),
                                )
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

          Widget buildCategoryBreakdown() {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Maintenance Category Breakdown",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _chartBar("Preventive Routine", 0.50, Colors.blue.shade700),
                  const SizedBox(height: 14),
                  _chartBar("Predictive AI-Triggered", 0.35, Colors.green.shade700),
                  const SizedBox(height: 14),
                  _chartBar("Corrective (Post-Failure)", 0.15, Colors.red.shade700),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total operations logged:", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const Text("36 audits this month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildKpiLayout(),
                const SizedBox(height: 24),
                isMobile
                    ? Column(
                        children: [
                          buildMalfunctioningDevices(),
                          const SizedBox(height: 16),
                          buildCategoryBreakdown(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: buildMalfunctioningDevices()),
                          const SizedBox(width: 16),
                          Expanded(flex: 3, child: buildCategoryBreakdown()),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool fullWidth,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
            Text("${(percentage * 100).round()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
