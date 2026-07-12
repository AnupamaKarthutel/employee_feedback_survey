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
  final _answers = <String, dynamic>{};
  bool _isSubmitting = false;
  Future<Survey?>? _surveyFuture;
  Future<bool>? _submittedFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = ServiceProvider.of(context);
    _surveyFuture ??= service.getSurvey(widget.surveyId);
    _submittedFuture ??= service.hasSubmitted(widget.surveyId, widget.user.id);
  }

  Future<void> _submit(Survey survey) async {
    for (final question in survey.questions) {
      if (question.isRequired) {
        final answer = _answers[question.id];
        if (answer == null ||
            (answer is String && answer.isEmpty) ||
            (answer is List && answer.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please answer: ${question.text}'),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);

    final response = SurveyResponse(
      surveyId: survey.id,
      employeeId: widget.user.id,
      employeeName: widget.user.email,
      submittedAt: DateTime.now(),
      answers: Map.from(_answers),
    );

    try {
      await ServiceProvider.of(context).submitResponse(response);
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 52),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Thank you!',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your response has been recorded.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: widget.user.isAdmin
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block_rounded,
                      size: 72, color: Colors.orange.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Admins cannot take surveys',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            )
          : FutureBuilder<bool>(
        future: _submittedFuture,
        builder: (context, submittedSnap) {
          if (submittedSnap.data == true) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 56),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Already Submitted',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You have already taken this survey.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          return FutureBuilder<Survey?>(
        future: _surveyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              submittedSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}',
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Survey not found.'));
          }
          final survey = snapshot.data!;
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Take Survey',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      survey.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (survey.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        survey.description,
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.help_outline,
                            color: Colors.white60, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${survey.questions.length} questions',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...survey.questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final q = entry.value;
                      return _QuestionCard(
                        key: ValueKey(q.id),
                        question: q,
                        index: index + 1,
                        onChanged: (value) => _answers[q.id] = value,
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed:
                            _isSubmitting ? null : () => _submit(survey),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _isSubmitting ? 'Submitting...' : 'Submit Response',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      );
        },
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  const _QuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.onChanged,
  });

  final Question question;
  final int index;
  final ValueChanged<dynamic> onChanged;

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  dynamic _localAnswer;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  void _onChanged(dynamic value) {
    setState(() => _localAnswer = value);
    widget.onChanged(value);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.index}',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.question.text +
                        (widget.question.isRequired ? '  *' : ''),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildInput(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(ColorScheme colorScheme) {
    switch (widget.question.type) {
      case QuestionType.text:
        return TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          maxLines: 3,
          onChanged: (v) {
            _localAnswer = v;
            widget.onChanged(v);
          },
        );

      case QuestionType.rating:
        final value = ((_localAnswer as num?)?.toInt() ?? 0).clamp(0, 5);
        final labels = ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () => _onChanged(star),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      star <= value
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 42,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Text(
              value == 0
                  ? 'Tap a star to rate'
                  : '$value / 5 — ${labels[value]}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        );

      case QuestionType.singleChoice:
        return Column(
          children: widget.question.options.map((option) {
            final selected = (_localAnswer as String?) == option;
            return GestureDetector(
              onTap: () => _onChanged(option),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selected
                        ? colorScheme.primary
                        : Colors.grey.shade300,
                    width: selected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: selected
                      ? colorScheme.primaryContainer.withOpacity(0.25)
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? colorScheme.primary : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(option,
                            style: const TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case QuestionType.multiChoice:
        final selected =
            ((_localAnswer as List<dynamic>?) ?? []).cast<String>().toSet();
        return Column(
          children: widget.question.options.map((option) {
            final isChecked = selected.contains(option);
            return GestureDetector(
              onTap: () {
                final updated = Set<String>.from(selected);
                if (isChecked) {
                  updated.remove(option);
                } else {
                  updated.add(option);
                }
                _onChanged(updated.toList());
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isChecked
                        ? colorScheme.primary
                        : Colors.grey.shade300,
                    width: isChecked ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: isChecked
                      ? colorScheme.primaryContainer.withOpacity(0.25)
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      isChecked
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: isChecked ? colorScheme.primary : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(option,
                            style: const TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            );
          }).toList(),
        );
    }
  }
}
