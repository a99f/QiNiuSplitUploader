///
/// Copyright (C) 2020 A99F.COM Inc. All rights reserved.
/// This is source code from a99f-dart-split-qiniu-uploader project.
/// The distribution of any copyright must be permitted by A99F.COM.
/// 此代码A99F.COM版权所有.
/// 说明: 七牛云创建块返回，七牛云返回的协议为json，不需要jsonDecode
/// 参见: https://developer.qiniu.com/kodo/api/1286/mkblk
/// 日期: Created by liyu on 2020/3/28 4:46 下午.
/// 作者: liyu
/// 更新版本          日期            作者             备注
/// v0001            2020/3/28     liyu             创建
///
import 'dart:convert';

class QiNiuMakeBlock {
  String ctx; //上下文
  String checksum;
  int crc32;
  int offset;
  String host;
  int expiredAt;

  QiNiuMakeBlock({
    this.ctx,
    this.checksum,
    this.crc32,
    this.offset,
    this.host,
    this.expiredAt,
  });

  factory QiNiuMakeBlock.fromRawJson(String str) => QiNiuMakeBlock.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QiNiuMakeBlock.fromJson(Map<String, dynamic> json) => QiNiuMakeBlock(
    ctx: json["ctx"],
    checksum: json["checksum"],
    crc32: json["crc32"],
    offset: json["offset"],
    host: json["host"],
    expiredAt: json["expired_at"],
  );

  Map<String, dynamic> toJson() => {
    "ctx": ctx,
    "checksum": checksum,
    "crc32": crc32,
    "offset": offset,
    "host": host,
    "expired_at": expiredAt,
  };
}
