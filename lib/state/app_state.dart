import 'package:flutter/material.dart';

class SparePart {
  final String name;
  int currentStock;
  final int minStock;
  final double unitCost;
  final String supplier;
  String status; // 'In Stock', 'Low Stock', 'Out of Stock'

  SparePart({
    required this.name,
    required this.currentStock,
    required this.minStock,
    required this.unitCost,
    required this.supplier,
  }) : status = currentStock == 0
            ? 'Out of Stock'
            : currentStock <= minStock
                ? 'Low Stock'
                : 'In Stock';

  void updateStock(int amount) {
    currentStock = (currentStock + amount).clamp(0, 1000);
    if (currentStock == 0) {
      status = 'Out of Stock';
    } else if (currentStock <= minStock) {
      status = 'Low Stock';
    } else {
      status = 'In Stock';
    }
  }
}

class IncidentReport {
  final String id;
  final String deviceId;
  final String deviceName;
  final String room;
  final String problemType;
  final String notes;
  final DateTime reportTime;
  String status; // 'Pending', 'In Progress', 'Resolved'

  IncidentReport({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.room,
    required this.problemType,
    required this.notes,
    required this.reportTime,
    this.status = 'Pending',
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class MedicalDevice {
  final String id;
  final String name;
  final String type; // 'Ventilator', 'Defibrillator', 'Patient Monitor', 'X-Ray', 'ECG'
  final String brand;
  final String model;
  String room;
  String status; // 'Working', 'Maintenance', 'Critical'
  int ageMonths;
  int usageHours;
  int previousFailures;
  int maintenanceCount;
  String lastMaintenanceDate;
  List<Map<String, String>> sparePartsUsed;
  List<String> maintenanceLogs;

  MedicalDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.brand,
    required this.model,
    required this.room,
    required this.status,
    required this.ageMonths,
    required this.usageHours,
    required this.previousFailures,
    required this.maintenanceCount,
    required this.lastMaintenanceDate,
    required this.sparePartsUsed,
    required this.maintenanceLogs,
  });

  Map<String, dynamic> get aiPrediction {
    // Risk Score Calculation Algorithm:
    // Age weights: 0.5 per month
    // Usage hours weights: 0.01 per hour
    // Previous failures weights: 15 per failure
    // Maintenance frequency deduction: reduces risk by 4.5 per maintenance cycle
    double rawRisk = (ageMonths * 0.5) +
        (usageHours * 0.01) +
        (previousFailures * 15.0) -
        (maintenanceCount * 4.5);

    // Baseline adjustments
    if (status == 'Critical') {
      rawRisk += 45.0;
    } else if (status == 'Maintenance') {
      rawRisk -= 20.0;
    }

    double riskPercent = rawRisk.clamp(5.0, 98.0);

    String suggestedDate;
    if (status == 'Critical') {
      suggestedDate = "Immediate (Emergency Service Required)";
    } else if (riskPercent > 75) {
      suggestedDate = "Urgent: Within 24 Hours";
    } else if (riskPercent > 50) {
      suggestedDate = "Scheduled: Within 3 Days";
    } else if (riskPercent > 30) {
      suggestedDate = "Routine check: Within 2 Weeks";
    } else {
      // Safe, schedule in 3 months
      suggestedDate = "Scheduled: Next 3 Months";
    }

    return {
      'riskPercent': riskPercent.round(),
      'suggestedDate': suggestedDate,
    };
  }
}

class AppState extends ChangeNotifier {
  // Singleton pattern
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Devices
  final List<MedicalDevice> _devices = [
    MedicalDevice(
      id: "VNT-2024-001",
      name: "Trilogy 100 Ventilator",
      type: "Ventilator",
      brand: "Philips Respironics",
      model: "Trilogy 100",
      room: "ER-101",
      status: "Working",
      ageMonths: 18,
      usageHours: 1850,
      previousFailures: 1,
      maintenanceCount: 5,
      lastMaintenanceDate: "2026-05-10",
      sparePartsUsed: [
        {"part": "Oxygen Sensor", "date": "2026-02-15"},
        {"part": "Air Inlet Filter", "date": "2026-05-10"}
      ],
      maintenanceLogs: [
        "Annual validation test passed.",
        "Replaced air inlet filter and cleaned external housing.",
        "Calibrated oxygen sensor and tested high-pressure alarms."
      ],
    ),
    MedicalDevice(
      id: "VNT-2024-002",
      name: "Puritan Bennett 980",
      type: "Ventilator",
      brand: "Medtronic",
      model: "PB980",
      room: "ER-203",
      status: "Maintenance",
      ageMonths: 36,
      usageHours: 4900,
      previousFailures: 4,
      maintenanceCount: 12,
      lastMaintenanceDate: "2026-04-01",
      sparePartsUsed: [
        {"part": "Expiratory Valve", "date": "2025-11-20"},
        {"part": "Backup Battery Pack", "date": "2026-04-01"}
      ],
      maintenanceLogs: [
        "Battery failed diagnostics. Replaced with new Backup Battery Pack.",
        "Routine 1000-hour calibration completed.",
        "Flow sensor calibration warning resolved."
      ],
    ),
    MedicalDevice(
      id: "VNT-2024-003",
      name: "Hamilton-C1 Ventilator",
      type: "Ventilator",
      brand: "Hamilton Medical",
      model: "C1",
      room: "ICU-02",
      status: "Critical",
      ageMonths: 48,
      usageHours: 6200,
      previousFailures: 6,
      maintenanceCount: 14,
      lastMaintenanceDate: "2026-03-15",
      sparePartsUsed: [
        {"part": "Flow Sensor", "date": "2026-01-10"},
        {"part": "O2 Cell", "date": "2026-03-15"}
      ],
      maintenanceLogs: [
        "O2 cell expired; replaced with new part and calibrated.",
        "Touchscreen unresponsive error cleared after ribbon cable reseat."
      ],
    ),
    MedicalDevice(
      id: "DEF-2024-010",
      name: "R Series Defibrillator",
      type: "Defibrillator",
      brand: "ZOLL Medical",
      model: "R Series Plus",
      room: "Triage",
      status: "Working",
      ageMonths: 12,
      usageHours: 320,
      previousFailures: 0,
      maintenanceCount: 2,
      lastMaintenanceDate: "2026-05-20",
      sparePartsUsed: [],
      maintenanceLogs: [
        "Monthly shock testing passed (30J, 150J, 200J).",
        "Pacing functionality verified with simulator."
      ],
    ),
    MedicalDevice(
      id: "MON-2024-022",
      name: "BeneVision N17 Monitor",
      type: "Patient Monitor",
      brand: "Mindray",
      model: "BeneVision N17",
      room: "ER-102",
      status: "Working",
      ageMonths: 30,
      usageHours: 7800,
      previousFailures: 2,
      maintenanceCount: 8,
      lastMaintenanceDate: "2026-01-10",
      sparePartsUsed: [
        {"part": "ECG Trunk Cable", "date": "2025-09-05"},
        {"part": "NIBP Cuff", "date": "2026-01-10"}
      ],
      maintenanceLogs: [
        "NIBP module calibrated. Leak test passed.",
        "Software updated to version 4.2."
      ],
    ),
    MedicalDevice(
      id: "XRY-2024-005",
      name: "Mobile X-Ray System",
      type: "X-Ray",
      brand: "Philips",
      model: "Practix 360",
      room: "Radiology",
      status: "Working",
      ageMonths: 24,
      usageHours: 1200,
      previousFailures: 3,
      maintenanceCount: 4,
      lastMaintenanceDate: "2026-04-18",
      sparePartsUsed: [
        {"part": "Collimator Lamp", "date": "2026-04-18"}
      ],
      maintenanceLogs: [
        "Radiation safety leakage inspection passed.",
        "Collimator lamp replaced and centered."
      ],
    )
  ];

