import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'dart:typed_data';
import 'package:uuid/uuid.dart';

///
/// Copyright (C) 2020 A99F.COM Inc. All rights reserved.
/// This is source code from a99f-dart-split-qiniu-uploader project.
/// The distribution of any copyright must be permitted by A99F.COM.
/// 此代码A99F.COM版权所有.
/// 说明: 文件切割
/// 参见:
/// 日期: Created by liyu on 2020/3/28 4:25 下午.
/// 作者: liyu
/// 更新版本          日期            作者             备注
/// v0001            2020/3/28     liyu             创建
///
class FileUtils {
  ///
  /// Function(函数名称): getFileObj
  /// Description(描述): 获取文件对象
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
  static File getFileObj(String filePath) {
    File file = new File(filePath);
    return file;
  }

  ///
  /// Function(函数名称): isFileExist
  /// Description(描述): 检查文件是否存在
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
  static bool isFileExist(String filePath) {
    File file = new File(filePath);
    return file.existsSync();
  }

  ///
  /// Function(函数名称): getFileSize
  /// Description(描述): 获取文件尺寸
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
  static int getFileSize(String filePath) {
    File file = getFileObj(filePath);
    return file.lengthSync();
  }

  ///
  /// Function(函数名称): writeSplitFile
  /// Description(描述): 写单片文件，默认1M，fileSize如果为4，即为4M
  /// Calls(被本函数调用的函数清单):
  /// Called By(调用本函数的函数清单):
  /// Table Accessed(被访问的表):
  /// Table Updated(被修改的表):
  /// Outputs(对输出参数的说明): 无
  /// Return(函数返回值的说明): 无
  /// Others(其他说明):
  /// Input: //输入参数说明，包括每个参数的作用、取值说明及参数间关系。
  /// String originFile 源文件路径
  /// String fileName 目标文件路径
  /// int fileSize 文件大小字节数
  /// ------------------------------------------------------------
  /// 更新版本          日期            作者             备注
  /// v0001            2020-03-28     liyu             创建
  ///
  void writeSplitFile(String originFile, String fileName, int fileSize, {start: 0, lastSize: 0}) {
    ///原文件对象
    File originFileObj = new File(originFile);

    ///目标文件对象
    File targetFileObj = new File(fileName);

    ///处理文件的指针，默认起始位置为0
    int pointer = start;

    if (targetFileObj.existsSync() == true) {
      targetFileObj.delete();
    }

    if (lastSize == 0) {
      /// 最后字节块的处理
      /// 16次循环65536正好等于1024*1024
      for (var i = 0; i < 16 * fileSize; i++) {
        int endPointer = 0;

        endPointer = pointer + 65536;

        originFileObj.openRead(pointer, endPointer).listen((data) {
          targetFileObj.writeAsBytesSync(data, mode: FileMode.append);
        });

        pointer = pointer + 65536;
      }
    } else {
      /// 其余字节块的处理
      /// 字节块以1M为单位需要循环的次数
      int endTimes = (lastSize / (1024 * 1024)).floor();

      /// 字节块小于1M的部分
      int leftSize = (lastSize % (1024 * 1024));

      ///循环处理字节块，每个部分为1M，即1024*1024，65536B
      for (var j = 0; j < 16 * (endTimes); j++) {
        ///结束时指针，每一个1M，最后结束时都为当前指针的位置+65536
        int endPointer1 = pointer + 65536;

        if (j == 0) {
          originFileObj.openRead(pointer, endPointer1).listen((data) {
            targetFileObj.writeAsBytesSync(data, mode: FileMode.append);
          });
        } else {
          originFileObj.openRead(pointer, endPointer1).listen((data) {
            targetFileObj.writeAsBytesSync(data, mode: FileMode.append);
          });
        }

        ///起始指针滑动到下一个1M块的开始处
        pointer = pointer + 65536;
      }

      ///如果最后一个块有剩余，追加到最后目标文件的结尾处
      if (leftSize > 0) {
        print("start:" + pointer.toString() + ",end:" + (pointer + leftSize).toString());
        originFileObj.openRead(pointer, pointer + leftSize).listen((data) {
          targetFileObj.writeAsBytesSync(data, mode: FileMode.append);
        });
      }
    }
  }

  ///
  /// Function(函数名称): getHashCode
  /// Description(描述): 获取文件哈希码
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
  /// v0001            2020-03-28    liyu             创建
  ///
  static int getHashCode(String filePath) {
    File file = getFileObj(filePath);
    return file.hashCode;
  }

