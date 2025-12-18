import 'dart:io';

import 'package:chat_app/chat/presentation/bloc/controllers/chat_controller.dart';
import 'package:chat_app/core/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'buttons.dart';

class AttachmentPicker extends ConsumerStatefulWidget {
  const AttachmentPicker({super.key});

  @override
  ConsumerState<AttachmentPicker> createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends ConsumerState<AttachmentPicker> {
  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Theme.of(context).brightness == Brightness.dark
              ? colorTheme.appBarColor
              : colorTheme.backgroundColor,
        ),
        child: GridView.count(
          crossAxisCount: 3,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            LabelledButton(
              onTap: () async {
                ref
                    .read(chatControllerProvider.notifier)
                    .pickDocuments(context);
              },
              backgroundColor: Colors.black87,
              label: 'Document',
              child: const Icon(
                CupertinoIcons.doc_fill,
                size: 35,
                color: Colors.blueAccent,
              ),
            ),
            LabelledButton(
              onTap: () async {
                ref
                    .read(chatControllerProvider.notifier)
                    .navigateToCameraView(context);
              },
              label: 'Camera',
              backgroundColor: Colors.black87,
              child: const Icon(
                CupertinoIcons.camera_fill,
                size: 35,
                color: Colors.white70,
              ),
            ),
            LabelledButton(
              onTap: () async {
                ref
                    .read(chatControllerProvider.notifier)
                    .pickAttachmentsFromGallery(context);
              },
              label: 'Gallery',
              backgroundColor: Colors.black87,
              child: const Icon(
                CupertinoIcons.photo_on_rectangle,
                size: 35,
                color: Colors.blueAccent,
              ),
            ),
            // if (Platform.isAndroid) ...[
            //   LabelledButton(
            //     onTap: () async {
            //       ref
            //           .read(chatControllerProvider.notifier)
            //           .pickAudioFiles(context);
            //     },
            //     label: 'Audio',
            //     backgroundColor: Colors.orange[900],
            //     child: const Icon(
            //       Icons.headphones_rounded,
            //       size: 28,
            //       color: Colors.white,
            //     ),
            //   )
            // ],
            // LabelledButton(
            //   onTap: () {
            //     if (!mounted) return;
            //     Navigator.pop(context);
            //   },
            //   label: 'Location',
            //   backgroundColor: Colors.green[600],
            //   child: const Icon(
            //     Icons.location_on,
            //     size: 28,
            //     color: Colors.white,
            //   ),
            // ),
            // LabelledButton(
            //   onTap: () {
            //     if (!mounted) return;
            //     Navigator.pop(context);
            //   },
            //   label: 'Payment',
            //   backgroundColor: Colors.teal[600],
            //   child: CircleAvatar(
            //     radius: 14,
            //     backgroundColor: Colors.white,
            //     child: Icon(
            //       Icons.currency_rupee_rounded,
            //       size: 18,
            //       color: Colors.teal[600],
            //     ),
            //   ),
            // ),
            // LabelledButton(
            //   onTap: () async {
            //     if (!mounted) return;
            //     Navigator.pop(context);
            //   },
            //   label: 'Contact',
            //   backgroundColor: Colors.blue[600],
            //   child: const Icon(
            //     Icons.person,
            //     size: 28,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
