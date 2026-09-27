import 'package:cloud_functions/cloud_functions.dart';

class AiFanHelperService {
  AiFanHelperService({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseFunctions _functions;

  Future<String> ask(String question) async {
    final callable = _functions.httpsCallable(
      'askFanHelper',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 35)),
    );
    final response = await callable.call<Map<String, dynamic>>({
      'message': question,
    });
    final answer = response.data['answer'];
    if (answer is! String || answer.trim().isEmpty) {
      throw const FormatException('The AI service returned an empty response.');
    }
    return answer.trim();
  }
}
