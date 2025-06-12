import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class LearningPlanRepository {
  final SupabaseClient _client;

  static const String _bucketName = 'students';
  static const String _filePath = 'learning_plan/plan.pdf';

  LearningPlanRepository(this._client);

  /// Returns a public URL of the learning-plan PDF if it exists.
  /// Returns null if the file is not found.
  Future<String?> getPlanUrl() async {
    try {
      // List the directory to ensure the file exists – avoid 404 PDF viewer.
      final listRes = await _client.storage.from(_bucketName).list(path: 'learning_plan');
      final exists = listRes.any((f) => f.name == 'plan.pdf');
      if (!exists) return null;

      // Generate a signed url every call so a new token busts any cache.
      return _client.storage.from(_bucketName).createSignedUrl(_filePath, 60 * 60);
    } catch (e) {
      return null;
    }
  }

  /// Uploads (or replaces) the learning-plan PDF.
  Future<void> uploadPlan(File pdf) async {
    // Delete the previous version if it exists to ensure clean replace.
    try {
      await _client.storage.from(_bucketName).remove([_filePath]);
    } catch (_) {
      // Ignore if file wasn't there.
    }

    final bytes = await pdf.readAsBytes();
    await _client.storage.from(_bucketName).uploadBinary(
      _filePath,
      bytes,
      fileOptions: const FileOptions(
        upsert: true,
        contentType: 'application/pdf',
      ),
    );
  }

  /// Deletes the current learning plan PDF if it exists.
  Future<void> deletePlan() async {
    try {
      await _client.storage.from(_bucketName).remove([_filePath]);
    } catch (_) {
      // ignore if not found
    }
  }
}
