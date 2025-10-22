import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/etl_job.dart';
import '../services/api_service.dart';
import '../services/mock_responses.dart';

enum EtlStatus { idle, loading, running, completed, failed }

class EtlProvider with ChangeNotifier {
  final ApiService _apiService;
  EtlJob? _currentJob;
  EtlStatus _status = EtlStatus.idle;
  Timer? _pollingTimer;
  String _errorMessage = '';

  EtlProvider(this._apiService);

  EtlJob? get currentJob => _currentJob;
  EtlStatus get status => _status;
  String get errorMessage => _errorMessage;

  void startEtl({
    required String dateFrom,
    required String dateTo,
    required List<String> languages,
  }) async {
    if (_status == EtlStatus.running || _status == EtlStatus.loading) return;

    _status = EtlStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final job = await _apiService.startEtlJob(
        dateFrom: dateFrom,
        dateTo: dateTo,
        languages: languages,
      );
      _currentJob = job;
      _status = EtlStatus.running;
      notifyListeners();
      
      _startPolling(job.jobId);

    } catch (e) {
      _status = EtlStatus.failed;
      _errorMessage = 'Error al iniciar ETL: ${e.toString()}';
      _currentJob = null;
      notifyListeners();
    }
  }

  void _startPolling(String jobId) {
    _pollingTimer?.cancel();
    int tickCount = 0;

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final mockApi = ApiService();
        final EtlJob job;
        if (tickCount >= 2) {
            job = EtlJob.fromJson(jsonDecode(mockEtlStatusResponseCompleted));
        } else {
            job = await mockApi.getEtlStatus(jobId);
        }
        tickCount++;
        
        _currentJob = job;
        notifyListeners();

        if (job.status == 'COMPLETED' || job.status == 'FAILED') {
          timer.cancel();
          _status = job.status == 'COMPLETED' ? EtlStatus.completed : EtlStatus.failed;
          if (_status == EtlStatus.failed) {
            _errorMessage = 'ETL ha fallado inesperadamente.';
          }
          notifyListeners();
        }
      } catch (e) {
        timer.cancel();
        _status = EtlStatus.failed;
        _errorMessage = 'Error en el seguimiento del ETL: ${e.toString()}';
        notifyListeners();
      }
    });
  }

  void reset() {
    _pollingTimer?.cancel();
    _currentJob = null;
    _status = EtlStatus.idle;
    _errorMessage = '';
    notifyListeners();
  }
}
