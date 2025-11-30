import 'dart:async';
import 'dart:io';
import 'package:chat_app/chat/data/models/attachement.model.dart';
import 'package:chat_app/chat/data/models/message.model.dart';
import 'package:chat_app/chat/data/models/recent_chat.model.dart';
import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/chat/domain/entities/create_room.entity.dart';
import 'package:chat_app/chat/presentation/bloc/controllers/chat_controller.dart';
import 'package:chat_app/chat/presentation/bloc/home/home_bloc.dart';
import 'package:chat_app/chat/presentation/pages/chat.dart';
import 'package:chat_app/core/bloc/base_bloc.dart';
import 'package:chat_app/core/theme/color_theme.dart';
import 'package:chat_app/core/theme/theme.dart';
import 'package:chat_app/core/utils/abc.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:chat_app/injections/injections_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends ConsumerStatefulWidget {
  final User user;
  static BuildContext? context;

  const HomePage({super.key, required this.user});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final StreamSubscription<List<Message>> messageListener;
  late TabController _tabController;
  late List<Widget> _floatingButtons;

  @override
  void initState() {
    // NOTE: Commented out Firebase & download logic for now — can be re-enabled later
    // final firestore = ref.read(firebaseFirestoreRepositoryProvider);
    // firestore.setActivityStatus(
    //   userId: widget.user.id,
    //   statusValue: UserActivityStatus.online.value,
    // );

    // messageListener = firestore.getChatStream(widget.user.id).listen(
    //   (messages) async {
    //     for (final message in messages) {
    //       message.status = MessageStatus.delivered;
    //       firestore.sendSystemMessage(
    //         message: SystemMessage(
    //           targetId: message.id,
    //           action: MessageAction.statusUpdate,
    //           update: MessageStatus.delivered.value,
    //         ),
    //         receiverId: message.senderId,
    //       );
    //
    //       if (message.attachment != null && message.attachment!.autoDownload) {
    //         DownloadService.download(
    //           taskId: message.id,
    //           url: message.attachment!.url,
    //           path: DeviceStorage.getMediaFilePath(
    //             message.attachment!.fileName,
    //           ),
    //           onDownloadComplete: (_) {},
    //           onDownloadError: () {},
    //         );
    //       }
    //     }
    //
    //     IsarDb.addMessages(messages);
    //   },
    // );

    // ref.read(pushNotificationsRepoProvider).init(
    //   onMessageOpenedApp: (message) async {
    //     await handleNotificationClick(message);
    //   },
    // );

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // final message = await FirebaseMessaging.instance.getInitialMessage();
      // if (message == null) return;
      //
      // await handleNotificationClick(message);
    });

    void handleTabIndexChange() {
      setState(() {});
      if (_tabController.index == 0) {
        ref.read(chatControllerProvider.notifier).getAdmins();
      } else if (_tabController.index == 1) {
        ref.read(chatControllerProvider.notifier).getSecondaryChats();
      }
    }

    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(handleTabIndexChange);

    _floatingButtons = [
      FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final _formKey = GlobalKey<FormState>();
              final TextEditingController _nameController =
                  TextEditingController();
              XFile? _pickedImage;

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text(
                      "اضافة محدث جديد",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    content: SizedBox(
                      width:
                          double.maxFinite, // Ensures full width on all devices
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name field
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: "الاسم *",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "الرجاء ادخال اسم المحدث";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Image picker
                            Center(
                              child: GestureDetector(
                                onTap: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (picked != null) {
                                    setState(() {
                                      _pickedImage = picked;
                                    });
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: _pickedImage != null
                                      ? FileImage(File(_pickedImage!.path))
                                      : null,
                                  child: _pickedImage == null
                                      ? const Icon(Icons.add_a_photo,
                                          size: 30, color: Colors.grey)
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("الغاء"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final name = _nameController.text.trim();

                            // Handle submission
                            ref
                                .read(chatControllerProvider.notifier)
                                .createRoom(CreateRoomEneity(
                                    name: name, image: _pickedImage?.path));

                            Navigator.of(context).pop(); // Close dialog
                          }
                        },
                        child: const Text("اضافة"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.chat),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: AppColorsDark.appBarColor,
            onPressed: () {},
            child: const Icon(Icons.edit),
          ),
          const SizedBox(
            height: 16.0,
          ),
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.camera_alt_rounded),
          ),
        ],
      ),
      FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_call),
      )
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).custom.textTheme;
    final colorTheme = Theme.of(context).custom.colorTheme;
    final chatState = ref.watch(chatControllerProvider);

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'مداولة',
              style: textTheme.titleLarge.copyWith(color: colorTheme.iconColor),
            ),
            actions: [
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(
              //     Icons.camera_alt_outlined,
              //   ),
              // ),
              // IconButtonz(
              //   onPressed: () {},
              //   icon: const Icon(
              //     Icons.search,
              //   ),
              // ),
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(
              //     Icons.more_vert,
              //   ),
              // ),
            ],
            bottom: AppUtils.user!.isAdmin
                ? TabBar(
                    controller: _tabController,
                    labelStyle: textTheme.labelLarge,
                    tabs: const [
                      Tab(
                        text: 'المحادثات',
                      ),
                      Tab(
                        text: 'المستنده اليك',
                      ),
                    ],
                  )
                : null,
          ),
          body: AppUtils.user!.isAdmin
              ? TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    RecentChatsBody(
                      user: widget.user,
                      chats: chatState.mainChats,
                    ),
                    RecentChatsBody(
                      user: widget.user,
                      chats: chatState.secondaryChats,
                    ),
                  ],
                )
              : RecentChatsBody(
                  user: widget.user,
                  chats: chatState.mainChats,
                ),
          floatingActionButton:
              AppUtils.user!.isAdmin ? null : _floatingButtons[0],
        ));
  }
}

