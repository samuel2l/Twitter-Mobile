import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../network/api_client.dart';
import '../../utils/constants/api_constants.dart';
import 'realtime_message.dart';

typedef WebSocketFactory = WebSocketChannel Function(
  Uri uri, {
  Map<String, dynamic>? headers,
});

class RealtimeClient {
  RealtimeClient({
    required ApiClient apiClient,
    WebSocketFactory? connect,
  })  : _apiClient = apiClient,
        _connect = connect ??
            ((uri, {headers}) => IOWebSocketChannel.connect(
                  uri,
                  headers: headers,
                ));

  final ApiClient _apiClient;
  final WebSocketFactory _connect;

  final _controller = StreamController<RealtimeMessage>.broadcast();
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _shouldRun = false;
  int _attempt = 0;

  Stream<RealtimeMessage> get messages => _controller.stream;

  bool get isConnected => _channel != null;

  Future<void> start() async {
    _shouldRun = true;
    await _open();
  }

  Future<void> stop() async {
    _shouldRun = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _closeSocket();
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  Future<void> _open() async {
    if (!_shouldRun) return;

    await _closeSocket();

    final uri = Uri.parse(ApiConstants.websocketUrl);
    final cookieHeader = await _apiClient.cookieHeaderFor(uri);
    final headers = <String, dynamic>{
      if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
    };

    try {
      final channel = _connect(uri, headers: headers);
      _channel = channel;
      _attempt = 0;

      _subscription = channel.stream.listen(
        _onData,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onData(dynamic data) {
    try {
      final decoded = jsonDecode(data as String);
      if (decoded is Map<String, dynamic>) {
        _controller.add(RealtimeMessage.fromJson(decoded));
      }
    } catch (_) {
      // Ignore malformed frames.
    }
  }

  void _scheduleReconnect() {
    _channel = null;
    _subscription = null;

    if (!_shouldRun || _controller.isClosed) return;

    _reconnectTimer?.cancel();
    final delaySeconds = (1 << _attempt.clamp(0, 5)).clamp(1, 30);
    _attempt += 1;

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      unawaited(_open());
    });
  }

  Future<void> _closeSocket() async {
    await _subscription?.cancel();
    _subscription = null;

    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }
}
