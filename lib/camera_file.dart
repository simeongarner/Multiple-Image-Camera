import 'dart:async';
import 'dart:io';
import "package:flutter/material.dart";
import "package:camera/camera.dart";
import 'package:flutter/services.dart';
import 'package:multiple_image_camera/image_preview.dart';

class CameraFile extends StatefulWidget {
  final Widget? doneButton;
  final Widget? bottomLeftButton;
  final Widget? customProgressIndicator;
  final List<Widget>? centerWidgets;
  final ButtonStyle? backButtonStyle;
  final Icon? removeImageIcon;
  final int? maxPictures;
  final bool? flashIcon;
  final double? bottomLeftSize;
  final Function(int)? onCapture;
  const CameraFile({
    super.key,
    this.doneButton,
    this.bottomLeftButton,
    this.customProgressIndicator,
    this.centerWidgets, 
    this.bottomLeftSize,
    this.backButtonStyle,
    this.removeImageIcon,
    this.maxPictures,
    this.flashIcon,
    this.onCapture,
  });

  @override
  State<CameraFile> createState() => _CameraFileState();
}

class _CameraFileState extends State<CameraFile> with TickerProviderStateMixin {
  double zoom = 0.0;
  double _scaleFactor = 1.0;
  double scale = 1.0;
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  List<XFile> imageFiles = [];
  List<MediaModel> imageList = <MediaModel>[];
  late int _currIndex;
  late Animation<double> animation;
  late AnimationController _animationController;
  late Animation<double> scaleAnimation;

  FlashMode flashMode = FlashMode.off;

  setFlash(){
    if (this.flashMode == FlashMode.off){
      this.flashMode = FlashMode.always;
    }
    else {
      this.flashMode = FlashMode.off;
    }
  }

  hasCapturedAllImages(){
    if (widget.maxPictures == null){
      return null;
    }
    if (imageFiles.length >= widget.maxPictures!){
      for (int i = 0; i < imageFiles.length; i++) {
        File file = File(imageFiles[i].path);
        imageList.add(
            MediaModel.blob(file, "", file.readAsBytesSync()));
      }
      _animationController.stop();
      Navigator.pop(context, imageList);
    }
  }