// ✅ NEW: Show "لا يوجد رسائل" if no chats
class RecentChatsBody extends ConsumerWidget {
  const RecentChatsBody({super.key, required this.user, required this.chats});

  final User user;
  final List<RecentChat> chats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    if (chats.isEmpty) {
      return Center(
        child: Text(
          "لا يوجد رسائل",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorTheme.greyColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      );
    }

    return ListView(
      // Add top padding to replace the previous Padding
      padding: const EdgeInsets.only(top: 8.0),
      children: [
        // All chat items
        ...chats.map((chat) {
          String msgStatus = '';
          // if (chat.lastMessage?.message.user!.deviceId == user.deviceId) {
          //   // msgStatus = chat.lastMessage!.status.value;
          // }
          String msgContent = chat.lastMessage?.message.content ?? '';

          return RecentChatWidget(
            user: user,
            chat: chat,
            colorTheme: colorTheme,
            title: chat.name,
            msgStatus: msgStatus,
            msgContent: msgContent,
          );
        }),

        // Footer section (only if there are chats)
        if (chats.isNotEmpty) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(
                //   Icons.lock,
                //   size: 18,
                //   color: Theme.of(context).brightness == Brightness.light
                //       ? colorTheme.greyColor
                //       : colorTheme.iconColor,
                // ),
                // const SizedBox(width: 4),
                // RichText(
                //   textAlign: TextAlign.center,
                //   text: TextSpan(
                //     style: Theme.of(context).textTheme.bodySmall,
                //     children: [
                //       TextSpan(
                //         text: 'Your personal messages are ',
                //         style: TextStyle(color: colorTheme.greyColor),
                //       ),
                //       TextSpan(
                //         text: 'end-to-end encrypted',
                //         style: TextStyle(color: colorTheme.greenColor),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ]
      ],
    );
  }
}

// ⚠️ OLD VERSION — REMOVED TO AVOID DUPLICATION
// class RecentChatsBody extends ConsumerWidget {
//   const RecentChatsBody({super.key, required this.user, required this.chats});
//
//   final User user;
//   final List<RecentChat> chats;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final colorTheme = Theme.of(context).custom.colorTheme;
//     return ListView(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 8.0),
//           child: ListView.builder(
//             itemCount: chats.length,
//             shrinkWrap: true,
//             itemBuilder: (context, index) {
//               RecentChat chat = chats[index];
//               UserReadMessage? msg = chat.lastMessage;
//               String msgContent = chat.lastMessage?.message.content ?? '';
//               String msgStatus = '';
//
//               // if (msg.senderId == user.deviceId) {
//               //   msgStatus = msg.status.value;
//               // }
//               return RecentChatWidget(
//                 user: user,
//                 chat: chat,
//                 colorTheme: colorTheme,
//                 title: chat.name,
//                 msgStatus: msgStatus,
//                 msgContent: msgContent,
//               );
//             },
//           ),
//         ),
//         if (chats.isNotEmpty) ...[
//           const Divider(),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.lock,
//                   size: 18,
//                   color: Theme.of(context).brightness == Brightness.light
//                       ? colorTheme.greyColor
//                       : colorTheme.iconColor,
//                 ),
//                 const SizedBox(width: 4),
//                 RichText(
//                   textAlign: TextAlign.center,
//                   text: TextSpan(
//                     style: Theme.of(context).textTheme.bodySmall,
//                     children: [
//                       TextSpan(
//                         text: 'Your personal messages are ',
//                         style: TextStyle(color: colorTheme.greyColor),
//                       ),
//                       TextSpan(
//                         text: 'end-to-end encrypted',
//                         style: TextStyle(color: colorTheme.greenColor),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ]
//       ],
//     );
//   }
// }

class RecentChatWidget extends StatelessWidget {
  const RecentChatWidget({
    super.key,
    required this.user,
    required this.chat,
    required this.colorTheme,
    required this.title,
    required this.msgStatus,
    required this.msgContent,
  });

