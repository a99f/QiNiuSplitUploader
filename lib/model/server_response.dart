import 'dart:convert';

import 'dart:convert';

///
/// Copyright (C) 2020 A99F.COM Inc. All rights reserved.
/// This is source code from a99f-dart-split-qiniu-uploader project.
/// The distribution of any copyright must be permitted by A99F.COM.
/// 此代码A99F.COM版权所有.
/// 说明: 与服务器的通讯基本协议
/// 参见: https://developer.qiniu.com/kodo/api/1286/mkblk
/// 日期: Created by liyu on 2020/3/28 4:25 下午.
/// 作者: liyu
/// 更新版本          日期            作者             备注
/// v0001            2020/3/28     liyu             创建
///
class ServerResponse<T> {
  String status;
  String msg;
  T result;

  ServerResponse({
    this.status,
    this.msg,
    this.result,
  });

  factory ServerResponse.fromRawJson(String str) => ServerResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ServerResponse.fromJson(Map<String, dynamic> json) => ServerResponse(
    status: json["status"],
    msg: json["msg"],
    result: json["result"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "msg": msg,
    "result": result,
  };

  @override
  String toString() {
    return '{"status": ${status != null ? '${json.encode(status)}' : 'null'},"msg": ${msg != null ? '${json.encode(msg)}' : 'null'},"result": ${result != null ? '${json.encode(result)}' : 'null'}}';
  }
}
