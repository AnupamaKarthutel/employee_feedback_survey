import 'dart:async';
import '../models/survey.dart';
import '../models/survey_response.dart';
import 'survey_service.dart';

class InMemorySurveyService implements SurveyService {
  final Map<String, Survey> _surveys = {};
  final Map<String, List<SurveyResponse>> _responses = {};
  final Map<String, StreamController<List<SurveyResponse>>> _responseControllers =
      {};

  late final StreamController<List<Survey>> _surveysController =
      StreamController<List<Survey>>.broadcast(
    onListen: _notifySurveys,
  );

  void _notifySurveys() {
    _surveysController.add(
      _surveys.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  StreamController<List<SurveyResponse>> _responsesController(
      String surveyId) {
    return _responseControllers.putIfAbsent(
      surveyId,
      () => StreamController<List<SurveyResponse>>.broadcast(
        onListen: () => _notifyResponses(surveyId),
      ),
    );
  }

  void _notifyResponses(String surveyId) {
    final responses = (_responses[surveyId] ?? [])
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    _responseControllers[surveyId]?.add(responses);
  }

  @override
  Stream<List<Survey>> getSurveys() => _surveysController.stream;

  @override
  Future<Survey?> getSurvey(String id) async => _surveys[id];

  @override
  Future<String> createSurvey(Survey survey) async {
    final id = 'survey_${_surveys.length + 1}';
    final stored = survey.copyWith(id: id, createdAt: DateTime.now());
    _surveys[id] = stored;
    _notifySurveys();
    return id;
  }

  @override
  Future<void> updateSurvey(Survey survey) async {
    _surveys[survey.id] = survey;
    _notifySurveys();
  }

  @override
  Future<void> deleteSurvey(String id) async {
    _surveys.remove(id);
    _responses.remove(id);
    _responseControllers[id]?.close();
    _responseControllers.remove(id);
    _notifySurveys();
  }

  @override
  Future<void> submitResponse(SurveyResponse response) async {
    final id = 'response_${(_responses[response.surveyId] ?? []).length + 1}';
    final stored = response.copyWith(id: id, submittedAt: DateTime.now());
    _responses.putIfAbsent(response.surveyId, () => []).add(stored);
    _notifyResponses(response.surveyId);
  }

  @override
  Stream<List<SurveyResponse>> getResponsesForSurvey(String surveyId) {
    return _responsesController(surveyId).stream;
  }
}
