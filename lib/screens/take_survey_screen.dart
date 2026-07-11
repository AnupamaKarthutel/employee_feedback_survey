import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/question.dart';
import '../models/survey.dart';
import '../models/survey_response.dart';
import '../services/service_provider.dart';

class TakeSurveyScreen extends StatefulWidget {
  const TakeSurveyScreen({
    super.key,
    required this.surveyId,
    required this.user,
  });

  final String surveyId;
  final AppUser user;

  @override
  State<TakeSurveyScreen> createState() => _TakeSurveyScreenState();
}

class _TakeSurveyScreenState extends State<TakeSurveyScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _answers = <String, dynamic>{};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.email;
    _idController.text = widget.user.id;
  }

  Future<void> _submit(Survey survey) async {
    if (_nameController.text.trim().isEmpty ||
        _idController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your name and employee ID.')),
      );
      return;
    }

    for (final question in survey.questions) {
      if (question.isRequired) {
        final answer = _answers[question.id];
        if (answer == null ||
            (answer is String && answer.isEmpty) ||
            (answer is List && answer.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please answer: ${question.text}')),
          );
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);

    final response = SurveyResponse(
      surveyId: survey.id,
      employeeId: _idController.text.trim(),
      employeeName: _nameController.text.trim(),
      submittedAt: DateTime.now(),
      answers: Map.from(_answers),
    );

    await ServiceProvider.of(context).submitResponse(response);

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Thank you!'),
          content: const Text('Your response has been recorded.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take Survey')),
      body: FutureBuilder<Survey?>(
        future: ServiceProvider.of(context).getSurvey(widget.surveyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Survey not found.'));
          }
          final survey = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  survey.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(survey.description),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Employee Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Questions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...survey.questions.map((q) => _QuestionCard(
                      question: q,
                      answer: _answers[q.id],
                      onChanged: (value) => setState(() => _answers[q.id] = value),
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : () => _submit(survey),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: const Text('Submit Response'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final Question question;
  final dynamic answer;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.text + (question.isRequired ? ' *' : ''),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    switch (question.type) {
      case QuestionType.text:
        return TextFormField(
          initialValue: answer?.toString() ?? '',
          decoration: const InputDecoration(
            hintText: 'Your answer',
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
        );
      case QuestionType.rating:
        final value = ((answer as num?)?.toDouble() ?? 0.0)
            .clamp(0.0, 5.0)
            .toDouble();
        return Column(
          children: [
            Slider(
              value: value,
              min: 0,
              max: 5,
              divisions: 5,
              label: value.toInt().toString(),
              onChanged: (v) => onChanged(v.toInt()),
            ),
            Text('${value.toInt()} / 5'),
          ],
        );
      case QuestionType.singleChoice:
        return Column(
          children: question.options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: answer as String?,
              onChanged: (value) => onChanged(value),
            );
          }).toList(),
        );
      case QuestionType.multiChoice:
        final selected = (answer as List<dynamic>? ?? []).cast<String>().toSet();
        return Column(
          children: question.options.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: selected.contains(option),
              onChanged: (value) {
                final updated = Set<String>.from(selected);
                if (value == true) {
                  updated.add(option);
                } else {
                  updated.remove(option);
                }
                onChanged(updated.toList());
              },
            );
          }).toList(),
        );
    }
  }
}
