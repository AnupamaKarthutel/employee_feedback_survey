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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Icon(
                                user.isAdmin
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Hello! 👋',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 13)),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(
                                user.isAdmin ? 'HR Admin' : 'Employee',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: user.isAdmin
                                      ? Colors.orange.shade900
                                      : Colors.blue.shade900,
                                ),
                              ),
                              backgroundColor: user.isAdmin
                                  ? Colors.orange.shade100
                                  : Colors.blue.shade100,
                              padding: EdgeInsets.zero,
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.logout, color: Colors.white),
                              tooltip: 'Sign out',
                              onPressed: () =>
                                  AuthServiceProvider.of(context).signOut(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          user.isAdmin ? 'Manage Surveys' : 'Available Surveys',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<List<Survey>>(
            stream: service.getSurveys(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off,
                              size: 64, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text('Error loading surveys',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final surveys = snapshot.data!;
              if (surveys.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.poll_outlined,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          user.isAdmin
                              ? 'No surveys yet'
                              : 'No surveys available',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.isAdmin
                              ? 'Tap + to create your first survey'
                              : 'Check back later for surveys from HR',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final survey = surveys[index];
                      return _SurveyCard(
                        user: user,
                        survey: survey,
                        onDelete: user.isAdmin
                            ? () => _deleteSurvey(context, service, survey)
                            : null,
                      );
                    },
                    childCount: surveys.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: user.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateSurveyScreen(createdBy: user.email),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('New Survey'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete survey?'),
        content: Text('${survey.title} will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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

  static const _cardColors = [
    Color(0xFF6C63FF),
    Color(0xFF3D8BFF),
    Color(0xFF26C6DA),
    Color(0xFF66BB6A),
    Color(0xFFFF7043),
  ];

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().format(survey.createdAt);
    final color = _cardColors[survey.title.hashCode.abs() % _cardColors.length];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.75)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.poll_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    survey.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${survey.questions.length} Q',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(survey.description,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(survey.createdBy,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(date, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (!user.isAdmin)
                    Expanded(
                      child: FutureBuilder<bool>(
                              future: ServiceProvider.of(context)
                                  .hasSubmitted(survey.id, user.id),
                              builder: (context, snap) {
                                final submitted = snap.data == true;
                                return FilledButton.icon(
                                  onPressed: submitted
                                      ? null
                                      : () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => TakeSurveyScreen(
                                                surveyId: survey.id,
                                                user: user,
                                              ),
                                            ),
                                          ),
                                  icon: Icon(
                                    submitted
                                        ? Icons.check_circle_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 18,
                                  ),
                                  label: Text(submitted
                                      ? 'Already Submitted'
                                      : 'Take Survey'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: submitted
                                        ? Colors.green.shade400
                                        : color,
                                    disabledBackgroundColor:
                                        Colors.green.shade400,
                                    disabledForegroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (user.isAdmin) ...[
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                SurveyResponsesScreen(surveyId: survey.id),
                          ),
                        ),
                        icon: const Icon(Icons.bar_chart_rounded, size: 18),
                        label: const Text('Results'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color),
                          foregroundColor: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        tooltip: 'Delete',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
