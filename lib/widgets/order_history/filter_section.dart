import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class FilterSection extends StatelessWidget {
  final int? selectedMonth;
  final int? selectedYear;
  final Function(int?) onMonthChanged;
  final Function(int?) onYearChanged;
  final VoidCallback onClearFilters;
  final int currentYear;

  const FilterSection({
    required this.selectedMonth,
    required this.selectedYear,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onClearFilters,
    required this.currentYear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Orders',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Month',
                    prefixIcon: const Icon(LucideIcons.calendar),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  value: selectedMonth,
                  hint: const Text('Select month'),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  menuMaxHeight: 300,
                  isExpanded: true,
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(
                        DateFormat('MMMM').format(DateTime(2024, index + 1)),
                        style: const TextStyle(fontSize: 15),
                      ),
                    );
                  }),
                  onChanged: onMonthChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Year',
                    prefixIcon: const Icon(LucideIcons.calendarDays),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  value: selectedYear ?? currentYear,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  isExpanded: true,
                  items: List.generate(5, (index) {
                    final year = currentYear - index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(
                        year.toString(),
                        style: const TextStyle(fontSize: 15),
                      ),
                    );
                  }),
                  onChanged: onYearChanged,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onClearFilters,
                icon: const Icon(LucideIcons.x),
                tooltip: 'Clear filters',
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
