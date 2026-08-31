import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../api/client/dio_consumer.dart';
import '../../api/common/end_points.dart';
import '../../api/errors/failure.dart';
import '../../helper/file_helper/file_helper.dart';
import '../../utils/download_params.dart';
import '../../utils/use_cases.dart';
import '../upload/upload_progress_helper.dart';

@lazySingleton
class DownloadFileUseCase implements StreamUseCase<dynamic, DownloadFileParams> {
  final DioConsumer _api;

  DownloadFileUseCase(this._api);

  String _resolveDownloadUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return '${EndPoints.baseFileUrl}$trimmed';
  }

  String _resolveSaveFileName(DownloadFileParams params) {
    final fromParam = params.fileName?.trim();
    if (fromParam != null && fromParam.isNotEmpty) {
      return fromParam;
    }
    return FileHelper.getFileName(_resolveDownloadUrl(params.url));
  }

  @override
  Stream<Either<Failure, dynamic>> call(DownloadFileParams params) async* {
    final url = _resolveDownloadUrl(params.url);
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _resolveSaveFileName(params);
    final savePath = p.join(directory.path, fileName);

    yield* streamUpload<String>(
      apiCall: (onReceiveProgress) => _api.downloadFile(
        url: url,
        savePath: savePath,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }
}
