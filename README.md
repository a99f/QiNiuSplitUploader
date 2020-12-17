# Dart实现七牛云分片上传

### 项目背景
我们的团队在开发Flutter短视频录制模块的过程中，发现七牛云没有兼容flutter的上传模块，并且原生Java/OC模块经过重写后依然存在体积过大的问题，于是产生了这个项目，实现轻量化上传，不需要原生库支持，完成在Flutter层面上的媒体开发。

基于七牛云的对象存储块文档，我们可以将flutter或dart服务器上的二进制文件进行切割上传，并在云端调用命令整合即可。

In the process of developing Flutter short video recording module, our team found that SevenNiu Cloud has no flutter compatible upload module, and the native Java/OC module still has the problem of oversized after rewriting, so we generated this project to achieve lightweight upload without native library support and complete media development at Flutter level.

Based on the object storage block documentation of the seven cows cloud, we can cut and upload the binary files on the flutter or dart server and just call the command integration in the cloud.

七牛云文档： https://developer.qiniu.com/kodo/api/1286/mkblk

上传时需要调用自身的服务器获取七牛云的授权Token链接，安全交互算法可以自行编写。

经过测试，媒体文件上传后可正常播放。

QiNiu cloud documentation: https://developer.qiniu.com/kodo/api/1286/mkblk

When uploading, you need to call your own server to get the authorization Token link from SevenNiuCloud, and the security interaction algorithm can be written by yourself.

After testing, the media files can be played normally after uploading.

### 分割原理
对一个二进制文件进行分割，按1MB进行计算进行分割，可以分成若干份。通过文件流操作，可以实现文件游标任意位置上的切割和整合。JAVA代码实现如下：

Splitting a binary file is calculated by 1MB for splitting, which can be divided into several parts. The file stream operation allows cutting and integration on any position of the file cursor. java code is implemented as follows.

```java
 import java.io.*;
 
 public class FileUtil {
     /**
      * 分割后的每个文件大小 这里是 1M
      */
     private static final int SIZE = 1024 * 1024 * 4;
 
 
     /**
      * 文件分割
      *
      * @param srcFile 原始文件
      * @param path    保存分割后的文件位置
      */
     public void splitFile(File srcFile, String path) {
         if (srcFile.length() < 0 || !srcFile.isFile()) {
             // log.error("文件内容不正确");
             System.out.println("文件内容不正确");
             return;
         }
         FileInputStream inputStream = null;
         try {
             inputStream = new FileInputStream(srcFile);
             // 分割后的文件的数量
             long chunkFileNum = srcFile.length() % SIZE == 0 ? srcFile.length() / SIZE : srcFile.length() / SIZE + 1;
             // 每次读取的大小
             byte[] buffer = new byte[1024];
             // 实际读取的大小
             int length = -1;
             for (int i = 0; i < chunkFileNum; i++) {
                 File distFile = new File(path + i);
                 FileOutputStream outputStream = new FileOutputStream(distFile);
                 while ((length = inputStream.read(buffer)) != -1) {
                     outputStream.write(buffer);
                     if (distFile.length() >= SIZE) {
                         //关闭写流,进行下一个分块文件
                         outputStream.close();
                         break;
                     }
                 }
             }
             // log.info("分割完成请到{}文件下查看", path);
             System.out.println("分割完成");
         } catch (Exception e) {
             // log.error("解析文件错误", e);
             System.out.println("解析文件错误");
             e.printStackTrace();
         } finally {
             try {
                 //关闭读流
                 inputStream.close();
             } catch (IOException e) {
                 e.printStackTrace();
             }
         }
 
     }
 
 
     /**
      * 文件合并
      *
      * @param path         需要服分割文件的路劲
      * @param distFileName 合并后文件的名称，请加上后缀名
      */
     public void mergeFile(String path, String distFileName) {
         File file = new File(path);
         File[] listFiles = file.listFiles();
         if (listFiles == null || listFiles.length == 0) {
             // log.error("文件目录下为空");
             System.out.println("文件目录下为空");
             return;
         }
         OutputStream out = null;
         try {
             out = new FileOutputStream(new File(distFileName));
             for (int i = 0; i < listFiles.length; i++) {
                 // 每次读取的大小
                 byte[] buffer = new byte[1024];
                 // 实际读取的大小
                 int length = -1;
                 InputStream in = new FileInputStream(new File(path + "/" + i));
                 while ((length = in.read(buffer)) != -1) {
                     out.write(buffer, 0, length);
                 }
                 in.close();
             }
             // log.info("文件和并完成,请到{}查看",distFileName);
             System.out.println("文件合并完成");
         } catch (Exception e) {
             e.printStackTrace();
         } finally {
             try {
                 out.close();
             } catch (IOException e) {
                 e.printStackTrace();
             }
         }
     }
 }
```

dart实现的基本原理与之相似，具体实现时文件的范围，特别是大文件的范围查找，需要使用dart的异步编程Futuer特性，性能比较优异。

The basic principle of dart implementation is similar, the specific implementation of the range of files, especially the range of large files to find, need to use dart's asynchronous programming Futuer feature, the performance is superior.

```dart
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
```
