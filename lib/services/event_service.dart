import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class EventService {
  static const String baseUrl = 'http://localhost:8080/evento';
  
  Future<List<Event>> getPublishedEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/publicados'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Event.fromMap(json)).toList();
      } else {
        print('Erro na resposta: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar eventos: $e');
      return [];
    }
  }
  
  Future<List<Event>> getUpcomingEvents({int limit = 3}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/proximos'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Event.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Erro ao buscar eventos próximos: $e');
      return [];
    }
  }
  
  Future<String?> getEventImage(int eventId, int photoNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foto$photoNumber/$eventId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      print('Erro ao buscar imagem do evento: $e');
      return null;
    }
  }
}