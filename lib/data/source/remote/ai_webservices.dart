import 'dart:developer';

import 'package:touchhealth/core/utils/constant/api_url.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GenerativeAiWebService {
  static final _model = GenerativeModel(
    model: EnvManager.generativeModelVersion,
    apiKey: EnvManager.generativeModelApiKey,
  );

  static Future<String?> postData({required List<Content> content}) async {
    try {
      final response = await _model.generateContent(content);
      log("Data posted successfully!");

      final cleanResponse = response.text!.trim();
      log('response: $cleanResponse');
      return cleanResponse;
    } on Exception catch (err) {
      log(err.toString());
      return null;
    }
  }

  static Future<void> streamData({required String text}) async {
    try {
      final content = [Content.text(text)];
      final response = _model.generateContentStream(content);
      await for (final chunk in response) {
        if (chunk.text != null) {
          log(chunk.text!);
        }
      }
    } catch (e) {
      log('Streaming error: $e');
    }
  }

  static Future<String?> getHealthAdvice({required String userMessage, String? medicalContext}) async {
    try {
      List<Content> healthContent = [
        Content.text("You are TouchHealth AI, a knowledgeable health assistant."),
        Content.text("Provide helpful, accurate health information while being empathetic."),
        Content.text("Always remind users to consult healthcare professionals for serious concerns."),
        if (medicalContext != null) Content.text("User's medical context: $medicalContext"),
        Content.text("User question: $userMessage"),
      ];

      final response = await _model.generateContent(healthContent);
      return response.text?.trim();
    } catch (e) {
      log('Health advice error: $e');
      return "I'm sorry, I couldn't provide health advice at the moment. Please consult with a healthcare professional.";
    }
  }
  
}
