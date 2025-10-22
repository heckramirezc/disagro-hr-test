import 'package:flutter/material.dart';
import '../models/page_models.dart';
import '../services/api_service.dart';

class PageProvider with ChangeNotifier {
  final ApiService _apiService;

  PaginatedResponse<TopPageItem>? _topRanking;
  PaginatedResponse<TrendingItem>? _trendingRanking;
  bool _isLoadingRankings = false;

  PaginatedResponse<SeriesItem>? _pageSeries;
  bool _isLoadingSeries = false;

  PageProvider(this._apiService);

  PaginatedResponse<TopPageItem>? get topRanking => _topRanking;
  PaginatedResponse<TrendingItem>? get trendingRanking => _trendingRanking;
  PaginatedResponse<SeriesItem>? get pageSeries => _pageSeries;
  bool get isLoadingRankings => _isLoadingRankings;
  bool get isLoadingSeries => _isLoadingSeries;
  
  bool get shouldShowEtlModal => !_isLoadingRankings && (_topRanking == null || _topRanking!.items.isEmpty);

  Future<void> loadRankings({
    String date = '2024-01-01', 
    String lang = 'es',
  }) async {
    _isLoadingRankings = true;
    notifyListeners();
    
    try {
      _topRanking = await _apiService.fetchTopRanking(date: date, lang: lang);
      _trendingRanking = await _apiService.fetchTrendingRanking(date: date, lang: lang);
    } catch (e) {
      _topRanking = null;
      _trendingRanking = null;
      debugPrint('Error obteniendo /page/top/: $e');
    }
    _isLoadingRankings = false;
    notifyListeners();
  }

  Future<void> loadPageSeries({
    required String title,
    String dateFrom = '2023-12-26',
    String dateTo = '2024-01-01',
    String lang = 'es',
  }) async {
    _isLoadingSeries = true;
    _pageSeries = null;
    notifyListeners();

    try {
      _pageSeries = await _apiService.fetchPageSeries(
        title: title,
        dateFrom: dateFrom,
        dateTo: dateTo,
        lang: lang,
      );
    } catch (e) {
      _pageSeries = null;
      debugPrint('Error obteniedno /page/:title: $e');
    }
    _isLoadingSeries = false;
    notifyListeners();
  }
}
