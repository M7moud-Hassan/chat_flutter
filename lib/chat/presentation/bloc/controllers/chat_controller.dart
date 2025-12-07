import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:camera/camera.dart';
import 'package:chat_app/chat/data/datasources/chat_db.dart';
import 'package:chat_app/chat/data/models/attachement.model.dart';
import 'package:chat_app/chat/data/models/message.model.dart';
import 'package:chat_app/chat/data/models/pagination_model.dart';
import 'package:chat_app/chat/data/models/recent_chat.model.dart';
import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/chat/data/repositories/websocket_repository.dart';
import 'package:chat_app/chat/domain/entities/assign_to_entity.dart';
import 'package:chat_app/chat/domain/entities/create_room.entity.dart';
import 'package:chat_app/chat/domain/entities/message.entity.dart';
import 'package:chat_app/chat/domain/entities/messgae_pagination.dart';
import 'package:chat_app/chat/domain/usercases/add_attachment_use_case.dart';
import 'package:chat_app/chat/domain/usercases/create_room_use_case.dart';
import 'package:chat_app/chat/domain/usercases/get_admin_use_case.dart';
import 'package:chat_app/chat/domain/usercases/get_messages_use_case.dart';
import 'package:chat_app/chat/domain/usercases/get_rooms_use_case.dart';
import 'package:chat_app/chat/presentation/pages/attachment_sender.dart';
import 'package:chat_app/chat/presentation/widgets/camera.dart';
import 'package:chat_app/chat/presentation/widgets/gallery.dart';
import 'package:chat_app/core/theme/theme.dart';
import 'package:chat_app/core/utils/abc.dart';
import 'package:chat_app/core/utils/attachment_utils.dart';
import 'package:chat_app/injections/injections_main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

final chatControllerProvider =
    StateNotifierProvider.autoDispose<ChatStateNotifier, ChatState>(
  (ref) => ChatStateNotifier(ref: ref),
);

enum RecordingState {
  notRecording,
  recording,
  recordingLocked,
  paused,
}

class ChatState {
  ChatState({
    this.hideElements = false,
    this.recordingState = RecordingState.notRecording,
    this.showScrollBtn = false,
    this.unreadCount = 0,
    this.showEmojiPicker = false,
    required this.recordingSamples,
    required this.soundRecorder,
    required this.messageController,
    required this.fieldFocusNode,
    this.mainChats = const [],
    this.admins = const [],
    this.secondaryChats = const [],
  });

  final bool hideElements;
  final RecordingState recordingState;
  final TextEditingController messageController;
  final FocusNode fieldFocusNode;
  final FlutterSoundRecorder soundRecorder;
  final bool showScrollBtn;
  final int unreadCount;
  final List<RecordingDisposition> recordingSamples;
  final bool showEmojiPicker;
  final List<User> admins;
  final List<RecentChat> mainChats;
  final List<RecentChat> secondaryChats;

  void dispose() {
    fieldFocusNode.dispose();
    messageController.dispose();
    soundRecorder.closeRecorder();
  }

  ChatState copyWith({
    bool? hideElements,
    RecordingState? recordingState,
    bool? showScrollBtn,
    int? unreadCount,
    bool? showEmojiPicker,
    List<RecordingDisposition>? recordingSamples,
    List<RecentChat>? mainChats,
    List<User>? admins,
    List<RecentChat>? secondaryChats,
  }) {
    return ChatState(
      hideElements: hideElements ?? this.hideElements,
      recordingState: recordingState ?? this.recordingState,
      showScrollBtn: showScrollBtn ?? this.showScrollBtn,
      unreadCount: unreadCount ?? this.unreadCount,
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
      messageController: messageController,
      fieldFocusNode: fieldFocusNode,
      soundRecorder: soundRecorder,
      recordingSamples: recordingSamples ?? this.recordingSamples,
      mainChats: mainChats ?? this.mainChats,
      admins: admins ?? this.admins,
      secondaryChats: secondaryChats ?? this.secondaryChats,
    );
  }
}

class ChatStateNotifier extends StateNotifier<ChatState> {
  ChatStateNotifier({required this.ref})
      : _getMessagesUseCase = sl<GetMessagesUseCase>(),
        _addAttachmentUseCase = sl<AddAttachmentUseCase>(),
        _getAdmins = sl<GetAdminUseCase>(),
        _getRoomsUseCase = sl<GetRoomsUseCase>(),
        _chatDB = sl<ChatDB>(),
        _createRoomUSeCase = sl<CreateRoomUseCase>(),
        super(
          ChatState(
            messageController: TextEditingController(),
            fieldFocusNode: FocusNode(),
            soundRecorder: FlutterSoundRecorder(logLevel: Level.error),
            recordingSamples: [],
          ),
        ) {
    _initializeChats();
  }

