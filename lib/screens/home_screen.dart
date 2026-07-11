import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/survey.dart';
import '../services/service_provider.dart';
import '../services/survey_service.dart';
import 'create_survey_screen.dart';
import 'survey_responses_screen.dart';
import 'take_survey_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ServiceProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Feedback'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Survey>>(
        stream: service.getSurveys(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final surveys = snapshot.data!;
          if (surveys.isEmpty) {
            return const Center(
              child: Text('No surveys yet. Create the first one!'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: surveys.length,
            itemBuilder: (context, index) {
              final survey = surveys[index];
              return _SurveyCard(
                survey: survey,
                onDelete: () => _deleteSurvey(context, service, survey),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateSurveyScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Survey'),
      ),
    );
  }

  Future<void> _deleteSurvey(
    BuildContext context,
    SurveyService service,
    Survey survey,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete survey?'),
        content: Text('${survey.title} will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await service.deleteSurvey(survey.id);
    }
  }
}

class _SurveyCard extends StatelessWidget {
  const _SurveyCard({required this.survey, required this.onDelete});

  final Survey survey;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMd().add_jm().format(survey.createdAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              survey.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(survey.description),
            const SizedBox(height: 8),
            Text(
              'Created by ${survey.createdBy} · $date · ${survey.questions.length} questions',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            OverflowBar(
              spacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TakeSurveyScreen(surveyId: survey.id),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Take'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SurveyResponsesScreen(surveyId: survey.id),
                    ),
                  ),
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Responses'),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