  ///
  /// Function(函数名称): getAllData
  /// Description(描述): 获取所有文件字节码
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
  /// v0001                 liyu             创建
  ///
  static Uint8List getAllData(filePath) {
    File file = getFileObj(filePath);
    return file.readAsBytesSync();
  }

  ///
  /// Function(函数名称): mergeFile
  /// Description(描述): 整合文件，以验证分割文件的正确性
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
  void mergeFile(String filePath, String fileType, int fileNumber) {
    /// 目标文件路径
    String targetFile = filePath + "_merge" + fileType;

    /// 目标文件对象
    File targetFileObj = FileUtils.getFileObj(targetFile);

    //初始化队列，以免造成异步写入错乱的问题
    Queue q = new Queue();


    for (var i = 0; i < fileNumber; i++) {
      q.add(i);
    }

    if (targetFileObj.existsSync() == true) {
      targetFileObj.delete();
    }

    for (var j in q) {
      print("queue:" + j.toString());
      String splitFilePath = filePath + "/" + j.toString();
      File splitFileObj = new File(splitFilePath);

      //读取分块文件的字节码
      var datas = splitFileObj.readAsBytesSync();
      //写入目标文件
      targetFileObj.writeAsBytesSync(datas, mode: FileMode.append);
    }
  }

  ///
  /// Function(函数名称): splitCheck
  /// Description(描述): 块字节码校验
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
  void splitCheck() {
    String filePath = "assets/file/split/fcd.flac_0";
    File fileObj = new File(filePath);

    String filePath1 = "assets/file/fcd.flac_0";
    File fileObj1 = new File(filePath1);

    String filePath2 = "assets/file/fcd.flac_1";
    File fileObj2 = new File(filePath2);

    String filePath3 = "assets/file/split/fcd.flac_1";
    File fileObj3 = new File(filePath3);

    Queue queue = new Queue();

    queue.add(0);
    queue.add(1);
    queue.add(2);
    queue.add(3);
    queue.add(4);
    queue.add(5);
    queue.add(6);

    for (var q in queue) {
      compareFile("assets/file/split/fcd.flac_" + q.toString(), "assets/file/fcd.flac_" + q.toString());
    }

//    fileObj2
//        .openRead(fileObj2.lengthSync() - 10, fileObj2.lengthSync())
//        .listen((data) {
//      print("<<"+data.toString());
//    });
  }

  ///
  /// Function(函数名称): compareFile
  /// Description(描述): 对比多个文件，以验证新旧文件的字节精度
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
  void compareFile(String oldFileName, String newFileName) {
    new File(oldFileName).openRead(0, 10).listen((data) {
      print("${oldFileName} begin:" + data.toString());
    });

    new File(newFileName).openRead(0, 10).listen((data) {
      print("${newFileName} begin:" + data.toString());
    });

    new File(oldFileName).openRead(new File(oldFileName).lengthSync() - 10, new File(oldFileName).lengthSync()).listen((data) {
      print("${oldFileName} end:" + data.toString());
    });

    new File(newFileName).openRead(new File(newFileName).lengthSync() - 10, new File(newFileName).lengthSync()).listen((data) {
      print("${newFileName} end:" + data.toString());
    });
  }

  ///
  /// Function(函数名称): createRandomFolder
  /// Description(描述): 创建随机文件夹
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
  /// v0001            2020/3/28     liyu             创建
  ///
  String createRandomFolder() {
    Uuid uuid = new Uuid();
    //print("uuid:" + uuid.v4().toString());

    String uuidStr = uuid.v4().toString();

    String folderPath = "assets/file/" + uuidStr + "";

    var dir = Directory(folderPath);

    dir.createSync();

    return folderPath;
  }

  ///
  /// Function(函数名称): getFolderFileNumber
  /// Description(描述): 获取文件夹内的文件数量
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
  /// v0001            2020/3/28     liyu             创建
  ///
  int getFolderFileNumber(String folderPath) {
    Directory folder = Directory(folderPath);

    print("folderPath:" + folderPath);

    bool isExist = folder.existsSync();

    print("isExist:" + isExist.toString());

    int index = 0;

    if (isExist) {
      //遍历所有文件夹
      List<FileSystemEntity> packageList = folder.listSync();
      index = packageList.length;

      for (var p in packageList) {
        print(p.path);
      }
    }

    return index;
  }