  final GetMessagesUseCase _getMessagesUseCase;
  final GetRoomsUseCase _getRoomsUseCase;
  final CreateRoomUseCase _createRoomUSeCase;
  final ChatDB _chatDB;
  final AddAttachmentUseCase _addAttachmentUseCase;
  final GetAdminUseCase _getAdmins;
  final AutoDisposeStateNotifierProviderRef ref;
  late User self;
  late User other;
  late String otherUserContactName;
  late WebSocketRepository wsRepo;
  StreamSubscription<RecordingDisposition>? recordingStream;

  void createRoom(CreateRoomEneity entity) async {
    final chat = await _createRoomUSeCase(entity);
    chat.fold(
      (failure) {
        Logger().e('❌ Error creating room: $failure');
      },
      (createdChat) {
        Logger().i('✅ Room created with ID: ${createdChat.id}');
        addNewChat(createdChat);
      },
    );
  }

  void setMainChats(List<RecentChat> chats) {
    state = state.copyWith(mainChats: chats);
  }

  void setSecondaryChats(List<RecentChat> chats) {
    state = state.copyWith(secondaryChats: chats);
  }

  void addNewChat(RecentChat chat) {
    state.mainChats.removeWhere((c) => c.id == chat.id);
    state = state.copyWith(
      mainChats: [chat, ...state.mainChats],
    );
    if (state.secondaryChats.any((c) => c.id == chat.id)) {
      state.secondaryChats.removeWhere((c) => c.id == chat.id);
      state = state.copyWith(
        secondaryChats: [chat, ...state.secondaryChats],
      );
    }
  }

  void disConnectRepo() {
    wsRepo.disconnect();
  }

  void updateChat(RecentChat updatedChat) {
    final updatedList = state.mainChats.map((chat) {
      if (chat.id == updatedChat.id) return updatedChat;
      return chat;
    }).toList();
    final updatedList2 = state.secondaryChats.map((chat) {
      if (chat.id == updatedChat.id) return updatedChat;
      return chat;
    }).toList();

    state = state.copyWith(mainChats: updatedList);
    state = state.copyWith(secondaryChats: updatedList2);
  }

  Future<void> _initializeChats() async {
    // Fetch main chats (false parameter)
    final mainResult = await _getRoomsUseCase(false);
    // Check if state notifier is still mounted before updating state
    if (!mounted) return;
    mainResult.fold(
        (l) => {},
        (r) =>
            state = state.copyWith(mainChats: r.results) // Replace entire list
        );

    final secondaryResult = await _getRoomsUseCase(true);
    if (!mounted) return;
    secondaryResult.fold(
        (l) => {},
        (r) => state =
            state.copyWith(secondaryChats: r.results) // Replace entire list
        );
  }

  void getAdmins() {
    _getAdmins.call().then((result) {
      result.fold(
        (failure) {
          print('❌ Error loading admins: $failure'); // 🔴 Log the error!
        },
        (success) {
          print("✅ Loaded ${success.length} admins");
          state = state.copyWith(admins: success);
        },
      );
    }).catchError((error, stack) {
      print('💥 Unhandled error in _getAdmins: $error');
      print(stack);
    });
  }

  getMainChats() async {
    final mainResult = await _getRoomsUseCase(false);
    // Check if state notifier is still mounted before updating state
    if (!mounted) return;
    mainResult.fold(
        (l) => {},
        (r) =>
            state = state.copyWith(mainChats: r.results) // Replace entire list
        );
  }

  getSecondaryChats() async {
    final secondaryResult = await _getRoomsUseCase(true);
    if (!mounted) return;
    secondaryResult.fold(
        (l) => {},
        (r) => state =
            state.copyWith(secondaryChats: r.results) // Replace entire list
        );
  }

  void initUsers(
      User self, User other, String otherUserContactName, String roomId) async {
    this.self = self;
    this.other = other;
    this.otherUserContactName = otherUserContactName;
    wsRepo = WebSocketRepository('wss://app.modoalah.cloud/ws/chat/$roomId/');
    wsRepo.connect();

    _getMessagesUseCase(
      MessgaePagination(roomId: roomId, sizePage: 10000, page: 1),
    ).then((result) {
      result.fold(
        (failure) {
          print('❌ Error loading messages: $failure'); // 🔴 Log the error!
        },
        (success) {
          print("✅ Loaded ${success.results.length} messages");
          print("Total count: ${success.count}");
          List<Message> message = [];
          success.results
              .forEach((userMessage) => message.add(userMessage.message));
          wsRepo.addLocalMessage(message); // Ensure this accepts List<Message>
        },
      );
    }).catchError((error, stack) {
      print('💥 Unhandled error in _getMessagesUseCase: $error');
      print(stack);
    });
  }

