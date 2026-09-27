import 'package:flutter/material.dart';
import 'package:ed_app/state/app_state.dart';

class MaintenanceHistory extends StatefulWidget {
  const MaintenanceHistory({super.key});

  @override
  State<MaintenanceHistory> createState() => _MaintenanceHistoryState();
}

class _MaintenanceHistoryState extends State<MaintenanceHistory> {
  final _resolveFormKey = GlobalKey<FormState>();
  final TextEditingController _solutionController = TextEditingController();
  String? selectedPartUsed;
  IncidentReport? activeIncidentToResolve;

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    Widget buildTicketsList(List<IncidentReport> pending, List<IncidentReport> resolved) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Active Tickets List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TabBar(
                    labelColor: Color(0xFF0E4F87),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF0E4F87),
                    tabs: [
                      Tab(text: "Pending Reports"),
                      Tab(text: "Resolved Tickets"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        // Pending view
                        pending.isEmpty
                            ? const Center(child: Text("No pending incident tickets", style: TextStyle(color: Colors.grey)))
                            : ListView.separated(
                                itemCount: pending.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final ticket = pending[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      "${ticket.deviceName} (${ticket.deviceId})",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text("Problem: ${ticket.problemType}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 13)),
                                        Text("Location: Room ${ticket.room}", style: const TextStyle(fontSize: 12)),
                                        Text("Time: ${ticket.reportTime.toString().substring(0, 16)}", style: const TextStyle(fontSize: 12)),
                                        if (ticket.notes.isNotEmpty) Text("Notes: ${ticket.notes}", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontSize: 12)),
                                      ],
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          activeIncidentToResolve = ticket;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0E4F87),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text("Resolve", style: TextStyle(fontSize: 12)),
                                    ),
                                  );
                                },
                              ),
                        // Resolved view
                        resolved.isEmpty
                            ? const Center(child: Text("No resolved tickets yet", style: TextStyle(color: Colors.grey)))
                            : ListView.separated(
                                itemCount: resolved.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final ticket = resolved[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      "${ticket.deviceName} (${ticket.deviceId})",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text("Problem: ${ticket.problemType}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 13)),
                                        Text("Location: Room ${ticket.room}", style: const TextStyle(fontSize: 12)),
                                        Text("Status: Resolved ✅", style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget buildResolutionPanel(AppState appState) {
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
        child: activeIncidentToResolve == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        "Select a Ticket",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Click on 'Resolve' next to any pending report to open the repair log panel here.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    ],
                  ),
                ),
              )
            : Form(
                key: _resolveFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Resolve Ticket: ${activeIncidentToResolve!.id}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Device: ${activeIncidentToResolve!.deviceName} (${activeIncidentToResolve!.deviceId})",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    // Description of solution
                    const Text("Technical Resolution Action: *", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _solutionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Describe the repairs performed, calibration tests run...",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    // Part used dropdown
                    const Text("Spare Part Replaced: (Optional)", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedPartUsed,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text("Select part used"),
                      items: appState.spareParts.map((part) {
                        return DropdownMenuItem<String>(
                          value: part.name,
                          child: Text("${part.name} (${part.currentStock} left)"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedPartUsed = val;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                activeIncidentToResolve = null;
                                _solutionController.clear();
                                selectedPartUsed = null;
                              });
                            },
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_resolveFormKey.currentState!.validate()) {
                                appState.resolveIncident(
                                  activeIncidentToResolve!.id,
                                  _solutionController.text,
                                  partUsed: selectedPartUsed,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Ticket resolved. Status restored to working!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                setState(() {
                                  activeIncidentToResolve = null;
                                  _solutionController.clear();
                                  selectedPartUsed = null;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Confirm"),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Tickets Log",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Generating Maintenance Audit PDF...")),
                );
              },
              icon: const Icon(Icons.picture_as_pdf, size: 16),
              label: const Text("Export", style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E4F87),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final pending = appState.incidents.where((i) => i.status == 'Pending').toList();
          final resolved = appState.incidents.where((i) => i.status == 'Resolved').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTicketsList(pending, resolved),
                      const SizedBox(height: 16),
                      buildResolutionPanel(appState),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: buildTicketsList(pending, resolved),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: buildResolutionPanel(appState),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}