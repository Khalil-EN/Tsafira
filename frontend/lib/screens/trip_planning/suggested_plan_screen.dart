import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/plan_provider.dart';
import '../../providers/suggested_plan_provider.dart';

import '../../models/trip_plan_item.dart';
import '../../models/trip_plan_item_converters.dart';

import '../../utils/suggested_plan_parser.dart';
import '../../exceptions/premium_required_exception.dart';
import '../../exceptions/session_expired_exception.dart';
import '../../widgets/trip_planning/day_selector.dart';
import '../../widgets/trip_planning/plan_status_bar.dart';
import '../../widgets/trip_planning/day_content.dart';
import '../auth/login_screen.dart';
import '../premium/premium_upgrade_screen.dart';
// Adjust these three to wherever your detail screens ended up:
import '../residences/residence_details.dart';
import '../restaurants/restaurant_details.dart';
import '../activities/activity_details_page.dart';

class SuggestMyPlan extends StatelessWidget {
  const SuggestMyPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final planProvider = Provider.of<PlanProvider>(context, listen: false);
        final provider = SuggestedPlanProvider();
        provider.load(planProvider.toMap(), planProvider.days);
        return provider;
      },
      child: const _SuggestMyPlanView(),
    );
  }
}

class _SuggestMyPlanView extends StatelessWidget {
  const _SuggestMyPlanView();

  AppBar _buildAppBar() {
    return AppBar(
      leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      title: const Text('Suggested Plan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    );
  }

  void _openItemDetails(BuildContext context, TripPlanItem item) {
    switch (item.type) {
      case 'residency':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResidenceDetails(
              residence: item.toResidence(),
            ),
          ),
        );
        break;

      case 'breakfast':
      case 'restaurant':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDetails(
              restaurant: item.toRestaurant(),
            ),
          ),
        );
        break;

      case 'breakfastUnavailable':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Breakfast was requested, but no suitable breakfast restaurant was selected for this day.',
            ),
          ),
        );
        break;

      case 'activity':
      case 'nightActivity':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActivityDetailsPage(
              activity: item.toActivity(),
            ),
          ),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details are not available for this item.')),
        );
    }
  }

  Widget _buildErrorPage(BuildContext context, SuggestedPlanProvider provider) {
    final error = provider.error;

    if (error is PremiumRequiredException) {
      return const PremiumUpgradeScreen();
    }

    if (error is SessionExpiredException) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen(showSessionExpired: true)));
      });
      return Scaffold(appBar: _buildAppBar(), body: const Center(child: Text('Your session has expired.')));
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Unable to generate your plan.', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(error?.toString() ?? 'Unknown error.', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => _retry(context), child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoPlanPage(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note_outlined, size: 70, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('No itinerary was generated', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('The server returned no usable itinerary days.', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => _retry(context), child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }

  void _retry(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    Provider.of<SuggestedPlanProvider>(context, listen: false).load(planProvider.toMap(), planProvider.days);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestedPlanProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Scaffold(appBar: _buildAppBar(), body: const Center(child: CircularProgressIndicator()));
        }

        if (provider.error != null) {
          return _buildErrorPage(context, provider);
        }

        final planData = provider.planData;
        if (planData == null) {
          return _buildNoPlanPage(context);
        }

        final items = SuggestedPlanParser.getSelectedItems(planData, provider.selectedDayIndex, provider.days.length);
        final warnings = SuggestedPlanParser.getWarnings(planData);
        final budget = SuggestedPlanParser.getBudget(planData);

        return Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: [
              DaySelector(
                days: provider.days,
                selectedDayIndex: provider.selectedDayIndex,
                onSelect: provider.selectDay,
                onAddDay: () {
                  provider.addLocalDay();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('A new day was added locally. Generate the plan again to populate it.')),
                  );
                },
              ),
              PlanStatusBar(warnings: warnings, budget: budget),
              Expanded(
                child: DayContent(
                  items: items,
                  selectedDayIndex: provider.selectedDayIndex,
                  dayCount: provider.days.length,
                  warnings: warnings,
                  onItemTap: (item) => _openItemDetails(context, item),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New attraction can be added here.')),
              );
            },
            backgroundColor: const Color.fromARGB(255, 9, 214, 255),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}