  // Spare Parts
  final List<SparePart> _spareParts = [
    SparePart(name: "Oxygen Sensor", currentStock: 8, minStock: 3, unitCost: 120.0, supplier: "Maxtec Medical Ltd."),
    SparePart(name: "Air Inlet Filter", currentStock: 15, minStock: 5, unitCost: 15.0, supplier: "Filters Corp Inc."),
    SparePart(name: "Expiratory Valve", currentStock: 2, minStock: 3, unitCost: 250.0, supplier: "Medtronic Spare Parts"),
    SparePart(name: "Backup Battery Pack", currentStock: 1, minStock: 2, unitCost: 320.0, supplier: "ZOLL Energy Depot"),
    SparePart(name: "Flow Sensor", currentStock: 4, minStock: 2, unitCost: 180.0, supplier: "Hamilton Medical AG"),
    SparePart(name: "O2 Cell", currentStock: 0, minStock: 2, unitCost: 145.0, supplier: "Analytical Industries"),
    SparePart(name: "ECG Trunk Cable", currentStock: 6, minStock: 2, unitCost: 95.0, supplier: "Mindray Healthcare"),
    SparePart(name: "NIBP Cuff", currentStock: 12, minStock: 4, unitCost: 40.0, supplier: "Mindray Healthcare"),
  ];

  // Incidents
  final List<IncidentReport> _incidents = [
    IncidentReport(
      id: "INC-991",
      deviceId: "VNT-2024-003",
      deviceName: "Hamilton-C1 Ventilator",
      room: "ICU-02",
      problemType: "Screen flickering & pressure drop",
      notes: "The screen is flickering off and on, and low pressure alarm keeps sounding even when connected correctly.",
      reportTime: DateTime.now().subtract(const Duration(hours: 4)),
      status: "Pending",
    )
  ];

