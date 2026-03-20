import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../data/github_release_service.dart';
import '../models/release_info.dart';

enum UpdateStatus { idle, checking, hasUpdate, upToDate, error }

class UpdateState {
  final UpdateStatus status;
  final ReleaseInfo? latestRelease;
  final String currentVersion;
  final String? errorMessage;

  const UpdateState({
    this.status = UpdateStatus.idle,
    this.latestRelease,
    this.currentVersion = '',
    this.errorMessage,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    ReleaseInfo? latestRelease,
    String? currentVersion,
    String? errorMessage,
  }) {
    return UpdateState(
      status: status ?? this.status,
      latestRelease: latestRelease ?? this.latestRelease,
      currentVersion: currentVersion ?? this.currentVersion,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UpdateNotifier extends Notifier<UpdateState> {
  final _service = GithubReleaseService();

  @override
  UpdateState build() {
    _loadCurrentVersion();
    return const UpdateState(status: UpdateStatus.idle);
  }

  Future<void> _loadCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    state = state.copyWith(currentVersion: info.version);
  }

  Future<void> checkForUpdate() async {
    state = state.copyWith(status: UpdateStatus.checking);
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;
      final latest = await _service.fetchLatestRelease()
          .timeout(const Duration(seconds: 15));
      final hasUpdate = _isNewer(latest.version, current);

      state = state.copyWith(
        status: hasUpdate ? UpdateStatus.hasUpdate : UpdateStatus.upToDate,
        latestRelease: latest,
        currentVersion: current,
      );
    } on TimeoutException {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: '检查超时',
      );
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  bool _isNewer(String latest, String current) {
    final l = latest.split('.').map(int.tryParse).toList();
    final c = current.split('.').map(int.tryParse).toList();
    for (var i = 0; i < 3; i++) {
      final lv = (i < l.length ? l[i] : 0) ?? 0;
      final cv = (i < c.length ? c[i] : 0) ?? 0;
      if (lv > cv) return true;
      if (lv < cv) return false;
    }
    return false;
  }
}

final updateProvider = NotifierProvider<UpdateNotifier, UpdateState>(
  UpdateNotifier.new,
);
