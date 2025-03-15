library multiple_image_camera;

import 'package:flutter/material.dart';
import 'package:multiple_image_camera/camera_file.dart';

class MultipleImageCamera {
  static Future<List<MediaModel>> capture({
    required BuildContext context,
    Widget? doneButton,
    Widget? bottomLeftButton,
    Widget? customProgressIndicator,
    List<Widget>? centerWidgets,
    ButtonStyle? backButtonStyle,
    Icon? removeImageIcon,
    int? maxPictures,
    double? bottomLeftSize,
    bool? flashIcon,
    Function(int)? onCapture,
  }) async {
    List<MediaModel> images = [];
    try {
      images = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>  CameraFile(
                doneButton: doneButton,
                bottomLeftButton: bottomLeftButton,
                customProgressIndicator: customProgressIndicator,
                centerWidgets: centerWidgets,
                bottomLeftSize: bottomLeftSize,
                backButtonStyle: backButtonStyle,
                removeImageIcon: removeImageIcon,
                maxPictures: maxPictures,
                flashIcon: flashIcon,
                onCapture: onCapture,
              )));
    // ignore: empty_catches
    } catch (e) {

    }
    return images;
  }
}