  Future<void> assignTo(AssignToEntity entity) async {
    await _chatDB.assignChat(entity);
  }

  Future<Attachment> addAttachment(
      Attachment attachment, String msgContent) async {
    final result = await _addAttachmentUseCase(attachment);
    attachment = result.fold(
      (failure) => throw Exception(failure.message),
      (attachment) => attachment,
    );
    sendMessageNoAttachments(
        MessageEntity(message: msgContent, attachment: attachment.id));
    return attachment;
  }

  Future<void> initRecorder() async {
    await state.soundRecorder.openRecorder();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    state.soundRecorder.setSubscriptionDuration(
      const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  void navigateToHome(BuildContext context) {
    Navigator.pop(context);
  }

  void setRecordingState(RecordingState recordingState) {
    state = state.copyWith(recordingState: recordingState);
  }

  Future<void> pauseRecording() async {
    await state.soundRecorder.pauseRecorder();
    setRecordingState(RecordingState.paused);
  }

  Future<void> resumeRecording() async {
    await state.soundRecorder.resumeRecorder();
    setRecordingState(RecordingState.recordingLocked);
  }

  Future<void> cancelRecording() async {
    await state.soundRecorder.stopRecorder();
    recordingStream?.cancel();
    recordingStream = null;
    state = state.copyWith(
      recordingSamples: [],
      recordingState: RecordingState.notRecording,
    );
  }

  Future<void> startRecording() async {
    if (!await hasPerm(Permission.microphoneission)) return;
    await state.soundRecorder.startRecorder(
      codec: Codec.aacADTS,
      sampleRate: 44100,
      bitRate: 48000,
      toFile: "voice.aac",
    );

    recordingStream = state.soundRecorder.onProgress!.listen(
      recordingListener,
    );
    setRecordingState(RecordingState.recording);
  }

  void recordingListener(RecordingDisposition data) {
    state = state.copyWith(
      recordingSamples: state.recordingSamples..add(data),
    );
  }

  Future<void> onMicDragLeft(double dx, double deviceWidth) async {
    if (dx > deviceWidth * 0.6) return;

    await state.soundRecorder.stopRecorder();
    setRecordingState(RecordingState.notRecording);
  }

  Future<void> onMicDragUp(double dy, double deviceHeight) async {
    if (dy > deviceHeight - 100 ||
        state.recordingState == RecordingState.recordingLocked) return;

    setRecordingState(RecordingState.recordingLocked);
  }

  Future<void> onRecordingDone() async {
    final path = await state.soundRecorder.stopRecorder();
    recordingStream?.cancel();
    recordingStream = null;

    final samples = state.recordingSamples.map((e) => e.decibels ?? 0).toList();

    state = state.copyWith(
      recordingSamples: [],
      recordingState: RecordingState.notRecording,
    );

    final recordedFile = File(path!);
    final messageId = const Uuid().v4();
    // final timestamp = Timestamp.now();
    final ext = path.split(".").last;
    final fileName = "AUD_${DateTime.now().microsecond}.$ext";

    // await recordedFile.copy(
    //   DeviceStorage.getMediaFilePath(fileName),
    // );

    final senderId = ref.read(chatControllerProvider.notifier).self.id;
    final receiverId = ref.read(chatControllerProvider.notifier).other.id;

    ref.read(chatControllerProvider.notifier).addAttachment(
        Attachment(
            id: 1,
            file: recordedFile.path,
            fileName: fileName,
            uploadStatus: UploadStatus.uploading),
        '');

    // ref.read(chatControllerProvider.notifier).sendMessageWithAttachments(
    //       Message(
    //         id: messageId,
    //         content: "",
    //         status: MessageStatus.pending,
    //         senderId: senderId,
    //         receiverId: receiverId,
    //         timestamp: timestamp,
    //         attachment: Attachment(
    //           type: AttachmentType.voice,
    //           url: "",
    //           fileName: fileName,
    //           fileSize: recordedFile.lengthSync(),
    //           fileExtension: ext,
    //           uploadStatus: UploadStatus.uploading,
    //           autoDownload: true,
    //           file: recordedFile,
    //           samples: samples,
    //         ),
    //       ),
    //     );
  }

  void onTextChanged(String value) {
    if (value.isEmpty) {
      state = state.copyWith(hideElements: false);
    } else if (value != ' ') {
      state = state.copyWith(hideElements: true);
    } else {
      state.messageController.text = "";
    }
  }

  void toggleScrollBtnVisibility() {
    state = state.copyWith(showScrollBtn: !state.showScrollBtn);
  }

  void setUnreadCount(int count) {
    if (state.unreadCount == count) return;
    state = state.copyWith(unreadCount: count);
  }

  void setShowEmojiPicker(bool shouldShowEmojiPicker) {
    state = state.copyWith(showEmojiPicker: shouldShowEmojiPicker);
  }

  void onSendBtnPressed(WidgetRef ref, User sender, User receiver) async {
    sendMessageNoAttachments(
      MessageEntity(
          // id: const Uuid().v4(),
          // content: state.messageController.text.trim(),
          // status: MessageStatus.pending,
          message: state.messageController.text.trim(),
          attachment: null
          // senderId: sender.id,
          // receiverId: receiver.id,
          ),
    );

    state.messageController.text = "";
    state = state.copyWith(
      hideElements: false,
    );
  }

  Future<void> sendMessageNoAttachments(MessageEntity message) async {
    // await IsarDb.addMessage(message);

    // Delay for smooth animation
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   ref
    //       .read(firebaseFirestoreRepositoryProvider)
    //       .sendMessage(message..status = MessageStatus.sent)
    //       .then((_) {
    //     IsarDb.updateMessage(message.id, status: message.status);
    //     ref.read(pushNotificationsRepoProvider).sendPushNotification(message);
    //   });
    // });

    wsRepo.sendMessage(message);
  }

  void sendMessageWithAttachments(Message message) async {
    if ({
      AttachmentType.document,
      AttachmentType.audio,
      AttachmentType.voice,
      AttachmentType.video
    }.contains(message.attachment!.type)) {
      // message.attachment!.uploadStatus = UploadStatus.preparing;
      // await IsarDb.addMessage(message);

      // message.attachment!.uploadStatus = UploadStatus.uploading;
      // await uploadAttachment(message);
      // await IsarDb.updateMessage(message.id, attachment: message.attachment);
      return;
    }

    // message.attachment!.uploadStatus = UploadStatus.preparing;
    // await IsarDb.addMessage(message);

    await compressAttachment(message);
    await uploadAttachment(message);
  }

  Future<void> uploadAttachment(Message message) async {
    // await UploadService.upload(
    //   taskId: message.id,
    //   file: message.attachment!.file!,
    //   path: 'attachments/${message.attachment!.fileName}',
    //   onUploadDone: (snapshot) async =>
    //       await uploadCompleteHandler(snapshot, message),
    //   onUploadError: () async => await stopUpload(message),
    // );

    // message.attachment!.uploadStatus = UploadStatus.uploading;
    // await IsarDb.updateMessage(message.id, attachment: message.attachment);
  }

  Future<void> uploadCompleteHandler(
    // TaskSnapshot snapshot,
    String snapshot,
    Message message,
  ) async {
    // final url = await snapshot.ref.getDownloadURL();

    // ref
    //     .read(firebaseFirestoreRepositoryProvider)
    //     .sendMessage(
    //       message
    //         ..status = MessageStatus.sent
    //         ..attachment!.url = url
    //         ..attachment!.uploadStatus = UploadStatus.uploaded,
    //     )
    //     .then((_) async {
    //   await IsarDb.updateMessage(
    //     message.id,
    //     status: message.status,
    //     attachment: message.attachment!
    //       ..url = url
    //       ..uploadStatus = UploadStatus.uploaded,
    //   );

    //   ref.read(pushNotificationsRepoProvider).sendPushNotification(message);
    // });
  }

  Future<void> stopUpload(Message message) async {
    // if (message.attachment!.uploadStatus == UploadStatus.notUploading) {
    //   return;
    // }

    // await UploadService.cancelUpload(message.id);
    // await IsarDb.updateMessage(
    //   message.id,
    //   attachment: message.attachment!..uploadStatus = UploadStatus.notUploading,
    // );
  }

  Future<void> downloadAttachment(
    Message message,
    // void Function(TaskSnapshot) onComplete,
    void Function(String) onComplete,
    void Function() onError,
  ) async {
    // await DownloadService.download(
    //   taskId: message.id,
    //   url: message.attachment!.url,
    //   path: DeviceStorage.getMediaFilePath(message.attachment!.fileName),
    //   onDownloadComplete: onComplete,
    //   onDownloadError: onError,
    // );
  }

  Future<void> cancelDownload(Message message) async {
    // await DownloadService.cancelDownload(message.id);
  }

  Future<void> compressAttachment(Message message) async {
    // final compressedFile = await CompressionService.compressImage(
    //   message.attachment!.file!,
    // );

    // await compressedFile.copy(
    //   DeviceStorage.getMediaFilePath(
    //     message.attachment!.fileName,
    //   ),
    // );

    // message.attachment!.file = compressedFile;
    // message.attachment!.fileSize = await compressedFile.length();
    // message.attachment!.fileExtension = compressedFile.path.split('.').last;
  }

  Future<void> markMessageAsSeen(Message message) async {
    // ref
    //     .read(firebaseFirestoreRepositoryProvider)
    //     .sendSystemMessage(
    //       message: SystemMessage(
    //         targetId: message.id,
    //         action: MessageAction.statusUpdate,
    //         update: MessageStatus.seen.value,
    //       ),
    //       receiverId: message.senderId,
    //     )
    //     .then((value) {
    //   IsarDb.updateMessage(message.id, status: MessageStatus.seen);
    // });
  }

  Future<void> navigateToCameraView(BuildContext context) async {
    final cameras = await availableCameras();
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CameraView(cameras: cameras)),
    );
  }