  runAnimation(){
    if (_animationController.isAnimating){
      _animationController.stop();
    }
    setState(() {
      _animationController = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1500));
      animation = Tween<double>(begin: 400, end: 1).animate(scaleAnimation =
          CurvedAnimation(
              parent: _animationController, curve: Curves.elasticOut))
        ..addListener(() {});
      _animationController.forward();
      HapticFeedback.lightImpact();
    },);
  }

  addImages(XFile image) {
    imageFiles.add(image);
    hasCapturedAllImages();
  }

  removeImage() {
    imageFiles.removeLast();
  }

  Widget? _animatedButton({Widget? customContent}) {
    return (customContent != null)
        ? customContent
        : Container(
            height: 70,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: const Center(
              child: Text(
                'Done',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          );
  }

  Future<void> _initCamera() async {
    _animationController = AnimationController(vsync: this);
    _cameras = await availableCameras();
    // ignore: unnecessary_null_comparison
    if (_cameras != null) {
      _controller = CameraController(_cameras[0], ResolutionPreset.ultraHigh,
          enableAudio: false);
      _controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {}
  }

  @override
  void initState() {
    _initCamera();
    _currIndex = 0;

    super.initState();
  }

  Widget _buildCameraPreview() {
    return GestureDetector(
        onScaleStart: (details) {
          zoom = _scaleFactor;
        },
        onScaleUpdate: (details) {
          _scaleFactor = zoom * details.scale;
          _controller!.setZoomLevel(_scaleFactor);
        },
        child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(fit: StackFit.expand, children: [
              CameraPreview(_controller!),
              ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                shrinkWrap: true,
                itemCount: imageFiles.length,
                itemBuilder: ((context, index) {
                  return Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.bottomLeft,
                        // ignore: unnecessary_null_comparison
                        child: imageFiles[index] == null
                            ? const Text("No image captured")
                            : imageFiles.length - 1 == index
                                ? ScaleTransition(
                                    scale: scaleAnimation,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ImagePreviewView(
                                                          File(imageFiles[index]
                                                              .path),
                                                          "",
                                                        )));
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: widget.bottomLeftSize != null ? widget.bottomLeftSize!/2 : 40, left: 15),
                                        width: 77,
                                        height: 105,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 15),
                                              child: Image.file(
                                                File(
                                                  imageFiles[index].path,
                                                ),
                                                height: 90 ,
                                                width: 60,
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    removeImage();
                                                    widget.onCapture?.call(imageFiles.length);
                                                  });
                                                },
                                                child: (widget.removeImageIcon != null) ? widget.removeImageIcon : const Icon(
                                                  Icons.cancel,
                                                  color: Colors.white,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ImagePreviewView(
                                                    File(
                                                        imageFiles[index].path),
                                                    "",
                                                  )));
                                    },
                                    child: Image.file(
                                      File(
                                        imageFiles[index].path,
                                      ),
                                      height: 90,
                                      width: 60,
                                    ),
                                  ),
                      )
                    ],
                  );
                }),
                scrollDirection: Axis.horizontal,
              ),
              Positioned(
                right:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? widget.bottomLeftSize == null ? 340 : MediaQuery.of(context).size.width - widget.bottomLeftSize!
                        : null,
                top: widget.bottomLeftSize == null ? null : MediaQuery.of(context).size.height - widget.bottomLeftSize!,
                bottom: 0,
                left: 0,
                child: IconButton(
                  iconSize: widget.bottomLeftSize ?? 40,
                  icon: (widget.bottomLeftButton != null) ? widget.bottomLeftButton! : Icon(
                    Icons.camera_front,
                    color: Colors.white,
                    size: widget.bottomLeftSize,
                  ),
                  onPressed: _onCameraSwitch,
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).orientation == Orientation.portrait
                    ? 0
                    : null,
                bottom:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 0
                        : MediaQuery.of(context).size.height / 2.5,
                right: 0,
                child: Column(
                  children: [
                    SafeArea(
                      child: IconButton(
                        iconSize: 80,
                        icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                RotationTransition(
                                  turns: child.key == const ValueKey('icon1')
                                      ? Tween<double>(begin: 1, end: 0.75)
                                          .animate(anim)
                                      : Tween<double>(begin: 0.75, end: 1)
                                          .animate(anim),
                                  child: ScaleTransition(
                                      scale: anim, child: child),
                                ),
                            child: _currIndex == 0
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    key: const ValueKey("icon1"),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    key: const ValueKey("icon2"),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  )),
                        onPressed: () {
                          runAnimation();
                          _currIndex = _currIndex == 0 ? 1 : 0;
                          takePicture();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ])));
  }

  Future<void> _onCameraSwitch() async {
    final CameraDescription cameraDescription =
        (_controller!.description == _cameras[0]) ? _cameras[1] : _cameras[0];
    if (_controller != null) {
      await _controller!.dispose();
    }
    _controller = CameraController(
        cameraDescription, ResolutionPreset.ultraHigh,
        enableAudio: false);
    _controller!.addListener(() {
      if (mounted) setState(() {});
      if (_controller!.value.hasError) {}
    });

    try {
      await _controller!.initialize();
      // ignore: empty_catches
    } on CameraException {}
    if (mounted) {
      setState(() {});
    }
  }

  takePicture() async {
    if (_controller!.value.isTakingPicture) {
      return null;
    }
    try {
      if (this.flashMode == FlashMode.off){
        await _controller!.setFlashMode(FlashMode.off);
      }
      else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      final image = await _controller!.takePicture();
      await _controller!.setFlashMode(FlashMode.off);
      setState(() {
        addImages(image);
        HapticFeedback.lightImpact();
        widget.onCapture?.call(imageFiles.length);
      });
    } on CameraException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      if (!_controller!.value.isInitialized) {
        return Container();
      }
    } else {
      return Center(
        child: widget.customProgressIndicator ?? const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Row(
          children: [
            BackButton(
              style: (widget.backButtonStyle != null) ? widget.backButtonStyle : ButtonStyle(
                iconColor: MaterialStateProperty.all<Color>(Colors.white),
                iconSize: MaterialStateProperty.all<double>(50)
              ),
              onPressed: () => Navigator.pop(context, imageList),
            ),
            Flexible(child: Container()),
            Row(
              children: widget.centerWidgets != null ? widget.centerWidgets! : [],
            ),
            Flexible(child: Container()),
            (widget.flashIcon == true) ? IconButton(
              iconSize: 50,
              icon: Icon(
                (this.flashMode == FlashMode.off) ? Icons.flash_off_rounded : Icons.flash_on_rounded,
                color: Colors.white,
              ),
              onPressed: () => setState(() {
                setFlash();
              }),
            ) : Container(),
            imageFiles.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    for (int i = 0; i < imageFiles.length; i++) {
                      File file = File(imageFiles[i].path);
                      imageList.add(
                          MediaModel.blob(file, "", file.readAsBytesSync()));
                    }
                    Navigator.pop(context, imageList);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _animatedButton(customContent: widget.doneButton),
                  ))
              : const SizedBox(width: 8.0,)
          ],
        ),
        leadingWidth: double.infinity,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBody: true,
      body: _buildCameraPreview(),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();

    super.dispose();
  }
}

class MediaModel {
  File file;
  String filePath;
  Uint8List blobImage;
  MediaModel.blob(this.file, this.filePath, this.blobImage);
}