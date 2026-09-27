import 'package:flutter/material.dart';
import 'package:ed_app/state/app_state.dart';
import 'device_profile1.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isScanning = true;
  String _scanStatus = "Align QR Code inside the box";
  Color _scannerColor = const Color(0xFF0E4F87);
  int _activeTab = 0; // 0 for Simulation, 1 for Manual Entry

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onScanSuccess(String deviceId) {
    setState(() {
      _isScanning = false;
      _scanStatus = "QR Code Detected! Opening profile...";
      _scannerColor = Colors.green;
    });

    // Play a brief success animation and navigate
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DeviceProfile(deviceId: deviceId),
          ),
        );
      }
    });
  }

  void _onScanError(String message) {
    setState(() {
      _scanStatus = message;
      _scannerColor = Colors.red;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _scanStatus = "Align QR Code inside the box";
          _scannerColor = const Color(0xFF0E4F87);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Device QR Scanner",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Main Section: Viewfinder & Quick Instructions
              isMobile
                  ? Column(
                      children: [
                        _buildViewfinder(),
                        const SizedBox(height: 24),
                        _buildControlsCard(appState),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildViewfinder()),
                        const SizedBox(width: 24),
                        Expanded(flex: 7, child: _buildControlsCard(appState)),
                      ],
                    ),
              const SizedBox(height: 30),
              _buildHelpSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Viewfinder showing simulated camera layout
  Widget _buildViewfinder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Viewfinder Screen
          Stack(
            alignment: Alignment.center,
            children: [
              // Scanner box/border
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // Animated Laser Line
              if (_isScanning)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Positioned(
                      top: 10 + (_animationController.value * 240),
                      child: Container(
                        width: 240,
                        height: 3,
                        decoration: BoxDecoration(
                          color: _scannerColor,
                          boxShadow: [
                            BoxShadow(
                              color: _scannerColor.withValues(alpha: 0.8),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Scanner Corners
              Positioned(
                top: 0,
                left: 0,
                child: _buildCorner(top: true, left: true),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _buildCorner(top: true, left: false),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: _buildCorner(top: false, left: true),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: _buildCorner(top: false, left: false),
              ),

              // Animated scan radar pulse
              if (_isScanning)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.2),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _scannerColor.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                  onEnd: () {},
                ),

              // Camera Icon in center
              if (!_isScanning)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 72,
                )
              else
                Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white.withValues(alpha: 0.15),
                  size: 64,
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Status Text
          Text(
            _scanStatus,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _scannerColor == const Color(0xFF0E4F87)
                  ? Colors.white70
                  : _scannerColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "CAMERA FEED SIMULATOR ACTIVE",
            style: TextStyle(
              color: Colors.white30,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Draw corner brackets
  Widget _buildCorner({required bool top, required bool left}) {
    const double size = 24;
    const double thickness = 4;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: !top ? 0 : null,
            left: left ? 0 : null,
            right: !left ? 0 : null,
            child: Container(
              width: size,
              height: thickness,
              color: _scannerColor,
            ),
          ),
          Positioned(
            top: top ? 0 : null,
            bottom: !top ? 0 : null,
            left: left ? 0 : null,
            right: !left ? 0 : null,
            child: Container(
              width: thickness,
              height: size,
              color: _scannerColor,
            ),
          ),
        ],
      ),
    );
  }

  // Interactive controls: simulation & manual input tabs
  Widget _buildControlsCard(AppState appState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tab selection header
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _activeTab == 0
                              ? const Color(0xFF0E4F87)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      "Simulate Scan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _activeTab == 0 ? const Color(0xFF0E4F87) : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _activeTab == 1
                              ? const Color(0xFF0E4F87)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      "Manual Entry",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _activeTab == 1 ? const Color(0xFF0E4F87) : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: _activeTab == 0
                ? _buildSimulationTab(appState)
                : _buildManualTab(appState),
          ),
        ],
      ),
    );
  }

  // Tab 1: Simulated scan of active devices
  Widget _buildSimulationTab(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Simulate Scanning Device QR Tag",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          "Click 'Simulate Scan' to replicate placing the camera over the device's physical QR sticker.",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appState.devices.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final device = appState.devices[index];

            Color statusColor = Colors.green;
            if (device.status == 'Maintenance') statusColor = Colors.orange;
            if (device.status == 'Critical') statusColor = Colors.red;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Icon indicator
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.qr_code_2,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${device.name} (${device.room})",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Scan Button
                  ElevatedButton(
                    onPressed: _isScanning
                        ? () => _onScanSuccess(device.id)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD7F1FF),
                      foregroundColor: const Color(0xFF0E4F87),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text("Simulate Scan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Tab 2: Manual entry form
  Widget _buildManualTab(AppState appState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Enter Device QR Code Manually",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            "If the QR sticker is scratched or the camera is faulty, input the physical Device ID.",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: "Device ID / Serial Code",
              hintText: "e.g., VNT-2024-001",
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.keyboard),
              fillColor: const Color(0xFFF8FAFC),
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF0E4F87), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter a device ID";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final input = _codeController.text.trim();
                  // Check if device exists
                  final match = appState.devices.any(
                    (d) => d.id.toUpperCase() == input.toUpperCase(),
                  );

                  if (match) {
                    // Find actual casing
                    final actualId = appState.devices
                        .firstWhere(
                          (d) => d.id.toUpperCase() == input.toUpperCase(),
                        )
                        .id;
                    _onScanSuccess(actualId);
                  } else {
                    _onScanError("Device ID '$input' not found in inventory!");
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E4F87),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "VERIFY & OPEN PROFILE",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            "Registered ID format references:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: appState.devices.map((device) {
              return ActionChip(
                label: Text(device.id, style: const TextStyle(fontSize: 11)),
                backgroundColor: Colors.grey.shade100,
                onPressed: () {
                  _codeController.text = device.id;
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Help Section card
  Widget _buildHelpSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF0E4F87)),
              SizedBox(width: 10),
              Text(
                "How Equipment QR Systems Work",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _helpBullet("1", "Each medical device in the system has a unique QR Code generated on its profile page."),
          _helpBullet("2", "Physical stickers can be printed and placed directly on the corresponding devices in the ER/ICU."),
          _helpBullet("3", "When an engineer scans the sticker, the app instantly redirects to its profile for quick logging, reporting issues, or editing maintenance logs."),
        ],
      ),
    );
  }

  Widget _helpBullet(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: const Color(0xFFD7F1FF),
            child: Text(
              number,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0E4F87)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
