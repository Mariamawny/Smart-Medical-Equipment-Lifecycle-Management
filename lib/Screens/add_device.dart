import 'package:flutter/material.dart';
import 'package:ed_app/state/app_state.dart';


class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController(text: "0");
  final TextEditingController _ageController = TextEditingController(text: "0");
  
  String selectedType = "Ventilator";
  String selectedRoom = "ER-101";
  String selectedStatus = "Working";

  final List<String> deviceTypes = ["Ventilator", "Defibrillator", "Patient Monitor", "X-Ray", "ECG"];
  final List<String> roomLocations = ["ER-101", "ER-102", "ER-203", "ICU-02", "Triage", "Radiology"];
  final List<String> statusTypes = ["Working", "Maintenance", "Critical"];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    Widget buildResponsiveRow(Widget w1, Widget w2) {
      if (isMobile) {
        return Column(
          children: [
            w1,
            const SizedBox(height: 16),
            w2,
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: w1),
          const SizedBox(width: 16),
          Expanded(child: w2),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Add New Medical Device",
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
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Device Identification",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0E4F87)),
                  ),
                  const SizedBox(height: 16),
                  
                  buildResponsiveRow(
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: "Device ID *",
                        hintText: "e.g., VNT-2024-004",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Device Name *",
                        hintText: "e.g., Philips Trilogy 200",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  buildResponsiveRow(
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: "Brand *",
                        hintText: "e.g., Philips",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                    ),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: "Model *",
                        hintText: "e.g., Trilogy 200",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    "Specifications & Status",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0E4F87)),
                  ),
                  const SizedBox(height: 16),

                  buildResponsiveRow(
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: "Device Type",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: deviceTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedType = val);
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedRoom,
                      decoration: const InputDecoration(
                        labelText: "Room Location",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: roomLocations.map((room) {
                        return DropdownMenuItem(value: room, child: Text(room));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedRoom = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  buildResponsiveRow(
                    TextFormField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Usage Hours",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      validator: (val) => val == null || int.tryParse(val) == null ? "Must be integer" : null,
                    ),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Age (Months)",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      validator: (val) => val == null || int.tryParse(val) == null ? "Must be integer" : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "Operating Status",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: statusTypes.map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedStatus = val);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
                        ),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final appState = AppState();
                            final newDevice = MedicalDevice(
                              id: _idController.text,
                              name: _nameController.text,
                              type: selectedType,
                              brand: _brandController.text,
                              model: _modelController.text,
                              room: selectedRoom,
                              status: selectedStatus,
                              ageMonths: int.parse(_ageController.text),
                              usageHours: int.parse(_hoursController.text),
                              previousFailures: 0,
                              maintenanceCount: 0,
                              lastMaintenanceDate: DateTime.now().toString().substring(0, 10),
                              sparePartsUsed: [],
                              maintenanceLogs: ["Device registered into database."],
                            );

                            appState.addDevice(newDevice);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("New device registered successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E4F87),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text("Register Device", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}