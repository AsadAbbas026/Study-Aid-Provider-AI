import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> getPublicMusicDirectory() async {
  final directory = await getExternalStorageDirectory();
  final musicDir = Directory('${directory!.path}/Music');
  if (!await musicDir.exists()) {
    await musicDir.create(recursive: true);
  }
  return musicDir.path;
}