  // Chatbot Messages
  final List<ChatMessage> _chatMessages = [
    ChatMessage(
      text: "Welcome back, Engineer. Ask me anything about ED medical equipment errors, troubleshooting, or parts. For example:\n- 'Philips EPIQ shows Error 205'\n- 'ZOLL Defibrillator fails self-test'\n- 'PB980 Ventilator alarm code 104'",
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    )
  ];

  // Notifications
  final List<String> _notifications = [
    "URGENT: Incident reported on Hamilton-C1 Ventilator in ICU-02.",
    "STOCK ALERT: O2 Cell is Out of Stock!",
    "STOCK ALERT: Backup Battery Pack is Low in Stock (1 left).",
    "STOCK ALERT: Expiratory Valve is Low in Stock (2 left).",
    "PREDICTIVE ALERT: BeneVision N17 Monitor in ER-102 has high failure risk (82%). Suggesting immediate maintenance check.",
  ];

  // Getters
  List<MedicalDevice> get devices => _devices;
  List<SparePart> get spareParts => _spareParts;
  List<IncidentReport> get incidents => _incidents;
  List<ChatMessage> get chatMessages => _chatMessages;
  List<String> get notifications => _notifications;

  // Add Device
  void addDevice(MedicalDevice device) {
    _devices.add(device);
    _notifications.insert(0, "New device added: ${device.brand} ${device.model} (${device.id}) in ${device.room}.");
    notifyListeners();
  }

  // Update Status
  void updateDeviceStatus(String id, String status) {
    final deviceIndex = _devices.indexWhere((d) => d.id == id);
    if (deviceIndex != -1) {
      _devices[deviceIndex].status = status;
      _notifications.insert(0, "Device ${id} status updated to ${status}.");
      notifyListeners();
    }
  }

  // Add Maintenance Log
  void addMaintenanceLog(String id, String log, {String? partUsed, String? partUsedDate}) {
    final deviceIndex = _devices.indexWhere((d) => d.id == id);
    if (deviceIndex != -1) {
      final device = _devices[deviceIndex];
      device.maintenanceLogs.insert(0, log);
      device.maintenanceCount += 1;
      device.lastMaintenanceDate = DateTime.now().toString().substring(0, 10);
      if (device.status == 'Critical' || device.status == 'Maintenance') {
        device.status = 'Working';
      }
      if (partUsed != null) {
        device.sparePartsUsed.insert(0, {
          "part": partUsed,
          "date": partUsedDate ?? DateTime.now().toString().substring(0, 10)
        });
        // Deduct spare part stock
        useSparePart(partUsed, 1);
      }
      _notifications.insert(0, "Maintenance logged for device ${id}. Status reset to Working.");
      notifyListeners();
    }
  }

  // Use Spare Part
  void useSparePart(String name, int qty) {
    final partIndex = _spareParts.indexWhere((p) => p.name.toLowerCase() == name.toLowerCase());
    if (partIndex != -1) {
      final part = _spareParts[partIndex];
      part.updateStock(-qty);
      if (part.status == 'Out of Stock') {
        _notifications.insert(0, "CRITICAL STOCK ALERT: ${part.name} is OUT OF STOCK!");
      } else if (part.status == 'Low Stock') {
        _notifications.insert(0, "STOCK ALERT: ${part.name} is low in stock (${part.currentStock} remaining).");
      }
      notifyListeners();
    }
  }

  // Reorder Spare Part
  void reorderPart(String name) {
    final partIndex = _spareParts.indexWhere((p) => p.name == name);
    if (partIndex != -1) {
      final part = _spareParts[partIndex];
      part.updateStock(10); // order 10 units
      _notifications.insert(0, "Reorder request approved: Added 10 units to ${part.name} inventory.");
      notifyListeners();
    }
  }

  // Incident Reporting
  void reportIncident(String deviceId, String problemType, String notes) {
    final device = _devices.firstWhere((d) => d.id == deviceId);
    
    // Create report
    final report = IncidentReport(
      id: "INC-${100 + _incidents.length + 800}",
      deviceId: deviceId,
      deviceName: device.name,
      room: device.room,
      problemType: problemType,
      notes: notes,
      reportTime: DateTime.now(),
      status: "Pending",
    );
    
    _incidents.insert(0, report);
    
    // Update device status to Critical and increase failures count
    device.status = 'Critical';
    device.previousFailures += 1;
    
    _notifications.insert(0, "ALERT: New Incident reported on ${device.name} in Room ${device.room}: $problemType");
    notifyListeners();
  }

