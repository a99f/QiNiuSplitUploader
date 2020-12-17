import 'dart:io';

import 'package:a99f_dart_split_qiniu_uploader/utils/upload_utils.dart';

void main(List<String> arguments) async {
  ///需要上传的文件路径
  String filePath = "assets/file/xiao.mp3";

  ///切割文件并上传
  await Uploader().doSplitUpload(filePath, "xiao.mp3");
}
