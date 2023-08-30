import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

const HOST = 'https://flutter-sandbox.free.beeceptor.com';

class Repository {
  final dio = Dio();

  Future<String> uploadPhoto(
    String comment,
    double latitude,
    double longitude,
    XFile photo,
  ) async {
    final result = await dio.post(
      '$HOST/upload_photo/',
      options: Options(
        headers: {'Content-Type': 'application/javascript'},
      ),
      data: {
        'comment': comment,
        'latitude': latitude,
        'latitude': longitude,
        'photo': await MultipartFile.fromFile(photo.path, filename:photo.name),
      },
    );

    return result.data['status'];
  }
}
