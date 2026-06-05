import 'package:flutter/material.dart';
import 'package:ed_app/state/app_state.dart';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedRoom;
  String? selectedDeviceId;
  String? selectedProblem;
  final TextEditingController _notesController = TextEditingController();

  final List<String> problemsList = [
    "Device completely dead (No Power)",
    "Slow performance / Unresponsive",
    "Screen / Display flickering",
    "Alarming continuously (Sensor Failure)",
    "Gas supply / pressure warning",
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    // Get rooms that have devices
    final rooms = appState.devices.map((d) => d.room).toSet().toList();

    // Filter devices based on selected room
    final filteredDevices = selectedRoom == null
        ? <MedicalDevice>[]
        : appState.devices.where((d) => d.room == selectedRoom).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Report Equipment Incident",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            maxWidth: 550,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.report_problem, color: Colors.red, size: 28),
                      SizedBox(width: 12),
                      Text(
                        "Urgent Report Portal",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Submit an issue immediately to the maintenance engineer team. The device status will be set to critical.",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Room Selector
                  const Text("1. Select Room / Location", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: "Choose a Room",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: selectedRoom,
                    items: rooms.map((room) {
                      return DropdownMenuItem(value: room, child: Text(room));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedRoom = val;
                        selectedDeviceId = null; // Reset device selection
                      });
                    },
                    validator: (val) => val == null ? "Please select a room" : null,
                  ),
                  const SizedBox(height: 20),

                  // Device Selector
                  const Text("2. Select Malfunctioning Device", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: selectedRoom == null ? "Choose room first" : "Choose a Device",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: selectedDeviceId,
                    items: filteredDevices.map((device) {
                      return DropdownMenuItem(
                        value: device.id,
                        child: Text("${device.name} (${device.id})"),
                      );
                    }).toList(),
                    onChanged: selectedRoom == null
                        ? null
                        : (val) {
                            setState(() {
                              selectedDeviceId = val;
                            });
                          },
                    validator: (val) => val == null ? "Please select a device" : null,
                  ),
                  const SizedBox(height: 20),

                  // Problem Selector
                  const Text("3. Describe the Issue", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: "Select issue type",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: selectedProblem,
                    items: problemsList.map((prob) {
                      return DropdownMenuItem(value: prob, child: Text(prob));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedProblem = val;
                      });
                    },
                    validator: (val) => val == null ? "Please select an issue type" : null,
                  ),
                  const SizedBox(height: 20),

                  // Notes Text Field
                  const Text("4. Additional Comments / Details", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Provide details (e.g. error code displayed, symptoms, context)...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          appState.reportIncident(
                            selectedDeviceId!,
                            selectedProblem!,
                            _notesController.text,
                          );

                          // Success dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green),
                                    SizedBox(width: 10),
                                    Text("Report Submitted"),
                                  ],
                                ),
                                content: const Text(
                                  "The incident has been logged. An engineer has been notified, and the device status has been set to Critical.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Pop dialog
                                      Navigator.pop(context); // Pop IncidentReportScreen
                                    },
                                    child: const Text("OK"),
                                  )
                                ],
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "SUBMIT URGENT REPORT",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
