import 'package:flutter/material.dart';
import '../models/stand/stand_stats.dart';
import '../services/stand_admin/stand_service.dart';

class StandStatsProvider extends ChangeNotifier {
  final StandService _standService;

  StandStatsProvider(this._standService);

  bool _isLoading = true;
  String? _error;
  StandStats? _stats;

  bool get isLoading => _isLoading;
  String? get error => _error;
  StandStats? get stats => _stats;

  Future<void> loadStats({bool forceRefresh = false}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _standService.getStats(forceRefresh: forceRefresh);

      if (response.status == 'success' && response.data != null) {
        _stats = response.data;
        _error = null;
      } else {
        // ignore: dead_null_aware_expression
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
    loadStats(forceRefresh: true);
  }
}
