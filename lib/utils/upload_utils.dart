import 'dart:convert';
import 'dart:io';

import 'package:a99f_dart_split_qiniu_uploader/model/qiniu_mkblk_response.dart';
import 'package:a99f_dart_split_qiniu_uploader/model/server_response.dart';
import 'package:dio/dio.dart';

import 'file_utils.dart';

///
/// Copyright (C) 2020 A99F.COM Inc. All rights reserved.
/// This is source code from a99f-dart-split-qiniu-uploader project.
/// The distribution of any copyright must be permitted by A99F.COM.
/// 此代码A99F.COM版权所有.
/// 说明: 分片上传文件到七牛云
/// 主要步骤：创建块，块分片上传，整合块
/// 创建块：https://developer.qiniu.com/kodo/api/1286/mkblk
/// 参见:
/// 日期: Created by liyu on 2020/3/28 4:25 下午.
/// 作者: liyu
/// 更新版本          日期            作者             备注
/// v0001            2020/3/28     liyu             创建
///
class Uploader {
  /// 远程服务器，用于获取七牛云的授权
  final String SERVER_GET_TOKEN_URL = "http://service.a99f.com/Test/QiNiu/getUploadToken";

  /// 七牛云空间，华南节点, 如果容器在不同区域，需要修改这里
  final String QINIU_DOMAIN_URL = "http://up-z2.qiniup.com";

  ///
  /// Function(函数名称): doUpload
  /// Description(描述): 上传文件到七牛云
  /// Calls(被本函数调用的函数清单)
  /// Called By(调用本函数的函数清单):
  /// Table Accessed(被访问的表):
  /// Table Updated(被修改的表):
  /// Outputs(对输出参数的说明):
  /// Return(函数返回值的说明):
  /// Others(其他说明):
  /// Input: //输入参数说明，包括每个参数的作用、取值说明及参数间关系。
  /// ------------------------------------------------------------
  /// 更新版本          日期            作者             备注
  /// v0001            2020-03-28     liyu             创建
  ///
  Future<void> doUpload(String filePath, String fileFolderPath) async {
    List<String> ctxs = new List();
    int ctxLength = 0;
    String ctxStr = "";

    for (int i = 0; i < 6; i++) {
      File file = new File("assets/file/qwr.mp4_" + i.toString());
      String token = await getRemoteUploadToken("test" + i.toString());
      String ctx = await uploadMakeBlock(file, token);
      print("ctx-" + i.toString() + ":" + ctx);

      ctxLength = ctxLength + ctx.length;
      if (i != 5) {
        ctxStr = ctxStr + ctx + ",";
      } else {
        ctxStr = ctxStr + ctx + "";
      }
      ctxs.add(ctx);

      if (i == 5) {
        print("=========== end ===========");
        print("list to String:" + ctxs.toString());
        uploadMakeFile(ctxs, ctxLength, ctxStr);
      }
    }
  }

  ///
  /// Function(函数名称): uploadMakeFile
  /// Description(描述): 发送指令整合七牛云块文件
  /// Calls(被本函数调用的函数清单):
  /// Called By(调用本函数的函数清单):
  /// Table Accessed(被访问的表):
  /// Table Updated(被修改的表):
  /// Outputs(对输出参数的说明):
  /// Return(函数返回值的说明):
  /// Others(其他说明):
  /// Input: //输入参数说明，包括每个参数的作用、取值说明及参数间关系。
  /// ------------------------------------------------------------
  /// 更新版本          日期            作者             备注
  /// v0001            2020-03-28     liyu             创建
  ///
  Future<void> uploadMakeFile(List ctxs, int ctxLength, String ctxStr) async {
    File oldFile = new File("assets/file/qwr.mp4");

    List<int> policyTextUtf8 = utf8.encode("test");
    String policyBase64 = base64.encode(policyTextUtf8);
    print("key utf-8:" + policyBase64);
    print("context length:" + ctxLength.toString());
    print("context Str:" + ctxStr);

    String makeFileUrl = QINIU_DOMAIN_URL + "/mkfile/" + oldFile.lengthSync().toString() + "/key/" + policyBase64;
    print("blockSize:" + oldFile.lengthSync().toString());
    String token = await getRemoteUploadToken("test");
    print("test token:" + token);
    Response response = await new Dio().post(
      makeFileUrl,
      data: ctxStr,
      options: Options(
        headers: {
          "Content-Type": "text/plain",
          "Authorization": "UpToken ${token}",
          "Content-Length": ctxLength, // set content-length
        },
      ),
    );

    print("response:" + response.statusCode.toString());
    print("response:" + response.data.toString());
  }

