import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/etl_job.dart';
import '../models/page_models.dart';

import 'mock_responses.dart';

class ApiService {
  // GET /page/top
  Future<PaginatedResponse<TopPageItem>> fetchTopRanking({
    required String date,
    required String lang,
  }) async {
    // final url = Uri.parse('$API_BASE_URL/page/top?date=$date&lang=$lang&limit=10&offset=0');
    // final response = await _client.get(url);
    
    final response = http.Response(mockTopResponse, 200);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PaginatedResponse<TopPageItem>(
        items: (json['items'] as List).map((i) => TopPageItem.fromJson(i)).toList(),
        total: json['total'], page: json['page'], pageSize: json['pageSize']
      );
    }
    throw Exception('Ocurrió un error obteniendo /page/top/');
  }

  // GET /page/trending
  Future<PaginatedResponse<TrendingItem>> fetchTrendingRanking({
    required String date,
    required String lang,
  }) async {
    // final url = Uri.parse('$API_BASE_URL/page/trending?date=$date&lang=$lang&limit=10&offset=0');
    // final response = await _client.get(url);
    
    final response = http.Response(mockTrendingResponse, 200);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PaginatedResponse<TrendingItem>(
        items: (json['items'] as List).map((i) => TrendingItem.fromJson(i)).toList(),
        total: json['total'], page: json['page'], pageSize: json['pageSize']
      );
    }
    throw Exception('Ocurrió un error obteniendo /page/trending.');
  }

  // GET /page/:title
  Future<PaginatedResponse<SeriesItem>> fetchPageSeries({
    required String title,
    required String dateFrom,
    required String dateTo,
    required String lang,
  }) async {
    // final url = Uri.parse('$API_BASE_URL/page/$title?date_from=$dateFrom&date_to=$dateTo&lang=$lang');
    // final response = await _client.get(url);

    final response = http.Response(mockSeriesResponse, 200);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PaginatedResponse<SeriesItem>(
        items: (json['items'] as List).map((i) => SeriesItem.fromJson(i)).toList(),
        total: json['total'], page: json['page'], pageSize: json['pageSize']
      );
    }
    throw Exception('Ocurrió un error obteniendo /page/:title');
  }

  // POST /etl/start
  Future<EtlJob> startEtlJob({
    required String dateFrom,
    required String dateTo,
    required List<String> languages,
  }) async {
    // final url = Uri.parse('$API_BASE_URL/etl/start');
    // final response = await _client.post(url,
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode({
    //       'date_from': dateFrom,
    //       'date_to': dateTo,
    //       'languages': languages,
    //     }));
    
    await Future.delayed(const Duration(milliseconds: 500));
    final response = http.Response(mockEtlStartResponse, 201);

    if (response.statusCode == 201) {
      return EtlJob.fromJson(jsonDecode(response.body));
    }
    throw Exception('Ocurrió un error iniciando el trabajo ETL');
  }

  // GET /etl/status/:jobId
  Future<EtlJob> getEtlStatus(String jobId) async {
    // final url = Uri.parse('$API_BASE_URL/etl/status/$jobId');
    // final response = await _client.get(url);
    
    await Future.delayed(const Duration(milliseconds: 500));
    final response = http.Response(mockEtlStatusResponseRunning, 200); 

    if (response.statusCode == 200) {
      return EtlJob.fromJson(jsonDecode(response.body));
    }
    throw Exception('Ocurrió un error obteniendo el estado del ETL');
  }
}
