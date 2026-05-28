// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import 'package:health_xiaohe/data/models/health_record_model.dart';

abstract class HealthRepository {
  Future<HealthResult<List<HealthRecordModel>>> getRecords({
    HealthRecordType? type,
    int limit = 20,
    int offset = 0,
  });

  Future<HealthResult<LatestRecordsModel>> getLatestRecords();

  Future<HealthResult<HealthRecordModel>> createRecord({
    required HealthRecordType type,
    required Map<String, dynamic> value,
    DateTime? recordedAt,
    String? note,
  });

  Future<HealthResult<void>> deleteRecord(String recordId);
}

class HealthResult<T> {
  final bool success;
  final T? data;
  final String? error;

  HealthResult.success(this.data)
      : success = true,
        error = null;

  HealthResult.failure(this.error)
      : success = false,
        data = null;
}
