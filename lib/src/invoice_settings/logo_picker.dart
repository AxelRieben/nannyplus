import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nannyplus/utils/logo_picker_controller.dart';
import 'package:path_provider/path_provider.dart';

class LogoPicker extends StatefulWidget {
  const LogoPicker({required this.controller, super.key});
  final LogoPickerController controller;

  @override
  State<LogoPicker> createState() => _LogoPickerState();
}

class _LogoPickerState extends State<LogoPicker> {
  Uint8List? bytes;
  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          focusNode: focusNode,
          onPressed: () => openLogoChooser(focusNode),
          child: Text(context.t('Choose a logo')),
        ),
        FutureBuilder<Directory>(
          future: getApplicationDocumentsDirectory(),
          builder: (context, value) {
            return GestureDetector(
              child: buildSquare(value, focusNode),
              onTap: () => openLogoChooser(focusNode),
            );
          },
        ),
      ],
    );
  }

  Widget buildSquare(AsyncSnapshot<Directory> value, FocusNode focusNode) {
    if (bytes != null) {
      return ClipRect(
        child: Image.memory(
          bytes!,
          height: 120,
          fit: BoxFit.contain,
          key: UniqueKey(),
        ),
      );
    } else {
      if (value.hasData) {
        final appDocumentsPath = value.data!.path;
        final filePath = '$appDocumentsPath/logo';
        if (File(filePath).existsSync()) {
          imageCache.clearLiveImages();

          return ClipRect(
            child: Image.file(
              File(filePath),
              height: 120,
              fit: BoxFit.contain,
              key: UniqueKey(),
            ),
          );
        } else {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey,
          );
        }
      } else {
        return Container(
          width: 120,
          height: 120,
          color: Colors.grey,
        );
      }
    }
  }

  Future<void> openLogoChooser(FocusNode focusNode) async {
    focusNode.requestFocus();
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      //Directory appDocumentsDirectory =
      //    await getApplicationDocumentsDirectory();
      //var appDocumentsPath = appDocumentsDirectory.path;
      //var filePath = '$appDocumentsPath/logo';
      //await image.saveTo(filePath);
      final b = await image.readAsBytes();
      widget.controller.bytes = b;
      setState(() {
        bytes = b;
      });
      //context
      //    .read<SettingsScreenCubit>()
      //    .updateLogo(image.hashCode);
    }
  }
}
