import 'package:flutter/material.dart';
import 'package:ed_app/state/app_state.dart';

class SparePartsScreen extends StatefulWidget {
  const SparePartsScreen({super.key});

  @override
  State<SparePartsScreen> createState() => _SparePartsScreenState();
}

class _SparePartsScreenState extends State<SparePartsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Spare Parts Inventory",
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
          final lowStockItems = appState.spareParts.where((p) => p.status == 'Low Stock').length;
          final outOfStockItems = appState.spareParts.where((p) => p.status == 'Out of Stock').length;

          // Build metric cards
          final cards = [
            _metricCard("Total Catalog Items", "${appState.spareParts.length}", Colors.blue.shade700),
            _metricCard("Low Stock Alerts", "$lowStockItems", Colors.orange.shade700),
            _metricCard("Out of Stock Alerts", "$outOfStockItems", Colors.red.shade700),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI metrics
                if (isMobile)
                  Column(
                    children: [
                      cards[0],
                      const SizedBox(height: 12),
                      cards[1],
                      const SizedBox(height: 12),
                      cards[2],
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 16),
                      Expanded(child: cards[1]),
                      const SizedBox(width: 16),
                      Expanded(child: cards[2]),
                    ],
                  ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  "Inventory Database Status",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // Table
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.01),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 48,
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                          columns: const [
                            DataColumn(label: Text("Part Name", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Stock Level", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Min Stock", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Unit Cost", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Supplier", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: appState.spareParts.map((part) {
                            Color statusColor = Colors.green;
                            if (part.status == 'Low Stock') statusColor = Colors.orange;
                            if (part.status == 'Out of Stock') statusColor = Colors.red;

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    part.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    "${part.currentStock} units",
                                    style: TextStyle(
                                      color: part.currentStock == 0 ? Colors.red : Colors.black87,
                                      fontWeight: part.currentStock == 0 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                DataCell(Text("${part.minStock} units")),
                                DataCell(Text("\$${part.unitCost.toStringAsFixed(2)}")),
                                DataCell(Text(part.supplier, style: TextStyle(color: Colors.grey.shade600))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      part.status,
                                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  part.status == 'In Stock'
                                      ? const Text("No Action Needed", style: TextStyle(color: Colors.grey, fontSize: 12))
                                      : ElevatedButton(
                                          onPressed: () {
                                            appState.reorderPart(part.name);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Reordered 10 units of ${part.name}!"),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue.shade700,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            minimumSize: const Size(60, 30),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          ),
                                          child: const Text("Reorder", style: TextStyle(fontSize: 12)),
                                        ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metricCard(String title, String val, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(
            val,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
