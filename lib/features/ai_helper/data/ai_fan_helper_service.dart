import 'package:cloud_functions/cloud_functions.dart';

/// Calls Gemini through the server-side Firebase function.
///
/// The Gemini key is deliberately never present in the Flutter application.
/// That keeps it out of GitHub, compiled web bundles, Android APKs and iOS
/// applications. The UI supplies its curated offline help when this call is
/// unavailable.
class AiFanHelperService {
  AiFanHelperService({FirebaseFunctions? functions}) : _functions = functions;

  final FirebaseFunctions? _functions;

  FirebaseFunctions get _client =>
      _functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  Future<String> ask(String question) async {
    final message = question.trim();
    if (message.isEmpty) {
      throw const FormatException(
          'Please enter a question for the AI Fan Helper.');
    }

    try {
      final result = await _client
          .httpsCallable('askFanHelper')
          .call<Map<String, dynamic>>({'message': message});
      final answer = result.data['answer'];
      if (answer is! String || answer.trim().isEmpty) {
        throw const FormatException(
            'The AI service returned an empty response.');
      }
      return answer.trim();
    } on FirebaseFunctionsException catch (error) {
      throw FormatException(error.message ?? 'AI Fan Helper is unavailable.');
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('AI Fan Helper is unavailable.');
    }
  }
}
