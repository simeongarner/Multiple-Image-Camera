library multiple_image_camera;

import 'package:flutter/material.dart';
import 'package:multiple_image_camera/camera_file.dart';

class MultipleImageCamera {
  static Future<List<MediaModel>> capture({
    required BuildContext context,
    Widget? customDoneButton,
    Widget? rotateCameraIcon,
    Widget? waitingWidget,
    ButtonStyle? backButtonStyle,
    Icon? cancelIcon,
    int? maxPictures,
  }) async {
    List<MediaModel> images = [];
    try {
      images = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>  CameraFile(
                customButton: customDoneButton,
                rotateCameraIcon: rotateCameraIcon,
                waitingWidget: waitingWidget,
                backButtonStyle: backButtonStyle,
                cancelIcon: cancelIcon,
                maxPictures: maxPictures,
              )));
    // ignore: empty_catches
    } catch (e) {

    }
    return images;
  }
}