  Future<List<Attachment>?> pickAttachmentsFromGallery(
    BuildContext context, {
    bool returnAttachments = false,
  }) async {
    if (Platform.isAndroid &&
        (!await hasPermission(Permission.storage)) &&
        (!await hasPermission(Permission.photos))) {
      return null;
    }

    if (!context.mounted) return null;

    if (Platform.isAndroid) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Gallery(
            title: 'Send to $otherUserContactName',
          ),
        ),
      );
      return null;
    }

    final key = showLoading(context);

    List<File>? files = await pickMultimedia();
    if (files == null) {
      Navigator.pop(key.currentContext!);
      return null;
    }

    final attachments = createAttachmentsFromFiles(files);
    if (returnAttachments) {
      Navigator.pop(key.currentContext!);
      return attachments;
    }

    if (!mounted) return null;
    Navigator.pop(key.currentContext!);
    navigateToAttachmentSender(context, attachments);
    return null;
  }

  Future<void> pickAudioFiles(
    BuildContext context,
  ) async {
    final key = showLoading(context);

    // List<File>? files = await pickFiles(type: FileType.audio);
    // if (files == null) {
    //   Navigator.pop(key.currentContext!);
    //   return;
    // }

    // final attachments = createAttachmentsFromFiles(files);

    // if (!mounted) return;
    // Navigator.pop(key.currentContext!);
    // navigateToAttachmentSender(context, attachments);
  }

  Future<List<Attachment>?> pickDocuments(
    BuildContext context, {
    bool returnAttachments = false,
  }) async {
    final key = showLoading(context);

    List<File>? files = await pickFiles(type: FileType.any);
    if (files == null) {
      Navigator.pop(key.currentContext!);
      return null;
    }

    final attachments = createAttachmentsFromFiles(
      files,
      areDocuments: true,
    );

    if (returnAttachments) {
      Navigator.pop(key.currentContext!);
      return attachments;
    }

    if (!mounted) return null;
    Navigator.pop(key.currentContext!);
    navigateToAttachmentSender(context, attachments);
    return null;
  }

  GlobalKey showLoading(context) {
    final dialogKey = GlobalKey();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          key: dialogKey,
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Text(
                'Preparing media',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).custom.colorTheme.textColor2,
                ),
              ),
            ],
          ),
        );
      },
    );

    return dialogKey;
  }

  Future<List<Attachment>> createAttachmentsFromFiles(
    List<File> files, {
    bool areDocuments = false,
  }) async {
    print("Creating attachments from files");
    print(areDocuments);
    return await Future.wait(
      files.map((file) async {
        final type = areDocuments
            ? AttachmentType.document
            : AttachmentType.fromValue(
                lookupMimeType(file.path)?.split("/")[0].toUpperCase() ??
                    'DOCUMENT',
              );

        double? width, height;
        if (type == AttachmentType.image) {
          (width, height) = await getImageDimensions(File(file.path));
        } else if (type == AttachmentType.video) {
          print("video");
          print(AttachmentType.video);
          (width, height) = await getVideoDimensions(File(file.path));
        }

        final fileName = file.path.split("/").last;

        return Attachment(id: 1, file: file.path);
      }),
    );
  }

  void navigateToAttachmentSender(
    BuildContext context,
    Future<List<Attachment>> attachments,
  ) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AttachmentMessageSender(
          attachmentsFuture: attachments,
        ),
      ),
    );
  }
}
