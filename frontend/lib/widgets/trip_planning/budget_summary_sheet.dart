import 'package:flutter/material.dart';
import '../../models/trip_plan_budget.dart';
import '../common/sheet_scaffold.dart';

class BudgetSummarySheet extends StatelessWidget {
  final TripPlanBudget budget;

  const BudgetSummarySheet({super.key, required this.budget});

  static Future<void> show(BuildContext context, TripPlanBudget budget) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BudgetSummarySheet(budget: budget),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      heightFactor: 0.86,
      title: 'Budget summary',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: Colors.blue.shade700,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final isOver = budget.isOverBudget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOver ? Colors.orange.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isOver ? Colors.orange.shade300 : Colors.green.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isOver ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: isOver ? Colors.orange.shade800 : Colors.green.shade700,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOver ? 'Budget needs attention' : 'Plan fits your budget',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOver
                          ? 'Some estimated costs exceed your budget.'
                          : 'The estimated plan is currently within your budget.',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _metric('Budget', '${budget.totalBudget.toStringAsFixed(0)} DH')),
            Expanded(child: _metric('Spent', '${budget.totalSpent.toStringAsFixed(0)} DH')),
            Expanded(
              child: _metric(
                budget.remainingBudget >= 0 ? 'Remaining' : 'Over',
                '${(budget.remainingBudget >= 0 ? budget.remainingBudget : -budget.remainingBudget).toStringAsFixed(0)} DH',
                valueColor: budget.remainingBudget < 0 ? Colors.red.shade700 : null,
              ),
            ),
          ],
        ),
        if (budget.allocated.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Budget allocation', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 4),
          _categoryRow('Accommodation', budget.allocated['accommodation'], budget.spent['accommodation']),
          _categoryRow('Food', budget.allocated['food'], budget.spent['food']),
          _categoryRow('Activities', budget.allocated['activities'], budget.spent['activities']),
          _categoryRow('Transport', budget.allocated['transport'], budget.spent['transport']),
        ],
        if (budget.overBudget > 0) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.trending_up, size: 20, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estimated over-budget amount: ${budget.overBudget.toStringAsFixed(2)} DH',
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _metric(String label, String value, {Color? valueColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: valueColor ?? Colors.blueGrey.shade800)),
        ],
      ),
    );
  }

  Widget _categoryRow(String label, dynamic allocatedValue, dynamic spentValue) {
    final allocated = allocatedValue is num ? allocatedValue.toDouble() : double.tryParse(allocatedValue?.toString() ?? '') ?? 0;
    final spentAmount = spentValue is num ? spentValue.toDouble() : double.tryParse(spentValue?.toString() ?? '') ?? 0;
    final difference = allocated - spentAmount;
    final isOver = difference < 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Spent: ${spentAmount.toStringAsFixed(2)} DH', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              const SizedBox(height: 2),
              Text(
                isOver ? 'Over by ${(-difference).toStringAsFixed(2)} DH' : '${difference.toStringAsFixed(2)} DH left',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isOver ? Colors.red.shade700 : Colors.green.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}