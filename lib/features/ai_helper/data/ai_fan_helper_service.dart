import 'package:google_generative_ai/google_generative_ai.dart';

class AiFanHelperService {
  AiFanHelperService();

  // =====================================================================
  // IMPORTANT: Apni Gemini API key yahan paste karein.
  // Key lene ka tariqa: https://aistudio.google.com/apikey
  // =====================================================================
  static const _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  Future<String> ask(String question) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.trim().isEmpty) {
      throw const FormatException(
        'Gemini API Key missing!\n\n'
        'lib/features/ai_helper/data/ai_fan_helper_service.dart mein '
        '_apiKey ki jagah apni Google AI Studio key paste karein.\n'
        'Key lene k liye: https://aistudio.google.com/apikey',
      );
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-3.8-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(
          'You are AI Fan Helper inside Fandom Verse Pocket Edition. '
          'Answer the user helpfully and naturally in the language they use. '
          'Keep answers concise and friendly.',
        ),
      );

      final response = await model.generateContent([
        Content.text(question.trim()),
      ]);

      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw const FormatException('The AI service returned an empty response.');
      }
      return text.trim();
    } on GenerativeAIException catch (e) {
      throw FormatException('AI Error: ${e.message}');
    } catch (e) {
      throw FormatException('Failed to connect to AI: $e');
    }
  }
}
