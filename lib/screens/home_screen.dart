import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_user.dart';
import '../models/survey.dart';
import '../services/auth_service_provider.dart';
import '../services/service_provider.dart';
import '../services/survey_service.dart';
import 'create_survey_screen.dart';
import 'survey_responses_screen.dart';
import 'take_survey_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final service = ServiceProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Feedback'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => AuthServiceProvider.of(context).signOut(),
          ),
        ],
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
            return Center(
              child: Text(
                user.isAdmin
                    ? 'No surveys yet. Create the first one!'
                    : 'No surveys available yet.',
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: surveys.length,
            itemBuilder: (context, index) {
              final survey = surveys[index];
              return _SurveyCard(
                user: user,
                survey: survey,
                onDelete: user.isAdmin
                    ? () => _deleteSurvey(context, service, survey)
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: user.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateSurveyScreen(createdBy: user.email),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Survey'),
            )
          : null,
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
  const _SurveyCard({
    required this.user,
    required this.survey,
    required this.onDelete,
  });

  final AppUser user;
  final Survey survey;
  final VoidCallback? onDelete;

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
                      builder: (_) => TakeSurveyScreen(
                        surveyId: survey.id,
                        user: user,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Take'),
                ),
                if (user.isAdmin) ...[
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
