import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ed_app/state/app_state.dart';

class DeviceProfile extends StatefulWidget {
  final String deviceId;
  const DeviceProfile({super.key, required this.deviceId});

  @override
  State<DeviceProfile> createState() => _DeviceProfileState();
}

class _DeviceProfileState extends State<DeviceProfile> {
  final _logFormKey = GlobalKey<FormState>();
  final TextEditingController _logController = TextEditingController();
  String? selectedPartToUse;

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1000;
    
    // Find device
    final deviceIndex = appState.devices.indexWhere((d) => d.id == widget.deviceId);
    if (deviceIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text("Device Not Found")),
        body: const Center(child: Text("Specified device does not exist.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Device Profile: ${widget.deviceId}",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final device = appState.devices[deviceIndex];
          final ai = device.aiPrediction;
          final int risk = ai['riskPercent'];
          final String suggestedDate = ai['suggestedDate'];

          Color statusColor = Colors.green;
          if (device.status == 'Maintenance') statusColor = Colors.orange;
          if (device.status == 'Critical') statusColor = Colors.red;

          Color riskColor = Colors.green;
          if (risk > 70) riskColor = Colors.red;
          else if (risk > 40) riskColor = Colors.orange;

          // Column 1: Basic Info & QR Code
          Widget buildBasicAndQr() {
            return Column(
              children: [
                // Basic info box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(device.brand, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              device.status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _detailRow("Device Type", device.type),
                      _detailRow("Model Number", device.model),
                      _detailRow("Current Location", "📍 ${device.room}"),
                      _detailRow("Age in Operation", "${device.ageMonths} months"),
                      _detailRow("Accumulated Hours", "${device.usageHours} hrs"),
                      _detailRow("Last Maintenance", device.lastMaintenanceDate),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // QR Code Sticker Card
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Device Physical QR Code Sticker",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Print and paste this sticker on the physical device. Engineers scan it to view this exact profile.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 16),
                      // QR image
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: QrImageView(
                          data: device.id,
                          version: QrVersions.auto,
                          size: 140.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        device.id,
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Simulating Print Command...")),
                          );
                        },
                        icon: const Icon(Icons.print),
                        label: const Text("Print Sticker"),
                      )
                    ],
                  ),
                ),
              ],
            );
          }

          // Column 2: AI Predictive Maintenance
          Widget buildAiPredictive() {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            "AI Failure Prediction Engine",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Risk progress indicator
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: risk / 100,
                                    strokeWidth: 10,
                                    color: riskColor,
                                    backgroundColor: Colors.grey.shade100,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "$risk%",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: riskColor,
                                      ),
                                    ),
                                    const Text(
                                      "Failure Risk",
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: riskColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                risk > 70
                                    ? "🚨 Critical Risk: Maintenance highly advised immediately."
                                    : risk > 40
                                        ? "⚠️ Moderate Risk: Schedule preventive service."
                                        : "✅ Normal Risk: Device operating safely.",
                                style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      
                      // AI Breakdown details
                      const Text(
                        "Prediction Input Variables Analyzed:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      _aiFactorRow("Operating Age Weight", "${(device.ageMonths * 0.5).toStringAsFixed(1)} pts", "Age: ${device.ageMonths} months"),
                      _aiFactorRow("Usage Hours Weight", "${(device.usageHours * 0.01).toStringAsFixed(1)} pts", "Hours: ${device.usageHours} hrs"),
                      _aiFactorRow("Historical Failures Weight", "${(device.previousFailures * 15.0).toStringAsFixed(1)} pts", "${device.previousFailures} past breakdowns"),
                      _aiFactorRow("Maintenance Counter Deduction", "-${(device.maintenanceCount * 4.5).toStringAsFixed(1)} pts", "${device.maintenanceCount} calibrations"),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Next inspection output
                      const Text(
                        "Suggested Maintenance Date:",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestedDate,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: risk > 50 ? Colors.red : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // Spare parts historically used
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Spare Parts Replaced", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),
                      if (device.sparePartsUsed.isEmpty)
                        const Text("No parts replaced on this device yet.", style: TextStyle(color: Colors.grey, fontSize: 13))
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: device.sparePartsUsed.map((item) {
                            return Chip(
                              label: Text("${item['part']} (${item['date']})", style: const TextStyle(fontSize: 11)),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                )
              ],
            );
          }

          // Column 3: Maintenance Logs & Technical Form
          Widget buildLogsAndForm() {
            return Column(
              children: [
                // Log new action
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Form(
                    key: _logFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Log Technical Maintenance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),
                        // Description
                        TextFormField(
                          controller: _logController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: "Describe inspection, repairs, calibration...",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        // Spare part choice
                        const Text("Spare Part Used (Optional):", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedPartToUse,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text("Select a spare part"),
                          items: appState.spareParts.map((part) {
                            return DropdownMenuItem<String>(
                              value: part.name,
                              child: Text("${part.name} (Qty: ${part.currentStock})"),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedPartToUse = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_logFormKey.currentState!.validate()) {
                                appState.addMaintenanceLog(
                                  device.id,
                                  _logController.text,
                                  partUsed: selectedPartToUse,
                                );

                                _logController.clear();
                                setState(() {
                                  selectedPartToUse = null;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Maintenance logged successfully!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E4F87),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Text("SAVE WORK LOG", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Logs history list
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Maintenance Audit History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: device.maintenanceLogs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.history_edu, size: 18, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  device.maintenanceLogs[index],
                                  style: const TextStyle(fontSize: 13, height: 1.3),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildBasicAndQr(),
                      const SizedBox(height: 20),
                      buildAiPredictive(),
                      const SizedBox(height: 20),
                      buildLogsAndForm(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: buildBasicAndQr()),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: buildAiPredictive()),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: buildLogsAndForm()),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _aiFactorRow(String name, String points, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                Text(description, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(points, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}
