import 'package:flutter/material.dart';
import 'dart:async';
import '../models/quiz_model.dart';

class QuizWidget extends StatefulWidget {
  final Quiz quiz;
  final Function(double score, int totalQuestions) onQuizCompleted;
  final bool practiceMode;
  final Map<String, List<String>>? previousAnswers;

  const QuizWidget({
    Key? key,
    required this.quiz,
    required this.onQuizCompleted,
    this.practiceMode = false,
    this.previousAnswers,
  }) : super(key: key);

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  int _currentQuestionIndex = 0;
  Map<String, List<String>> _userAnswers = {};
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isCompleted = false;
  @override
  void initState() {
    super.initState();
    if (widget.previousAnswers != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _userAnswers = Map.from(widget.previousAnswers!);
          });
        }
      });
    }
    if (widget.quiz.timeLimit > 0 && !widget.practiceMode) {
      _remainingSeconds = widget.quiz.timeLimit;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _remainingSeconds--;
            });
          }
        });
      } else {
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submitQuiz() {
    _timer?.cancel();
    int correctAnswers = 0;
    int totalPoints = 0;

    for (var question in widget.quiz.questions) {
      final userAnswerIds = _userAnswers[question.id] ?? [];
      final correctAnswerIds =
          question.answers
              .where((answer) => answer.isCorrect)
              .map((answer) => answer.id)
              .toList();

      if (question.type == QuestionType.multipleChoice) {
        // Pour les questions à choix multiples, toutes les réponses doivent être correctes
        if (userAnswerIds.length == correctAnswerIds.length &&
            userAnswerIds.every((id) => correctAnswerIds.contains(id))) {
          correctAnswers += question.points;
        }
      } else {
        // Pour les autres types de questions, une seule réponse correcte suffit
        if (userAnswerIds.isNotEmpty &&
            correctAnswerIds.contains(userAnswerIds.first)) {
          correctAnswers += question.points;
        }
      }
      totalPoints += question.points;
    }

    final score = (correctAnswers / totalPoints) * 100;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isCompleted = true;
        });
      }
      widget.onQuizCompleted(score, widget.quiz.questions.length);
    });
  }

  void _answerQuestion(String questionId, String answerId, bool isMultiChoice) {
    setState(() {
      if (isMultiChoice) {
        _userAnswers[questionId] = _userAnswers[questionId] ?? [];
        if (_userAnswers[questionId]!.contains(answerId)) {
          _userAnswers[questionId]!.remove(answerId);
        } else {
          _userAnswers[questionId]!.add(answerId);
        }
      } else {
        _userAnswers[questionId] = [answerId];
        if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
          _currentQuestionIndex++;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildQuizSummary();
    }

    final question = widget.quiz.questions[_currentQuestionIndex];
    final isMultiChoice = question.type == QuestionType.multipleChoice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barre de progression
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timer
              if (widget.quiz.timeLimit > 0)
                Text(
                  'Temps restant: ${Duration(seconds: _remainingSeconds).toString().split('.').first}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 16),

              // Question
              Text(
                'Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                question.text,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Réponses
              ...question.answers.map((answer) {
                final isSelected = (_userAnswers[question.id] ?? []).contains(
                  answer.id,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap:
                          () => _answerQuestion(
                            question.id,
                            answer.id,
                            isMultiChoice,
                          ),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            isMultiChoice
                                ? Checkbox(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    _answerQuestion(
                                      question.id,
                                      answer.id,
                                      true,
                                    );
                                  },
                                )
                                : Radio<String>(
                                  value: answer.id,
                                  groupValue:
                                      (_userAnswers[question.id] ?? [])
                                              .isNotEmpty
                                          ? _userAnswers[question.id]!.first
                                          : null,
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      _answerQuestion(
                                        question.id,
                                        value,
                                        false,
                                      );
                                    }
                                  },
                                ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                answer.text,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Boutons de navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentQuestionIndex > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      child: const Text('Précédent'),
                    ),
                  if (_currentQuestionIndex == widget.quiz.questions.length - 1)
                    ElevatedButton(
                      onPressed: _submitQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Terminer le quiz'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      },
                      child: const Text('Suivant'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizSummary() {
    int correctAnswers = 0;
    int totalPoints = 0;

    for (var question in widget.quiz.questions) {
      final userAnswerIds = _userAnswers[question.id] ?? [];
      final correctAnswerIds =
          question.answers
              .where((answer) => answer.isCorrect)
              .map((answer) => answer.id)
              .toList();

      if (userAnswerIds.length == correctAnswerIds.length &&
          userAnswerIds.every((id) => correctAnswerIds.contains(id))) {
        correctAnswers += question.points;
      }
      totalPoints += question.points;
    }

    final score = (correctAnswers / totalPoints) * 100;
    final isPassed = score >= widget.quiz.passingScore;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPassed ? Icons.check_circle : Icons.error,
            size: 64,
            color: isPassed ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            isPassed ? 'Félicitations !' : 'Quiz non validé',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: isPassed ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score: ${score.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Text(
            'Réponses correctes: $correctAnswers/$totalPoints',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentQuestionIndex = 0;
                _userAnswers.clear();
                _isCompleted = false;
                if (widget.quiz.timeLimit > 0) {
                  _remainingSeconds = widget.quiz.timeLimit;
                  _startTimer();
                }
              });
            },
            child: const Text('Recommencer le quiz'),
          ),
        ],
      ),
    );
  }
}
