import 'package:flutter/material.dart';
import '../models/stand_stats.dart';
import '../services/stand_service.dart';

class StandStatsProvider extends ChangeNotifier {
  final StandService _standService;

  StandStatsProvider(this._standService);

  bool _isLoading = true;
  String? _error;
  StandStats? _stats;

  bool get isLoading => _isLoading;
  String? get error => _error;
  StandStats? get stats => _stats;

  Future<void> loadStats() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _standService.getStandStats();

      if (response.status == 'success' && response.data != null) {
        _stats = response.data;
        _error = null;
      } else {
        _error = response.message ?? 'Failed to load statistics';
      }
    } catch (e) {
      _error = 'An error occurred while loading statistics';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    loadStats();
  }
}