  // Resolve Incident
  void resolveIncident(String incidentId, String solutionLog, {String? partUsed}) {
    final index = _incidents.indexWhere((inc) => inc.id == incidentId);
    if (index != -1) {
      final incident = _incidents[index];
      incident.status = 'Resolved';
      
      // Update device
      addMaintenanceLog(
        incident.deviceId, 
        "Incident Resolved: ${incident.problemType}. Solution: $solutionLog",
        partUsed: partUsed
      );
      notifyListeners();
    }
  }

  // Chatbot Send Message
  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;

    _chatMessages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
    notifyListeners();

    // Generate smart response after 500ms delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final query = text.toLowerCase();
      String reply = "";

      if (query.contains("philips") && (query.contains("epiq") || query.contains("trilogy")) && query.contains("205")) {
        reply = "🛠️ **Philips Error Code 205 (Internal Power Fault)**:\n\n"
            "**Possible Cause:** Loss of battery communication or faulty backup battery charger circuit.\n\n"
            "**Steps to Inspect:**\n"
            "1. Disconnect AC power and measure battery terminal voltage (should be >14.4V).\n"
            "2. Inspect the internal power cable harness for pin corrosion or loose connections.\n"
            "3. Run power board diagnostics via Service Mode (Passcode: 4321).\n\n"
            "**Required Spare Parts:** Backup Battery Pack (ZOLL/Philips Compatible) or Internal Power Board Harness.";
      } else if (query.contains("zoll") && query.contains("self-test")) {
        reply = "🛠️ **ZOLL Defibrillator Self-Test Failure**:\n\n"
            "**Possible Cause:** Expired therapy cables, poor pads connection, or dead internal clock battery.\n\n"
            "**Steps to Inspect:**\n"
            "1. Perform a manual 30J shock test into the test port.\n"
            "2. Inspect the multi-function therapy cable connector for bent pins.\n"
            "3. Clean battery contacts with isopropyl alcohol.\n\n"
            "**Required Spare Parts:** Defibrillator Therapy Cable or Pad Connector.";
      } else if (query.contains("pb980") || query.contains("puritan bennett") && query.contains("104")) {
        reply = "🛠️ **PB980 Alarm Code 104 (Inspiratory Module Fault)**:\n\n"
            "**Possible Cause:** Proportional solenoid valve calibration mismatch or high moisture in intake filter.\n\n"
            "**Steps to Inspect:**\n"
            "1. Run SST (Short Self Test) with a gold standard circuit.\n"
            "2. Clean/replace the inspiratory bacteria filter.\n"
            "3. Check gas supply pressure (must be 35-80 psi).\n\n"
            "**Required Spare Parts:** Air Inlet Filter or Expiratory Valve.";
      } else if (query.contains("error") || query.contains("عطل") || query.contains("مشكلة")) {
        reply = "🔍 **General Troubleshooting Assistant**:\n\n"
            "I detected an error query. For specific clinical devices:\n"
            "- Check the internal gas inlet pressure (for ventilators).\n"
            "- Perform system sensor recalibration via the menu.\n"
            "- Swap modular components (cables, sensors) with a known working unit to isolate the issue.\n\n"
            "If you need specific help, mention the device model (e.g. 'PB980', 'Trilogy', 'ZOLL') and error code.";
      } else {
        reply = "👋 Hello Engineer! I can help you diagnose and fix ED medical equipment.\n\n"
            "Try asking me about common problems, such as:\n"
            "• *'What is the cause of low pressure alarm in Hamilton-C1?'*\n"
            "• *'Philips Trilogy Error 205'* \n"
            "• *'How to calibrate Mindray N17 NIBP?'*";
      }

      _chatMessages.add(ChatMessage(text: reply, isUser: false, time: DateTime.now()));
      notifyListeners();
    });
  }

  // Dashboard Statistics Getters
  int get workingDevicesCount => _devices.where((d) => d.status == 'Working').length;
  int get maintenanceDevicesCount => _devices.where((d) => d.status == 'Maintenance').length;
  int get criticalDevicesCount => _devices.where((d) => d.status == 'Critical').length;
  
  double get deviceAvailabilityRate {
    if (_devices.isEmpty) return 0.0;
    int total = _devices.length;
    int offline = _devices.where((d) => d.status == 'Critical').length;
    return ((total - offline) / total) * 100.0;
  }

  double get monthlyMaintenanceCost {
    // Sum the unit cost of used spare parts in our devices
    double cost = 0.0;
    for (var device in _devices) {
      for (var partInfo in device.sparePartsUsed) {
        final partName = partInfo['part'];
        final part = _spareParts.firstWhere((p) => p.name == partName, orElse: () => SparePart(name: '', currentStock: 0, minStock: 0, unitCost: 0.0, supplier: ''));
        cost += part.unitCost;
      }
    }
    // Add base service overhead costs
    return cost + 1200.00;
  }

  double get meanTimeToRepairHours {
    // Simulation based on resolved reports
    return 1.8;
  }
}
