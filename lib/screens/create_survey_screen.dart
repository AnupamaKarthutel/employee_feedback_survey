import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/survey.dart';
import '../services/service_provider.dart';

class CreateSurveyScreen extends StatefulWidget {
  const CreateSurveyScreen({super.key, this.createdBy});

  final String? createdBy;

  @override
  State<CreateSurveyScreen> createState() => _CreateSurveyScreenState();
}

class _CreateSurveyScreenState extends State<CreateSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final TextEditingController _createdByController;
  final List<Question> _questions = [];
  int _nextQuestionId = 1;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _createdByController = TextEditingController(text: widget.createdBy ?? '');
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        Question(
          id: 'q_${_nextQuestionId++}',
          text: '',
          type: QuestionType.text,
        ),
      );
    });
  }

  void _updateQuestion(int index, Question updated) {
    setState(() {
      _questions[index] = updated;
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _saveSurvey() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final survey = Survey(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdBy: _createdByController.text.trim(),
      createdAt: DateTime.now(),
      questions: _questions,
    );

    final service = ServiceProvider.of(context);
    await service.createSurvey(survey);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Survey saved')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _createdByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Survey')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _createdByController,
              decoration: const InputDecoration(labelText: 'Created by'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Questions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._questions.asMap().entries.map((entry) {
              return _QuestionEditor(
                index: entry.key,
                question: entry.value,
                onChanged: (q) => _updateQuestion(entry.key, q),
                onDelete: () => _removeQuestion(entry.key),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSurvey,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save Survey'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionEditor extends StatefulWidget {
  const _QuestionEditor({
    required this.index,
    required this.question,
    required this.onChanged,
    required this.onDelete,
  });

  final int index;
  final Question question;
  final ValueChanged<Question> onChanged;
  final VoidCallback onDelete;

  @override
  State<_QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<_QuestionEditor> {
  late TextEditingController _textController;
  late TextEditingController _optionsController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question.text);
    _optionsController = TextEditingController(
      text: widget.question.options.join(', '),
    );
  }

  @override
  void didUpdateWidget(covariant _QuestionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.question.id != oldWidget.question.id) {
      _textController.text = widget.question.text;
      _optionsController.text = widget.question.options.join(', ');
    }
  }

  void _update({
    String? text,
    QuestionType? type,
    List<String>? options,
    bool? isRequired,
  }) {
    widget.onChanged(
      widget.question.copyWith(
        text: text,
        type: type,
        options: options,
        isRequired: isRequired,
      ),
    );
  }

  bool get _hasOptions =>
      widget.question.type == QuestionType.singleChoice ||
      widget.question.type == QuestionType.multiChoice;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question ${widget.index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Question text'),
              onChanged: (value) => _update(text: value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<QuestionType>(
              value: widget.question.type,
              decoration: const InputDecoration(labelText: 'Question type'),
              items: QuestionType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  if (value == QuestionType.rating) {
                    _optionsController.text = '';
                  }
                  _update(
                    type: value,
                    options: value == QuestionType.rating ? [] : null,
                  );
                }
              },
            ),
            if (_hasOptions) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _optionsController,
                decoration: const InputDecoration(
                  labelText: 'Options (comma-separated)',
                  hintText: 'Option 1, Option 2, Option 3',
                ),
                onChanged: (value) {
                  final options = value
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();
                  _update(options: options);
                },
              ),
            ],
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Required'),
              value: widget.question.isRequired,
              onChanged: (value) => _update(isRequired: value ?? true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _optionsController.dispose();
    super.dispose();
  }
}
