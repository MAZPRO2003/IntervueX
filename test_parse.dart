import 'dart:convert';
import 'dart:io';

class HiringProgramModel {
  final String id;
  final String name;
  final String role;
  final String packageLpa;
  final String difficulty;
  final int roundsCount;
  final String overview;
  final List<String> typicalRounds;

  HiringProgramModel({
    required this.id,
    required this.name,
    required this.role,
    required this.packageLpa,
    required this.difficulty,
    required this.roundsCount,
    required this.overview,
    required this.typicalRounds,
  });

  factory HiringProgramModel.fromJson(Map<String, dynamic> json) {
    return HiringProgramModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      packageLpa: json['package_lpa'] ?? '',
      difficulty: json['difficulty'] ?? 'Medium',
      roundsCount: json['rounds_count'] ?? 2,
      overview: json['overview'] ?? '',
      typicalRounds: (json['typical_rounds'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class CompanyModel {
  final String id;
  final String name;
  final String shortName;
  final String category;
  final String colorHex;
  final List<HiringProgramModel> hiringPrograms;

  CompanyModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.colorHex,
    required this.hiringPrograms,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      category: json['category'] ?? '',
      colorHex: json['color_hex'] ?? '#6366F1',
      hiringPrograms: (json['hiring_programs'] as List?)
              ?.map((e) => HiringProgramModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

void main() {
  try {
    final file = File('companies_utf8.json');
    final String content = file.readAsStringSync(encoding: utf8);
    final List<dynamic> list = jsonDecode(content);
    for (var idx = 0; idx < list.length; idx++) {
      try {
         CompanyModel.fromJson(list[idx]);
      } catch (e, st) {
         print('Failed to parse company at index $idx');
         print('Company ID: ${list[idx]['id']}');
         print('Error: $e');
         print('Stacktrace: $st');
      }
    }
    print('Finished parsing ${list.length} companies.');
  } catch(e) {
    print('Failed to parse json: $e');
  }
}
