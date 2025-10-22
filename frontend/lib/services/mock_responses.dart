const String mockTopResponse = '''
{
  "items": [
    {"title": "DISAGRO_ETL", "lang": "en", "viewsTotal": 984021},
    {"title": "Lionel_Messi", "lang": "es", "viewsTotal": 765432},
    {"title": "Guatemala", "lang": "es", "viewsTotal": 612345}
  ],
  "page": 1, "pageSize": 3, "total": 50
}
''';

const String mockTrendingResponse = '''
{
  "items": [
    {"title": "Mundial_2026", "lang": "en", "viewsTotal": 550000, "trendScore": 4.5},
    {"title": "Nueva_Ley", "lang": "es", "viewsTotal": 320000, "trendScore": 3.8}
  ],
  "page": 1, "pageSize": 2, "total": 10
}
''';

const String mockSeriesResponse = '''
{
  "items": [
    {"day": "2024-10-13", "viewsTotal": 10000, "avg7Day": 11000, "trendScore": -0.2},
    {"day": "2024-10-14", "viewsTotal": 12000, "avg7Day": 11500, "trendScore": 0.5},
    {"day": "2024-10-15", "viewsTotal": 15000, "avg7Day": 12000, "trendScore": 1.2}
  ],
  "page": 1, "pageSize": 3, "total": 3
}
''';

const String mockEtlStartResponse = '''
{"jobId": "a1b2c3d4-e5f6-7890-1234-567890abcdef", "status": "PENDING", "startTime": "2024-10-20T15:00:00Z"}
''';

const String mockEtlStatusResponseRunning = '''
{"jobId": "a1b2c3d4-e5f6-7890-1234-567890abcdef", "status": "RUNNING", "startTime": "2024-10-20T15:00:00Z"}
''';

const String mockEtlStatusResponseCompleted = '''
{"jobId": "a1b2c3d4-e5f6-7890-1234-567890abcdef", "status": "COMPLETED", "startTime": "2024-10-20T15:00:00Z", "endTime": "2024-10-20T15:01:30Z"}
''';
