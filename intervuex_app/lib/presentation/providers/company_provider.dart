import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/company_model.dart';
import '../../data/services/api_service.dart';

final companiesListProvider = FutureProvider<List<CompanyModel>>((ref) async {
  return await ApiService.instance.getCompanies();
});

final selectedCategoryFilterProvider = StateProvider<String>((ref) => 'All');
