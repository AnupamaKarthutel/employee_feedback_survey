import '../models/survey.dart';
import '../models/survey_response.dart';

abstract class SurveyService {
  Stream<List<Survey>> getSurveys();

  Future<Survey?> getSurvey(String id);

  Future<String> createSurvey(Survey survey);

  Future<void> updateSurvey(Survey survey);

  Future<void> deleteSurvey(String id);

  Future<void> submitResponse(SurveyResponse response);

  Stream<List<SurveyResponse>> getResponsesForSurvey(String surveyId);

  Future<bool> hasSubmitted(String surveyId, String employeeId);
}
