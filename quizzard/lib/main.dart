import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const QuizScreen(),
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  // Factory method to create Question from API JSON
  factory Question.fromApi(Map<String, dynamic> json) {
    final correct = json['correct_answer'] as String;
    final incorrect = List<String>.from(json['incorrect_answers']);
    final options = [...incorrect, correct]..shuffle();

    return Question(
      text: json['question'],
      options: options,
      correctAnswerIndex: options.indexOf(correct),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  List<Question> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Example API: Open Trivia DB (10 multiple choice questions)
      final url = Uri.parse("https://opentdb.com/api.php?amount=5&type=multiple");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        final fetchedQuestions = results
            .map((json) => Question.fromApi(json))
            .toList();

        setState(() {
          _questions = fetchedQuestions;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load questions");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading questions: $e")),
      );
    }
  }

  void _answerQuestion(int selectedIndex) {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        if (selectedIndex == _questions[_currentQuestionIndex].correctAnswerIndex) {
          _score++;
        }
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        if (selectedIndex == _questions[_currentQuestionIndex].correctAnswerIndex) {
          _score++;
        }
        _quizCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
    });
    _fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _quizCompleted
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Quiz Completed!",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Your Score: $_score/${_questions.length}",
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _restartQuiz,
                          child: const Text("Restart Quiz"),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Question ${_currentQuestionIndex + 1}/${_questions.length}",
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _questions[_currentQuestionIndex].text,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _questions[_currentQuestionIndex].options.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ElevatedButton(
                                onPressed: () => _answerQuestion(index),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  _questions[_currentQuestionIndex].options[index],
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          "Score: $_score",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