  final User user;
  final RecentChat chat;
  final ColorTheme colorTheme;
  final String title;
  final String msgStatus;
  final String msgContent;

  @override
  Widget build(BuildContext context) {
    final trailingChildren = [
      RecentChatTime(chat: chat, colorTheme: colorTheme),
      if (chat.numMessagesNotSeen > 0) ...[
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorTheme.greenColor,
          ),
          margin: const EdgeInsets.only(left: 4.0),
          padding: const EdgeInsets.all(6.0),
          child: Text(
            chat.numMessagesNotSeen.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    ];

    return ListTile(
      onTap: () {
        chat.numMessagesNotSeen = 0;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              self: user,
              chat: chat,
              other: chat.users != null && chat.users!.length > 1
                  ? chat.users!.lastWhere((u) => u.id != user.id)
                  : user,
              otherUserContactName: title,
              roomId: chat.id,
            ),
            settings: const RouteSettings(name: 'chat'),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 28.0,
        backgroundImage: CachedNetworkImageProvider(chat.image ?? ''),
      ),
      title: Text(
        title,
        style: Theme.of(context)
            .custom
            .textTheme
            .titleMedium
            .copyWith(color: colorTheme.textColor1),
      ),
      subtitle: Row(
        children: [
          if (msgStatus!.isNotEmpty) ...[
            Image.asset(
              'assets/images/$msgStatus.png',
              color: msgStatus != 'SEEN' ? colorTheme.textColor1 : null,
              width: 15.0,
            ),
            const SizedBox(
              width: 2.0,
            )
          ],
          if (chat.lastMessage?.message.attachment != null) ...[
            LayoutBuilder(
              builder: (context, _) {
                switch (chat.lastMessage?.message.attachment!.type) {
                  case AttachmentType.audio:
                    return const Icon(
                      Icons.audiotrack_rounded,
                      size: 20,
                    );

                  case AttachmentType.voice:
                    return const Icon(
                      Icons.mic,
                      size: 20,
                    );

                  case AttachmentType.image:
                    return const Icon(
                      Icons.image_rounded,
                      size: 20,
                    );

                  case AttachmentType.video:
                    return const Icon(
                      Icons.videocam_rounded,
                      size: 20,
                    );

                  default:
                    return const Icon(
                      Icons.file_copy,
                      size: 20,
                    );
                }
              },
            ),
            const SizedBox(
              width: 2.0,
            )
          ],
          Text(
              msgContent.length > 30
                  ? '${msgContent.substring(0, 30)}...'
                  : msgContent == "\u00A0" || msgContent.isEmpty
                      ? chat.lastMessage?.message.attachment?.type.value ?? ''
                      : msgContent,
              style: Theme.of(context).custom.textTheme.subtitle2)
        ],
      ),
      trailing: chat.numMessagesNotSeen > 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: trailingChildren,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: trailingChildren,
            ),
    );
  }
}

class RecentChatTime extends StatefulWidget {
  const RecentChatTime({
    super.key,
    required this.chat,
    required this.colorTheme,
  });

  final RecentChat chat;
  final ColorTheme colorTheme;

  @override
  State<RecentChatTime> createState() => _RecentChatTimeState();
}

class _RecentChatTimeState extends State<RecentChatTime> {
  late final Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formattedTimestamp(
        widget.chat.lastMessage?.message.createAt ?? DateTime.now(),
      ),
      style: Theme.of(context).custom.textTheme.caption.copyWith(
            color: widget.chat.numMessagesNotSeen > 0
                ? widget.colorTheme.greenColor
                : Theme.of(context).custom.colorTheme.greyColor,
          ),
    );
  }
}
