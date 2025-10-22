class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  PaginatedResponse({required this.items, required this.total, required this.page, required this.pageSize});
}

class TopPageItem {
  final String title;
  final String lang;
  final int viewsTotal;

  TopPageItem({required this.title, required this.lang, required this.viewsTotal});

  factory TopPageItem.fromJson(Map<String, dynamic> json) => TopPageItem(
        title: json['title'] as String,
        lang: json['lang'] as String,
        viewsTotal: json['viewsTotal'] as int,
      );
}

class TrendingItem {
  final String title;
  final String lang;
  final int viewsTotal;
  final double trendScore;

  TrendingItem({required this.title, required this.lang, required this.viewsTotal, required this.trendScore});

  factory TrendingItem.fromJson(Map<String, dynamic> json) => TrendingItem(
        title: json['title'] as String,
        lang: json['lang'] as String,
        viewsTotal: json['viewsTotal'] as int,
        trendScore: (json['trendScore'] as num).toDouble(),
      );
}

class SeriesItem {
  final String day;
  final int viewsTotal;
  final double avg7Day;
  final double trendScore;

  SeriesItem({required this.day, required this.viewsTotal, required this.avg7Day, required this.trendScore});

  factory SeriesItem.fromJson(Map<String, dynamic> json) => SeriesItem(
        day: json['day'] as String,
        viewsTotal: json['viewsTotal'] as int,
        avg7Day: (json['avg7Day'] as num).toDouble(),
        trendScore: (json['trendScore'] as num).toDouble(),
      );
}
