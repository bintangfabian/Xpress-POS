import 'dart:async';
import 'package:xpress/data/repositories/sync_repository.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';

/// Service untuk manage queue sync operations dengan retry mechanism
class SyncQueueService {
  SyncQueueService({
    required SyncRepository syncRepository,
    required OnlineCheckerBloc onlineCheckerBloc,
  })  : _syncRepository = syncRepository,
        _onlineCheckerBloc = onlineCheckerBloc;

  final SyncRepository _syncRepository;
  final OnlineCheckerBloc _onlineCheckerBloc;

  bool _isProcessing = false;
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  /// Process pending sync operations
  Future<void> processPendingSync() async {
    if (_isProcessing) {
      return; // Already processing
    }

    if (!_onlineCheckerBloc.isOnline) {
      // Schedule retry when online
      _scheduleRetryWhenOnline();
      return;
    }

    _isProcessing = true;
    _retryCount = 0;

    try {
      await _syncRepository.uploadPending();
    } catch (e) {
      _handleSyncError(e);
    } finally {
      _isProcessing = false;
    }
  }

  /// Auto-sync when connection is restored
  void _scheduleRetryWhenOnline() {
    _retryTimer?.cancel();

    // Will be triggered by OnlineCheckerBloc listener in UI
    // This method is kept for future use if needed
  }

  /// Handle sync errors with exponential backoff retry
  void _handleSyncError(dynamic error) {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = Duration(
        seconds: _retryDelay.inSeconds * _retryCount,
      );

      _retryTimer?.cancel();
      _retryTimer = Timer(delay, () {
        if (_onlineCheckerBloc.isOnline) {
          processPendingSync();
        }
      });
    } else {
      // Max retries reached, will retry on next manual sync or when online
      _retryCount = 0;
    }
  }

  /// Manual trigger sync
  Future<void> triggerSync() async {
    if (!_onlineCheckerBloc.isOnline) {
      throw SyncException('Tidak dapat sinkronisasi saat offline');
    }
    await processPendingSync();
  }

  /// Cancel any pending retries
  void cancel() {
    _retryTimer?.cancel();
    _isProcessing = false;
  }

  void dispose() {
    cancel();
  }
}
