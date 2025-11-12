import 'dart:io';

import 'package:chat_app/core/entities/entity.dart';
import 'package:dio/dio.dart';

enum AttachmentType {
  document("DOCUMENT"),
  image("IMAGE"),
  audio("AUDIO"),
  voice("VOICE"),
  video("VIDEO");

  const AttachmentType(this.value);
  final String value;

  factory AttachmentType.fromValue(String value) {
    final res = AttachmentType.values.where(
      (element) => element.value == value,
    );

    if (res.isEmpty) {
      throw 'ValueError: $value is not a valid attachment type';
    }

    return res.first;
  }
}

enum UploadStatus {
  notUploading("NOT_UPLOADING"),
  preparing("PREPARING"),
  uploading("UPLOADING"),
  uploaded("UPLOADED");

  const UploadStatus(this.value);
  final String value;
  factory UploadStatus.fromValue(String value) {
    final res = UploadStatus.values.where(
      (element) => element.value == value,
    );

    if (res.isEmpty) {
      throw 'ValueError: $value is not a valid upload status';
    }

    return res.first;
  }
}

class Attachment extends BaseEntity {
  final int id;
  String file;
  String? fileName;
  UploadStatus? uploadStatus;
  final double width;
  final double height;

  Attachment(
      {required this.id,
      required this.file,
      this.uploadStatus,
      this.fileName,
      this.width = 300,
      this.height = 400});

  factory Attachment.fromMap(Map<String, dynamic> data) {
    return Attachment(id: data['id'], file: data['file']);
  }

  AttachmentType get type {
    final ext = file.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return AttachmentType.image;
    } else if (['mp3', 'wav', 'aac', 'ogg'].contains(ext)) {
      return AttachmentType.audio;
    } else if (['mp4', 'avi', 'mkv', 'mov', 'flv'].contains(ext)) {
      return AttachmentType.video;
    } else if (['amr', 'opus'].contains(ext)) {
      return AttachmentType.voice;
    } else {
      return AttachmentType.document;
    }
  }

  @override
  String toString() {
    return file;
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  Future<FormData> getform() async {
    return FormData.fromMap({
      'file': await MultipartFile.fromFile(file, filename: fileName),
    });
  }
}
