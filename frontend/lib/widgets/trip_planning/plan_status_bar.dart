import 'package:flutter/material.dart';
import '../../models/trip_plan_budget.dart';
import 'warnings_sheet.dart';
import 'budget_summary_sheet.dart';

class PlanStatusBar extends StatelessWidget {
  final List<String> warnings;
  final TripPlanBudget? budget;

  const PlanStatusBar({super.key, required this.warnings, required this.budget});

  @override
  Widget build(BuildContext context) {
    final hasWarnings = warnings.isNotEmpty;
    final isOverBudget = budget?.overBudget != null && budget!.overBudget > 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: _statusButton(
              icon: hasWarnings ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              label: hasWarnings ? '${warnings.length} warning${warnings.length == 1 ? '' : 's'}' : 'No warnings',
              color: hasWarnings ? Colors.orange.shade800 : Colors.green.shade700,
              backgroundColor: hasWarnings ? Colors.orange.shade50 : Colors.green.shade50,
              onTap: hasWarnings ? () => WarningsSheet.show(context, warnings) : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _statusButton(
              icon: isOverBudget ? Icons.account_balance_wallet_rounded : Icons.account_balance_wallet_outlined,
              label: budget == null
                  ? 'Budget unavailable'
                  : isOverBudget
                  ? 'Over ${budget!.overBudget.toStringAsFixed(0)} DH'
                  : '${budget!.remainingBudget.toStringAsFixed(0)} DH left',
              color: isOverBudget ? Colors.red.shade700 : Colors.blue.shade700,
              backgroundColor: isOverBudget ? Colors.red.shade50 : Colors.blue.shade50,
              onTap: budget != null ? () => BudgetSummarySheet.show(context, budget!) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.25))),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              if (onTap != null) Icon(Icons.chevron_right, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}