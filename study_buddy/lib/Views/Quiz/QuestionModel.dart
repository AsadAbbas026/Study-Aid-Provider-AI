class QuizQuestion {
  final int id;
  final String question;
  final String type;
  final List<String>? options;
  final String answer;

  QuizQuestion({required this.id, required this.question, required this.type, this.options, required this.answer});
}