  ///
  /// Function(函数名称): splitFileInFolder
  /// Description(描述): 在文件夹内分割文件
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
  /// v0001            2020/3/28     liyu             创建
  ///
  int splitFileInFolder(String targetFilePath, String folderPath) {
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

    //////                             //////
    // ==============================  //
    // 4M块 开始                       //
    // ============================== //
    /////                            //////

    for (int i = 0; i < splitTimes; i++) {
      //分割文件，写到子块中
      new FileUtils().writeSplitFile(targetFilePath, folderPath + "/" + index.toString(), 4, start: start);
      //位移块指针，以生成下一个分块
      start = start + BLOCK_SIZE;
      print("start==>" + start.toString());
      //增加分割次数
      index++;
    }

    //////                             //////
    // ==============================  //
    // 4M块 结束                       //
    // ============================== //
    /////                            //////

    //////                             //////
    // ==============================  //
    // 剩余小于4M的块 开始               //
    // ============================== //
    /////                            //////

    //小于4M，剩余的块
    int endBlockSize = (targetFileSize % BLOCK_SIZE);
    if (endBlockSize > 0) {
      print("endblock:" + endBlockSize.toString());
      //分割文件，写到子块中
      new FileUtils().writeSplitFile(targetFilePath, folderPath + "/" + index.toString(), 4, start: start, lastSize: endBlockSize);
    }

    //////                             //////
    // ==============================  //
    // 剩余小于4M的块 结束               //
    // ============================== //
    /////                            //////

    return index;
  }

  ///
  /// Function(函数名称): splitFileInFolderOneTime
  /// Description(描述): 切割文件
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
  Future<int> splitFileInFolderOneTime(String targetFilePath, String folderPath) async {
    //源文件
    File targetFile = new File(targetFilePath);
    //源文件大小，字节
    int targetFileSize = targetFile.lengthSync();

    print("targetFileSize:" + targetFileSize.toString());
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

//    targetFile.openRead(0, targetFileSize).listen((data) {
////      if (index >= index && index <= (i * BLOCK_SIZE)) {
////        splitFile.writeAsBytesSync(data, mode: FileMode.append);
////      }
////
////      if (endBlockSize > 0) {
////        print("endblock:" + endBlockSize.toString());
////        File splitFile1 = new File(folderPath + "/" + index.toString());
////        //分割文件，写到子块中
////        splitFile1.writeAsBytesSync(data, mode: FileMode.append);
////      }
//      print(index);
//      index++;
//    });

//    Stream stream = targetFile.openRead();

    int position = 0;

//    targetFile.openRead().listen((data){

//      }
//
//      index++;
//    });

    //}
//    int index=0;
//    stream.listen((data) {

//    });

    for (int i = 0; i < splitTimes; i++) {
      Future<List<int>> fileBlock = getRange(targetFile, i * BLOCK_SIZE, (i + 1) * BLOCK_SIZE);
      File targetFile1 = new File(folderPath + "/" + i.toString());

      fileBlock.then((data) async {
        await targetFile1.writeAsBytes(data, mode: FileMode.append);
      });
      index++;
    }

    if (endBlockSize > 0) {
      print("endblock:" + endBlockSize.toString());
      File splitFile1 = new File(folderPath + "/" + index.toString());

      Future<List<int>> fileBlock1 = getRange(targetFile, index * BLOCK_SIZE, index * BLOCK_SIZE + endBlockSize);
      fileBlock1.then((data) async {
        //分割文件，写到子块中
        await splitFile1.writeAsBytes(data, mode: FileMode.append);
      });
    }

    return index;
  }

  ///
  /// Function(函数名称): getRange
  /// Description(描述): 读取文件范围，支持大文件读取
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
  Future<List<int>> getRange(File file, int start, int end) async {
    if (file == null || !file.existsSync()) {
//      throw FileNotExistsError();
    }
    if (start < 0) {
      throw RangeError.range(start, 0, file.lengthSync());
    }
    if (end > file.lengthSync()) {
      throw RangeError.range(end, 0, file.lengthSync());
    }

    final c = Computer<List<int>>();

    List<int> result = [];
    file.openRead(start, end).listen((data) {
      result.addAll(data);
    }).onDone(() {
      c.reply(result);
    });

    return c.future;
  }
}

class Computer<T> {
  Completer<T> completer = Completer();

  Computer();

  Future<T> get future => completer.future;

  void reply(T result) {
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }
}
