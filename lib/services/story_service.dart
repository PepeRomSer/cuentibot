import 'package:cuentibot/models/profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:core';

class StoryService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://api.openai.com/v1",
    headers: {
      "Authorization": "Bearer ${dotenv.env['OPENAI_API_KEY']}", // API Key desde .env
      "Content-Type": "application/json",
    },
  ));

  String _extractTitle(String storyText) {
    final RegExp regex = RegExp(r'Título:\s*\"([^\"]+)\"'); // Busca el título entre comillas
    final match = regex.firstMatch(storyText);

    if (match != null) {
      return match.group(1) ?? "Título Desconocido"; // Extrae el texto dentro de las comillas
    }

    // Si no se encuentra el formato esperado, tomamos la primera línea del cuento
    List<String> lines = storyText.split('\n');
    return lines.firstWhere(
      (line) => line.trim().isNotEmpty,
      orElse: () => "Cuento sin título",
    );
  }

  Future<Map<String, String>> generateStory({
    required String storyType,
    required List<Profile> profiles,
    String category = '',
    String description = '',
    String popularStory = '',
  }) async {
    String prompt = _buildPrompt(
      storyType: storyType,
      profiles: profiles,
      category: category,
      description: description,
      popularStory: popularStory,
    );

    final response = await _dio.post("/chat/completions", data: {
      "model": "gpt-4",
      "messages": [
        {"role": "system", "content": "Eres un narrador experto en cuentos para niños. Crea historias con un inicio, desarrollo y final bien definidos."},
        {"role": "user", "content": prompt},
      ],
      "max_tokens": 1000,
      "temperature": 0.8,
      "top_p": 0.9,
    });

    String fullStory = response.data["choices"][0]["message"]["content"].trim();
    String title = _extractTitle(fullStory);

    return {
      "titulo": title,
      "texto": fullStory,
    };
  }

  String _buildPrompt({
    required String storyType,
    required List<Profile> profiles,
    String category = '',
    String description = '',
    String popularStory = '',
  }) {
    String characterDetails = profiles.map((p) => "${p.name}, ${p.gender}, ${p.age} años").join('; ');

    switch (storyType) {
      case "Automático":
        return "Escribe un cuento infantil con los siguientes personajes, teniendo en cuenta su nombre, género y edad: $characterDetails. La historia debe tener un inicio, desarrollo y un final bien estructurado.";
      case "Por Categoría":
        return "Escribe un cuento de la categoría '$category' con los personajes: $characterDetails. Asegúrate de que el cuento tiene un desarrollo lógico y un desenlace satisfactorio.";
      case "Descriptivo":
        return "Escribe un cuento basado en la siguiente descripción: '$description'. Los personajes son: $characterDetails. Asegúrate de que la historia sigue la descripción dada y tiene una conclusión adecuada.";
      case "Popular":
        return "Reescribe el cuento clásico '$popularStory' incorporando los personajes: $characterDetails. Asegúrate de que los nuevos personajes se integran de forma natural en la historia y que el cuento tiene un final completo.";
      default:
        return "Escribe un cuento con los personajes: $characterDetails. Asegúrate de que la historia tenga un inicio, un desarrollo y un final bien definidos.";
    }
  }
}
