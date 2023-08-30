import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:photo_app/domain/repository.dart';

enum LoadStatus { start, loading, loaded }

class AppViewModel extends ChangeNotifier {
  final _repository = Repository();

  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  String _comment = '';
  String get comment => _comment;
  set comment(String value) {
    _comment = value;
    notifyListeners();
  }

  String _resultMessage = '';
  String get resultMessage => _resultMessage;

  LoadStatus _loadStatus = LoadStatus.start;
  LoadStatus get loadStatus => _loadStatus;

  Future<CameraController> initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.max,
    );
    await _cameraController!.initialize();
    return _cameraController!;
  }

  Future<void> uploadPhoto() async {
    if (_loadStatus == LoadStatus.loading) return;

    _loadStatus = LoadStatus.loading;
    notifyListeners();

    try {
      final image = await _cameraController?.takePicture();
      if (image == null) return;

      final position = await _getPosition();

      _resultMessage = await _repository.uploadPhoto(
        comment,
        position.latitude,
        position.longitude,
        image,
      );
    } catch (e) {
      _resultMessage = 'Error has occurred';
    }

    _loadStatus = LoadStatus.loaded;
    notifyListeners();
  }

  Future<Position> _getPosition() async {
    await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition();
  }
}
