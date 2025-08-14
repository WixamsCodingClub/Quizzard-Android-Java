class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory Question.fromApi(Map<String, dynamic> json) {
    final correct = json['correctAnswer'] as String;
    final incorrect = List<String>.from(json['incorrectAnswers']);
    final options = [...incorrect, correct]..shuffle();

    return Question(
      text: json['question']['text'],
      options: options,
      correctAnswerIndex: options.indexOf(correct),
    );
  }
}
