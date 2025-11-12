import 'dart:async';
import 'dart:convert';
import 'package:chat_app/chat/data/models/message.model.dart';
import 'package:chat_app/chat/domain/entities/message.entity.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketRepository {
  static final List<WebSocketRepository> _instances = [];

  late IOWebSocketChannel _channel;
  final String _url;
  final StreamController<List<Message>> _messageController =
      StreamController.broadcast();
  final List<Message> _messages = [];

  Stream<List<Message>> get messageStream => _messageController.stream;

  WebSocketRepository(this._url) {
    _instances.add(this);
  }

  Future<void> connect() async {
    try {
      _channel = IOWebSocketChannel.connect(
        _url,
        protocols: ['token-${AppUtils.user?.access?.token}'],
      );
      _channel.stream.listen(
        (data) {
          final json = jsonDecode(data);
          print(data);
          final message = Message.fromMap(json['message']);
          _messages.insert(0, message);
          _messageController.add(List.unmodifiable(_messages));
        },
        onError: (error) {
          _messageController.addError(error);
        },
        onDone: () {
          _messageController.close();
        },
      );
    } catch (e) {
      _messageController.addError(e);
    }
  }

  void addLocalMessage(List<Message> messages) {
    _messages.addAll(messages);
    _messageController.add(messages);
  }

  void sendMessage(MessageEntity message) {
    _channel.sink.add(jsonEncode(message.toJson()));
  }

  void disconnect() {
    try {
      _channel.sink.close();
    } catch (_) {}
    try {
      _messageController.close();
    } catch (_) {}
  }

  /// 🔒 Disconnect all WebSocket connections globally
  static void disconnectAll() {
    for (final instance in _instances) {
      instance.disconnect();
    }
    _instances.clear();
  }
}
