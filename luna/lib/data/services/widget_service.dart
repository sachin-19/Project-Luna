import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../../core/constants/enums.dart';

class WidgetService {
  const WidgetService._();

  static Future<void> update({
    required CyclePhase phase,
    required int cycleDay,
    required int daysUntilPeriod,
    required bool hasCycle,
    required DateTime? cycleStartDate,
    required int cycleLength,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData('luna_phase', phase.name),
        HomeWidget.saveWidgetData('luna_phase_name', phase.displayName),
        HomeWidget.saveWidgetData('luna_cycle_day', cycleDay),
        HomeWidget.saveWidgetData('luna_days_until_period', daysUntilPeriod),
        HomeWidget.saveWidgetData('luna_has_cycle', hasCycle),
        HomeWidget.saveWidgetData<String>(
          'luna_cycle_start_ms',
          cycleStartDate?.millisecondsSinceEpoch.toString(),
        ),
        HomeWidget.saveWidgetData('luna_cycle_length', cycleLength),
      ]);
      await HomeWidget.updateWidget(androidName: 'LunaWidgetReceiver');
    } catch (e) {
      if (kDebugMode) debugPrint('WidgetService.update: $e');
    }
  }
}
