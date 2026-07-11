import 'package:flutter/widgets.dart';
import 'survey_service.dart';

class ServiceProvider extends InheritedWidget {
  const ServiceProvider({
    super.key,
    required this.service,
    required super.child,
  });

  final SurveyService service;

  static SurveyService of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ServiceProvider>();
    assert(provider != null, 'No ServiceProvider found in context');
    return provider!.service;
  }

  @override
  bool updateShouldNotify(ServiceProvider oldWidget) =>
      service != oldWidget.service;
}
