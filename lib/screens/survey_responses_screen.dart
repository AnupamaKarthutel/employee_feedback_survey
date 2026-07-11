import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/question.dart';
import '../models/survey.dart';
import '../models/survey_response.dart';
import '../services/service_provider.dart';

class SurveyResponsesScreen extends StatelessWidget {
  const SurveyResponsesScreen({super.key, required this.surveyId});

  final String surveyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responses')),
      body: FutureBuilder<Survey?>(
        future: ServiceProvider.of(context).getSurvey(surveyId),
        builder: (context, surveySnapshot) {
          if (surveySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (surveySnapshot.hasError ||
              !surveySnapshot.hasData ||
              surveySnapshot.data == null) {
            return const Center(child: Text('Survey not found.'));
          }

          final survey = surveySnapshot.data!;
          return StreamBuilder<List<SurveyResponse>>(
            stream: ServiceProvider.of(context).getResponsesForSurvey(surveyId),
            builder: (context, responseSnapshot) {
              if (responseSnapshot.hasError) {
                return Center(child: Text('Error: ${responseSnapshot.error}'));
              }
              if (!responseSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final responses = responseSnapshot.data!;
              if (responses.isEmpty) {
                return const Center(
                  child: Text('No responses yet.'),
                );
              }
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _SummaryCard(survey: survey, responses: responses),
                  const SizedBox(height: 16),
                  ...responses.map((r) => _ResponseTile(response: r)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.survey, required this.responses});

  final Survey survey;
  final List<SurveyResponse> responses;

  @override
  Widget build(BuildContext context) {
    final summaryWidgets = <Widget>[
      Text(
        'Total responses: ${responses.length}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 12),
    ];

    for (final question in survey.questions) {
      summaryWidgets.add(
        Text(
          question.text,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      );

      if (question.type == QuestionType.rating) {
        final values = responses
            .map((r) => r.answers[question.id])
            .whereType<int>()
            .toList();
        final avg = values.isEmpty
            ? 0.0
            : values.reduce((a, b) => a + b) / values.length;
        summaryWidgets.add(
          Text('Average rating: ${avg.toStringAsFixed(1)} / 5'),
        );
      } else if (question.type == QuestionType.singleChoice ||
          question.type == QuestionType.multiChoice) {
        final counts = <String, int>{};
        for (final r in responses) {
          final answer = r.answers[question.id];
          if (answer is String) {
            counts[answer] = (counts[answer] ?? 0) + 1;
          } else if (answer is List) {
            for (final item in answer) {
              final s = item.toString();
              counts[s] = (counts[s] ?? 0) + 1;
            }
          }
        }
        if (counts.isEmpty) {
          summaryWidgets.add(const Text('No answers'));
        } else {
          summaryWidgets.add(
            Wrap(
              spacing: 8,
              children: counts.entries
                  .map((e) => Chip(label: Text('${e.key}: ${e.value}')))
                  .toList(),
            ),
          );
        }
      }
      summaryWidgets.add(const SizedBox(height: 12));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: summaryWidgets,
        ),
      ),
    );
  }
}

class _ResponseTile extends StatelessWidget {
  const _ResponseTile({required this.response});

  final SurveyResponse response;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMd().add_jm().format(response.submittedAt);
    final answers = response.answers.entries
        .map((e) => '• ${e.key}: ${e.value}')
        .join('\n');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              response.employeeName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'ID: ${response.employeeId} · $date',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              answers.isEmpty ? 'No answers' : answers,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