  ///
  /// Function(函数名称): uploadMakeFile
  /// Description(描述): 发送指令整合七牛云块文件
  /// Calls(被本函数调用的函数清单):
  /// Called By(调用本函数的函数清单):
  /// Table Accessed(被访问的表):
  /// Table Updated(被修改的表):
  /// Outputs(对输出参数的说明):
  /// Return(函数返回值的说明):
  /// Others(其他说明):
  /// Input: //输入参数说明，包括每个参数的作用、取值说明及参数间关系。
  /// ------------------------------------------------------------
  /// 更新版本          日期            作者             备注
  /// v0001            2020-03-28     liyu             创建
  ///
  Future<void> uploadMakeFileWithBlock(String filePath, String keyName, int ctxLength, String ctxStr) async {
    File oldFile = new File(filePath);

    List<int> policyTextUtf8 = utf8.encode(keyName);
    String policyBase64 = base64.encode(policyTextUtf8);
    print("key utf-8:" + policyBase64);
    print("context length:" + ctxLength.toString());
    print("context Str:" + ctxStr);

    String makeFileUrl = QINIU_DOMAIN_URL + "/mkfile/" + oldFile.lengthSync().toString() + "/key/" + policyBase64;
    print("blockSize:" + oldFile.lengthSync().toString());
    String token = await getRemoteUploadToken(keyName);
    print("test token:" + token);
    Response response = await new Dio().post(
      makeFileUrl,
      data: ctxStr,
      options: Options(
        headers: {
          "Content-Type": "text/plain",
          "Authorization": "UpToken ${token}",
          "Content-Length": ctxLength, // set content-length
        },
      ),
    );

    print("response:" + response.statusCode.toString());
    print("response:" + response.data.toString());
  }

  ///
  /// Function(函数名称): uploadMakeBlock
  /// Description(描述): 创建块，并上传至七牛云
  /// Calls(被本函数调用的函数清单):
  /// Called By(调用本函数的函数清单):
  /// Table Accessed(被访问的表):
  /// Table Updated(被修改的表):
  /// Outputs(对输出参数的说明):
  /// Return(函数返回值的说明):
  /// Others(其他说明):
  /// Input: //输入参数说明，包括每个参数的作用、取值说明及参数间关系。
  /// ------------------------------------------------------------
  /// 更新版本          日期            作者             备注
  /// v0001            2020-03-28     liyu             创建
  ///
  Future<String> uploadMakeBlock(File file, String token) async {
    List<int> postData = await file.readAsBytesSync();
    String makeBlockUrl = QINIU_DOMAIN_URL + "/mkblk/" + file.lengthSync().toString();
    print("blockSize:" + file.lengthSync().toString());
    Response response = await new Dio().post(
      makeBlockUrl,

      ///create a Stream<List<int>>
      data: Stream.fromIterable(postData.map((e) => [e])),
      options: Options(
        headers: {
          "Content-Type": "application/octet-stream",
          "Authorization": "UpToken ${token}",
          "Content-Length": postData.length, // set content-length
        },
      ),
    );
  }

  ///
  /// Function(函数名称): uploadMakeBlockWithBlock
  /// Description(描述): 直接上传块状数据到七牛云
  /// Calls(被本函数调用的函数清单):
  /// Called By(调用本函数的函数清单):
  /// Table Accessed(被访问的表):
  /// Table Updated(被修改的表):
  /// Outputs(对输出参数的说明):
  /// Return(函数返回值的说明):
  /// Others(其他说明):
  /// Input: //输入参数说明，包括每个参数的作用、取值说明及参数间关系。
  /// ------------------------------------------------------------
  /// 更新版本          日期            作者             备注
  /// v0001            2020/3/29     liyu             创建
  ///
  Future<String> uploadMakeBlockWithBlock(List<int> postData, String token, String blockSize) async {
    String makeBlockUrl = QINIU_DOMAIN_URL + "/mkblk/" + blockSize;
    Response response = await new Dio().post(
      makeBlockUrl,
      data: Stream.fromIterable(postData.map((e) => [e])),
      options: Options(
        headers: {
          "Content-Type": "application/octet-stream",
          "Authorization": "UpToken ${token}",
          "Content-Length": postData.length, // set content-length
        },
      ),
    );

    print("response:" + response.data.toString());

    ///无须jsonDecod额，返回协议为application/json
    QiNiuMakeBlock qiNiuMakeBlock = QiNiuMakeBlock.fromJson(response.data);
    print("resp,ctx:" + qiNiuMakeBlock.ctx);

    //返回context
    return qiNiuMakeBlock.ctx;
  }

