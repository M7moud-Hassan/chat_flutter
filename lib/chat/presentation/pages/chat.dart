import 'dart:async';
import 'dart:io';

import 'package:chat_app/chat/data/models/recent_chat.model.dart';
import 'package:chat_app/chat/data/repositories/websocket_repository.dart';
import 'package:chat_app/chat/presentation/bloc/categories/categories_bloc.dart';
import 'package:chat_app/chat/presentation/pages/categores_page.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:easy_localization/easy_localization.dart'
    show StringTranslateExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/chat/data/models/message.model.dart';
import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/chat/domain/entities/assign_to_entity.dart';
import 'package:chat_app/chat/presentation/bloc/controllers/chat_controller.dart';
import 'package:chat_app/chat/presentation/widgets/attachment_picker.dart';
import 'package:chat_app/chat/presentation/widgets/bottom_inset.dart';
import 'package:chat_app/chat/presentation/widgets/chat_date.dart';
import 'package:chat_app/chat/presentation/widgets/chat_field.dart';
import 'package:chat_app/chat/presentation/widgets/chat_mic.dart';
import 'package:chat_app/chat/presentation/widgets/emoji_picker.dart';
import 'package:chat_app/chat/presentation/widgets/message_cards.dart';
import 'package:chat_app/chat/presentation/widgets/scroll_btn.dart';
import 'package:chat_app/chat/presentation/widgets/unread_banner.dart';
import 'package:chat_app/chat/presentation/widgets/voice_recorder.dart';
import 'package:chat_app/core/theme/color_theme.dart';
import 'package:chat_app/core/theme/theme.dart';
import 'package:chat_app/core/utils/abc.dart';
import 'package:chat_app/core/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChatPage extends ConsumerStatefulWidget {
  final User self;
  final User other;
  final String otherUserContactName;
  final String roomId;
  final RecentChat chat;

  const ChatPage(
      {super.key,
      required this.self,
      required this.other,
      required this.otherUserContactName,
      required this.chat,
      required this.roomId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage>
    with WidgetsBindingObserver {
  bool _isDisposed = false; // Track disposal state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
    // ref.read(chatControllerProvider.notifier).getAdmins();
  }

  void _initializeChat() {
    // Only initialize if not disposed
    if (!_isDisposed) {
      ref.read(chatControllerProvider.notifier).initUsers(widget.self,
          widget.other, widget.otherUserContactName, widget.roomId);
    }
    CategoresPage.contextPage?.read<CategoriesBloc>().add(GetCategories());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Critical: Disconnect repository when app moves to background
    // This handles both app closing (when OS kills process) and backgrounding
    // Prevents resource leaks and unnecessary network connections
    if (state == AppLifecycleState.detached) {
      WebSocketRepository.disconnectAll();

      if (!_isDisposed) {
        ref.read(chatControllerProvider.notifier).disConnectRepo();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    // Critical: Disconnect repository when chat page is disposed
    // Handles user navigating back from chat screen
    // Ensures stream subscriptions are terminated and connection closed
    WebSocketRepository.disconnectAll();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container if disposed to prevent rendering after disposal
    if (_isDisposed) {
      return Container();
    }

    final self = widget.self;
    final other = widget.other;

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Platform.isAndroid
            ? PopScope(
                canPop: false,
                onPopInvoked: (didPop) async {
                  if (!ref.read(chatControllerProvider).showEmojiPicker) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }

                    return;
                  }

                  ref
                      .read(chatControllerProvider.notifier)
                      .setShowEmojiPicker(false);
                },
                child: _build(self, other, context),
              )
            : _build(self, other, context),
      ),
    );
  }

  Widget _build(User self, User other, BuildContext context) {
    final recordingState = ref.watch(
      chatControllerProvider.select((chatState) => chatState.recordingState),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          children: [
            CircleAvatar(
              maxRadius: 18,
              backgroundImage:
                  CachedNetworkImageProvider(widget.chat.image ?? ''),
            ),
            const SizedBox(
              width: 8.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserContactName,
                  style: Theme.of(context).custom.textTheme.titleMedium,
                ),
                StreamBuilder<UserActivityStatus>(
                  stream: null,
                  // stream: ref
                  //     .read(firebaseFirestoreRepositoryProvider)
                  //     .userActivityStatusStream(userId: other.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }

                    return snapshot.data!.value == 'Online'
                        ? Text(
                            'Online',
                            style: Theme.of(context).custom.textTheme.caption,
                          )
                        : Container();
                  },
                ),
              ],
            ),
          ],
        ),
        leadingWidth: 36.0,
        leading: IconButton(
          onPressed: () =>
              ref.read(chatControllerProvider.notifier).navigateToHome(context),
          icon: const Icon(
            CupertinoIcons.back,
            size: 24,
          ),
        ),
        actions: [
          // IconButton(
          //   onPressed:
          //       recordingState == RecordingState.notRecording ? () {} : null,
          //   icon: const Icon(
          //     Icons.videocam_rounded,
          //     size: 28,
          //     color: Colors.white,
          //   ),
          // ),
          // IconButton(
          //   onPressed:
          //       recordingState == RecordingState.notRecording ? () {} : null,
          //   icon: const Icon(
          //     Icons.call,
          //     color: Colors.white,
          //     size: 24,
          //   ),
          // ),
          if (AppUtils.user!.isAdmin)
            IconButton(
              onPressed: () async {
                final admins =
                    await ref.read(chatControllerProvider.notifier).getAdmins();

                // AwesomeDialog(
                //   context: context,
                //   dialogType: DialogType.info,
                //   animType: AnimType.bottomSlide,
                //   title: 'User Info',
                //   desc:
                //       'Name: ${other.deviceId}\nDevice ID: ${other.deviceId}\nActive: ${other.isActive ? "Yes" : "No"}\nCreated At: ${other.createdAt}\nLast Login: ${other.lastLogin ?? "N/A"}\nAdmin: ${other.isAdmin ? "Yes" : "No"}',
                //   btnOkOnPress: () {},
                // ).show();
                showPlatformDialog(
                  context: context,
                  builder: (_) => BasicDialogAlert(
                    title: const Text(
                      'اختر ادمن لاسناد المحدثة اليه',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    content: SizedBox(
                      height: 300, // Adjust height as needed
                      child: ListView(
                        shrinkWrap: true,
                        children: admins.map((admin) {
                          return ListTile(
                            onTap: () {
                              ref
                                  .read(chatControllerProvider.notifier)
                                  .assignTo(
                                    AssignToEntity(
                                      roomId: widget.roomId,
                                      adminId: admin.id.toString(),
                                    ),
                                  )
                                  .then((_) {
                                Navigator.of(context).pop();
                              });
                            },
                            title: Text(admin.name ?? ''),
                            subtitle:
                                Text('${'admin'.tr()}: ${admin.deviceId}'),
                          );
                        }).toList(),
                      ),
                    ),
                    actions: [
                      BasicDialogAction(
                        title: Text('close'.tr()),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(
                Icons.assignment_add,
                color: Colors.white,
                size: 26,
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Theme.of(context).themedImage('chat_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Platform.isIOS
                  ? GestureDetector(
                      onTap: () {
                        SystemChannels.textInput.invokeMethod(
                          "TextInput.hide",
                        );
                        ref
                            .read(chatControllerProvider.notifier)
                            .setShowEmojiPicker(false);
                      },
                      child: ChatStream(
                        chat: widget.chat,
                      ),
                    )
                  : ChatStream(
                      chat: widget.chat,
                    ),
            ),
            const SizedBox(
              height: 4.0,
            ),
            ChatInputContainer(
              self: self,
              other: other,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatInputContainer extends ConsumerStatefulWidget {
  const ChatInputContainer({
    super.key,
    required this.self,
    required this.other,
  });

  final User self;
  final User other;

  @override
  ConsumerState<ChatInputContainer> createState() => _ChatInputContainerState();
}

class _ChatInputContainerState extends ConsumerState<ChatInputContainer>
    with WidgetsBindingObserver {
  double keyboardHeight =
      SharedPref.instance.getDouble('keyboardHeight') ?? 300;
  bool isKeyboardVisible = false;
  late final StreamSubscription<bool> _keyboardSubscription;
  bool _isDisposed = false;

  @override
  void initState() {
    _isDisposed = false;
    ref.read(chatControllerProvider.notifier).initRecorder();
    _keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((isVisible) async {
      if (_isDisposed) return;

      isKeyboardVisible = isVisible;
      if (isVisible) {
        ref.read(chatControllerProvider.notifier).setShowEmojiPicker(false);
      }
      if (mounted) setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() async {
    _isDisposed = true;
    _keyboardSubscription.cancel();
    super.dispose();
  }

  void switchKeyboards() async {
    if (_isDisposed) return;

    final showEmojiPicker = ref.read(chatControllerProvider).showEmojiPicker;

    if (!showEmojiPicker && !isKeyboardVisible) {
      ref.read(chatControllerProvider.notifier).setShowEmojiPicker(true);
    } else if (showEmojiPicker) {
      ref.read(chatControllerProvider).fieldFocusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isDisposed || !mounted || showEmojiPicker) return;
        ref.read(chatControllerProvider.notifier).setShowEmojiPicker(false);
      });
    } else if (isKeyboardVisible) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      ref.read(chatControllerProvider.notifier).setShowEmojiPicker(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return Container();
    }

    final colorTheme = Theme.of(context).custom.colorTheme;
    final hideElements = ref.watch(
      chatControllerProvider.select((s) => s.hideElements),
    );
    final recordingState = ref.watch(
      chatControllerProvider.select((s) => s.recordingState),
    );
    final showEmojiPicker = ref.watch(
      chatControllerProvider.select((s) => s.showEmojiPicker),
    );

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(
            color: Theme.of(context).brightness == Brightness.light
                ? colorTheme.greyColor
                : colorTheme.iconColor),
      ),
      child: AvoidBottomInset(
        padding: EdgeInsets.only(bottom: Platform.isAndroid ? 4.0 : 24.0),
        conditions: [showEmojiPicker],
        offstage: Offstage(
          offstage: !showEmojiPicker,
          child: CustomEmojiPicker(
            afterEmojiPlaced: (emoji) => ref
                .read(chatControllerProvider.notifier)
                .onTextChanged(emoji.emoji),
            textController: ref.read(chatControllerProvider).messageController,
          ),
        ),
        child: recordingState != RecordingState.recordingLocked &&
                recordingState != RecordingState.paused
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? colorTheme.appBarColor
                              : colorTheme.backgroundColor,
                        ),
                        child: recordingState == RecordingState.notRecording
                            ? _buildChatField(
                                showEmojiPicker,
                                context,
                                hideElements,
                                colorTheme,
                              )
                            : const VoiceRecorderField(),
                      ),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    hideElements
                        ? InkWell(
                            onTap: () async {
                              if (_isDisposed) return;
                              ref
                                  .read(chatControllerProvider.notifier)
                                  .onSendBtnPressed(
                                    ref,
                                    widget.self,
                                    widget.other,
                                  );
                            },
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: colorTheme.greenColor,
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const ChatInputMic(),
                  ],
                ),
              )
            : const VoiceRecorder(),
      ),
    );
  }

  ChatField _buildChatField(bool showEmojiPicker, BuildContext context,
      bool hideElements, ColorTheme colorTheme) {
    return ChatField(
        leading: GestureDetector(
          onTap: switchKeyboards,
          child: Icon(
            !showEmojiPicker ? Icons.emoji_emotions : Icons.keyboard,
            size: 26.0,
          ),
        ),
        focusNode: ref.read(chatControllerProvider).fieldFocusNode,
        onTextChanged: (value) => {
              if (!_isDisposed)
                ref.read(chatControllerProvider.notifier).onTextChanged(value)
            },
        textController: ref.read(chatControllerProvider).messageController,
        actions: [
          if (AppUtils.user!.isAdmin)
            InkWell(
              onTap: () {
                if (_isDisposed) return;
                onAttachmentsIconPressed(
                  context,
                );
              },
              child: Transform.rotate(
                angle: -0.8,
                child: const Icon(
                  Icons.attach_file_rounded,
                  size: 26.0,
                ),
              ),
            ),
          if (!hideElements) ...[
            // InkWell(
            //   onTap: () {},
            //   child: Container(
            //     width: 21,
            //     height: 21,
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       color: Theme.of(context).brightness == Brightness.light
            //           ? colorTheme.greyColor
            //           : colorTheme.iconColor,
            //     ),
            //     child: Center(
            //       child: Text(
            //         '₹',
            //         textAlign: TextAlign.center,
            //         style: TextStyle(
            //           fontWeight: FontWeight.w500,
            //           fontSize: 16,
            //           color: Theme.of(context).brightness == Brightness.light
            //               ? colorTheme.backgroundColor
            //               : colorTheme.appBarColor,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // InkWell(
            //   onTap: () {
            //     ref
            //         .read(
            //           chatControllerProvider.notifier,
            //         )
            //         .navigateToCameraView(context);
            //   },
            //   child: const Icon(
            //     Icons.camera_alt_rounded,
            //     size: 24.0,
            //   ),
            // ),
          ],
        ]);
  }

  void onAttachmentsIconPressed(BuildContext context) {
    if (_isDisposed) return;

    final focusNode = ref.read(chatControllerProvider).fieldFocusNode;
    focusNode.unfocus();
    Future.delayed(
      Duration(
        milliseconds: MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 0,
      ),
      () async {
        if (_isDisposed || !mounted) return;
        showDialog(
          barrierColor: null,
          context: context,
          builder: (context) {
            return Dialog(
              alignment: Alignment.bottomCenter,
              insetPadding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: ref.read(chatControllerProvider).showEmojiPicker
                    ? 36.0
                    : 56.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 0,
              child: const Padding(
                padding: EdgeInsets.only(top: 24.0),
                child: AttachmentPicker(),
              ),
            );
          },
        );
      },
    );
  }
}

class ChatStream extends ConsumerStatefulWidget {
  const ChatStream({
    super.key,
    required this.chat,
  });

  final RecentChat chat;
  @override
  ConsumerState<ChatStream> createState() => _ChatStreamState();
}

class _ChatStreamState extends ConsumerState<ChatStream> {
  late final User self;
  late final User other;
  late final String chatId;
  late Stream<List<Message>> messageStream;
  late final ScrollController scrollController;
  bool _isDisposed = false;

  bool isInitialRender = true;
  // int unreadCount = 0;
  int prevMsgCount = 0;
  final bannerKey = GlobalKey();

  @override
  void initState() {
    _isDisposed = false;
    try {
      self = ref.read(chatControllerProvider.notifier).self;
      other = ref.read(chatControllerProvider.notifier).other;
      chatId = getChatId(self.id.toString(), other.id.toString());

      // The stream is provided by the repository which is managed by ChatPage
      // ChatPage will disconnect the repository when:
      // 1. User navigates back (in ChatPage.dispose)
      // 2. App moves to background (in ChatPage.didChangeAppLifecycleState)
      // This automatically closes the stream and cleans up subscriptions
      messageStream =
          ref.read(chatControllerProvider.notifier).wsRepo.messageStream;
      scrollController = ScrollController();
    } catch (e) {
      print("⚠️ Error initializing ChatStream: $e");
    }
    messageStream.listen((messages) {
      if (mounted && messages.isNotEmpty) {
        print("🟢 New messages received in ChatStream: ${messages.length}");
        widget.chat.lastMessage = messages.isNotEmpty
            ? UserReadMessage(
                id: messages.first.id,
                message: messages.first,
                isRead: true,
              )
            : null;
        ref.read(chatControllerProvider.notifier).updateChat(widget.chat);
      }
    });

    super.initState();
  }

  @override
  void dispose() async {
    _isDisposed = true;
    scrollController.dispose();

    // Ensure all resources are cleaned up
    try {
      // If needed, cancel stream subscription here
      // But StreamBuilder will automatically cancel when widget is disposed
    } catch (e) {
      print("⚠️ Error disposing ChatStream: $e");
    }

    super.dispose();
  }

  // void handleNewMessage(Message message) {
  //   if (_isDisposed) return;

  //   if ((message.user?.id ?? 0) == self.id) {
  //     // if (message.id == self.id) {
  //     unreadCount = 0;
  //     if (message.id == MessageStatus.pending) {
  //       // if (message.status == MessageStatus.pending) {
  //       scrollToBottom();
  //     }
  //   } else {
  //     unreadCount = unreadCount > 0 ? unreadCount + 1 : 0;
  //   }
  // }

  // void handleInitialData(int unreadMsgCount) {
  //   if (_isDisposed) return;

  //   isInitialRender = false;
  //   unreadCount = unreadMsgCount;

  //   if (unreadCount > 0) {
  //     scrollToUnreadBanner();
  //   }
  // }

  int updateUnreadCount(List<Message> messages) {
    if (_isDisposed) return 0;

    int unreadCount = 0;

    for (final message in messages) {
      if (message.user?.id == self.id) break;
      // if ((message.user?.id ?? 0) == self.id) break;
      if (message.id == MessageStatus.seen) break;
      // if (message.status == MessageStatus.seen) break;
      unreadCount++;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      ref.read(chatControllerProvider.notifier).setUnreadCount(unreadCount);
    });

    return unreadCount;
  }

  void scrollToUnreadBanner() {
    if (_isDisposed) return;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_isDisposed) return;
      try {
        Scrollable.ensureVisible(
          bannerKey.currentContext!,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      } catch (e) {
        print("⚠️ Error scrolling to unread banner: $e");
      }
    });
  }

  void scrollToBottom() {
    if (_isDisposed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      try {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } catch (e) {
        print("⚠️ Error scrolling to bottom: $e");
      }
    });
  }

  void markAsSeen(Message message) {
    if (_isDisposed) return;
    if (message.user?.id == self.id) return;
    // if (message.id == MessageStatus.seen) return;
    ref.read(chatControllerProvider.notifier).markMessageAsSeen(message);
  }

  int getMessageIndexByKey(Key key, List<Message> messages) {
    final messageKey = key as ValueKey;
    return messages.indexWhere((msg) => msg.id == messageKey.value);
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return Container();
    }

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = Theme.of(context).custom.colorTheme;

    return StreamBuilder<List<Message>>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (_isDisposed) {
          return Container();
        }

        if (!snapshot.hasData) {
          return Container();
        }

        final messages = snapshot.data!;

        // final unreadMsgCount = updateUnreadCount(messages);

        // if (isInitialRender) {
        //   handleInitialData(unreadMsgCount);
        // } else if (messages.length - prevMsgCount > 0) {
        //   handleNewMessage(messages.first);
        // }

        prevMsgCount = messages.length;
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(color: Colors.transparent),
            CustomScrollView(
              shrinkWrap: true,
              reverse: true,
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // if (unreadCount > 0) ...[
                //   SliverList.builder(
                //     itemCount: unreadCount,
                //     itemBuilder: (context, index) {
                //       return buildMessageCard(index, messages);
                //     },
                //     findChildIndexCallback: (key) {
                //       return getMessageIndexByKey(key, messages);
                //     },
                //   ),
                //   SliverToBoxAdapter(
                //     key: bannerKey,
                //     child: UnreadMessagesBanner(
                //       unreadCount: unreadCount,
                //     ),
                //   ),
                // ],
                SliverList.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    index = index;
                    return buildMessageCard(index, messages);
                  },
                  findChildIndexCallback: (key) {
                    return getMessageIndexByKey(key, messages);
                  },
                ),
                // SliverToBoxAdapter(
                //   child: Center(
                //     child: Container(
                //       width: MediaQuery.of(context).size.width * 0.8,
                //       margin: const EdgeInsets.only(bottom: 4),
                //       padding: const EdgeInsets.all(6),
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(12),
                //         color: isDarkTheme
                //             ? const Color.fromARGB(200, 24, 34, 40)
                //             : const Color.fromARGB(148, 248, 236, 130),
                //       ),
                //       child: Text(
                //         '🔒Messages and calls are end-to-end encrypted. No one outside this chat, not even ChatApp, can read or listen to them. Tap to learn more.',
                //         style: TextStyle(
                //           fontSize: 13,
                //           color: isDarkTheme
                //               ? colorTheme.yellowColor
                //               : colorTheme.textColor1,
                //         ),
                //         softWrap: true,
                //         textWidthBasis: TextWidthBasis.longestLine,
                //         textAlign: TextAlign.center,
                //       ),
                //     ),
                //   ),
                // ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ChatDate(
                      date: messages.isEmpty
                          ? 'Today'
                          : dateFromTimestamp(messages.last.createAt),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ScrollButton(scrollController: scrollController),
            )
          ],
        );
      },
    );
  }

  Widget buildMessageCard(int index, List<Message> messages) {
    if (_isDisposed) {
      return Container();
    }

    final message = messages[index];
    final isFirstMsg = index == messages.length - 1;
    final isSpecial =
        isFirstMsg || messages[index].user?.id != messages[index + 1].user?.id;
    final currMsgDate = dateFromTimestamp(messages[index].createAt);
    final showDate = isFirstMsg ||
        currMsgDate != dateFromTimestamp(messages[index + 1].createAt);

    return Column(
      key: ValueKey(message.id),
      children: [
        if (!isFirstMsg && showDate) ...[
          ChatDate(date: currMsgDate),
        ],
        VisibilityDetector(
          key: ValueKey('${message.id}_vd'),
          onVisibilityChanged: (info) {
            if (_isDisposed || info.visibleFraction < 0.1) return;
            markAsSeen(message);
          },
          child: MessageCard(
            message: message,
            currentUserId: self.id.toString(),
            special: isSpecial,
          ),
        ),
      ],
    );
  }
}
