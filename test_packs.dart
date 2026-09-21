import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'intervuex_app/lib/data/models/pack_model.dart';

void main() async {
  final url = Uri.parse('http://127.0.0.1:8000/api/v1/packs');
  print('Fetching $url...');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Data type: ${data.runtimeType}');
      if (data is List) {
        for (var item in data) {
          try {
            final pack = InterviewPackModel.fromJson(item as Map<String, dynamic>);
            print('Parsed pack: ${pack.company} - ${pack.hiringProgram}');
          } catch (e, stack) {
            print('Error parsing item: $e\n$stack');
          }
        }
      } else {
        print('Expected a list, got something else');
      }
    } else {
      print('Status: ${response.statusCode}');
    }
  } catch (e) {
    print('HTTP Error: $e');
  }
}
