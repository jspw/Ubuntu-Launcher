import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:launcher/src/config/constants/size.dart';
import 'package:launcher/src/helpers/widgets/error_message.dart';

final picker = ImagePicker();

Future<PickedFile> getImage() async {
  var image = await picker.getImage(source: ImageSource.gallery);
  return image;
}

Future<PickedFile> _selectImageFromFile() async {
  var image = await picker.getImage(
    source: ImageSource.gallery,
  );
  return image;
}

Future<PickedFile> _captureFromCamera() async {
  var image = await picker.getImage(source: ImageSource.camera);
  return image;
}

typedef ImagePickedCallback = void Function(PickedFile image);

void pickImageFile(BuildContext context, ImagePickedCallback callback) {
  showDialog(
    context: context,
    builder: (builder) => new AlertDialog(
      scrollable: true,
      title: Text(
        "Select Wallpaper from",
        style: TextStyle(fontSize: subTitleSize),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              fontSize: smallTextSize,
              color: Colors.red,
            ),
          ),
        )
      ],
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () async {
              try {
                var image = await _captureFromCamera();
                callback(image);
              } catch (err) {
                ErrorMessage(context: context, error: err.toString()).display();
              } finally {
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.camera_alt_outlined, size: iconSize * 2),
                Text(
                  "Camera",
                  style: TextStyle(fontSize: normalTextSize),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              try {
                var image = await _selectImageFromFile();
                callback(image);
              } catch (err) {
                ErrorMessage(context: context, error: err.toString()).display();
              } finally {
                Navigator.of(context).pop();
              }
            },
            child: Column(
              children: [
                Icon(Icons.image_outlined, size: iconSize * 2),
                Text(
                  "Gallery",
                  style: TextStyle(fontSize: normalTextSize),
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}
