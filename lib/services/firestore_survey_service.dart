import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/survey.dart';
import '../models/survey_response.dart';
import 'survey_service.dart';

class FirestoreSurveyService implements SurveyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _surveys =>
      _firestore.collection('surveys');

  @override
  Stream<List<Survey>> getSurveys() {
    return _surveys
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Survey.fromDocument(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<Survey?> getSurvey(String id) async {
    final doc = await _surveys.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Survey.fromDocument(doc.id, doc.data()!);
  }

  @override
  Future<String> createSurvey(Survey survey) async {
    final doc = await _surveys.add(survey.toMap());
    return doc.id;
  }

  @override
  Future<void> updateSurvey(Survey survey) async {
    await _surveys.doc(survey.id).update(survey.toMap());
  }

  @override
  Future<void> deleteSurvey(String id) async {
    await _surveys.doc(id).delete();
  }

  @override
  Future<void> submitResponse(SurveyResponse response) async {
    await _surveys
        .doc(response.surveyId)
        .collection('responses')
        .add(response.toMap());
  }

  @override
  Stream<List<SurveyResponse>> getResponsesForSurvey(String surveyId) {
    return _surveys
        .doc(surveyId)
        .collection('responses')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SurveyResponse.fromDocument(doc.id, doc.data()))
          .toList();
    });
  }
}