  ///
  /// Function(函数名称): getRemoteUploadToken
  /// Description(描述):  获取桥为人服务器对于七牛云的上传授权
  /// Calls(被本函数调用的函数清单):
  /// Called By(调用本函数的函数清单):
  /// Table Accessed(被访问的表):
  /// Table Updated(被修改的表):
  /// Outputs(对输出参数的说明):
  /// Return(函数返回值的说明):
  /// Others(其他说明):
  /// Input: //输入参数说明，包括每个参数的作用、取值说明及参数间关系。
  /// ------------------------------------------------------------
  /// 更新版本          日期            作者             备注
  /// v0001            2020-03-28     liyu             创建
  ///
  Future<String> getRemoteUploadToken(String fileName) async {
    Response response = await new Dio().get(SERVER_GET_TOKEN_URL + "?fileName=" + fileName);

    ServerResponse serverResp = ServerResponse.fromJson(json.decode(response.data));

    return serverResp.result;
  }

  ///
  /// Function(函数名称): doSplitUpload
  /// Description(描述): 分片上传，直接读取源文件的块片段上传，无需通过切割文件再上传的办法。
  /// Calls(被本函数调用的函数清单):
  /// Called By(调用本函数的函数清单):
  /// Table Accessed(被访问的表):
  /// Table Updated(被修改的表):
  /// Outputs(对输出参数的说明):
  /// Return(函数返回值的说明):
  /// Others(其他说明):
  /// Input: //输入参数说明，包括每个参数的作用、取值说明及参数间关系。
  /// ------------------------------------------------------------
  /// 更新版本          日期            作者             备注
  /// v0001            2020/3/29     liyu             创建
  ///
  Future<void> doSplitUpload(String targetFilePath, String targetName) async {
    //源文件
    File targetFile = new File(targetFilePath);
    //源文件大小，字节
    int targetFileSize = targetFile.lengthSync();

    //块尺寸，默认为4M
    final int BLOCK_SIZE = 1024 * 1024 * 4;

    //需要分割的次数
    int splitTimes = (targetFileSize / BLOCK_SIZE).floor();

    //文件游标，起始位置为0
    int start = 0;

    //循环次数，用于计算最后一次剩余块的处理
    int index = 0;

    int times = 0;

    //小于4M，剩余的块
    int endBlockSize = (targetFileSize % BLOCK_SIZE);

    List<String> ctxs = new List();
    int ctxLength = 0;
    String ctxStr = "";

    for (int i = 0; i < splitTimes; i++) {
      ///读取块数据
      List<int> fileBlock = await FileUtils().getRange(targetFile, i * BLOCK_SIZE, (i + 1) * BLOCK_SIZE);

      ///获取远程服务器授权链接
      String token = await getRemoteUploadToken("test" + i.toString());

      ///上传块到七牛云
      String ctx = await uploadMakeBlockWithBlock(fileBlock, token, BLOCK_SIZE.toString());

      ctxLength = ctxLength + ctx.length;

      if (i != (splitTimes - 1)) {
        ctxStr = ctxStr + ctx + ",";
      } else {
        if (endBlockSize > 0) {
          ctxStr = ctxStr + ctx + ",";
        } else {
          ctxStr = ctxStr + ctx + "";
        }
      }
      ctxs.add(ctx);

      index++;
    }

    if (endBlockSize > 0) {
      ///读取块数据
      List<int> fileBlock1 = await FileUtils().getRange(targetFile, index * BLOCK_SIZE, index * BLOCK_SIZE + endBlockSize);

      ///获取远程服务器授权链接
      String token = await getRemoteUploadToken("test" + index.toString());

      ///上传块到七牛云
      String ctx = await uploadMakeBlockWithBlock(fileBlock1, token, endBlockSize.toString());

      ctxLength = ctxLength + ctx.length;
      ctxStr = ctxStr + ctx + "";

      ctxs.add(ctx);
    }

    /// 发送指令整合七牛云块文件
    uploadMakeFileWithBlock(targetFilePath, targetName, ctxLength, ctxStr);
  }
}
