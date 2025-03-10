import 'package:universal_io/io.dart';

Future<Socket?> connectToServer(String server, int port, Function(String) onResponse) async {
  try {
    final socket = await Socket.connect(server, port, timeout: const Duration(seconds: 5));

    // Buffer for handling multi-packet responses
    String buffer = '';

    socket.listen(
      (data) {
        buffer += String.fromCharCodes(data);

        // Check if response is complete (SIP2 messages often end with '\r' or '\n')
        if (buffer.contains('\r') || buffer.contains('\n')) {
          // Process response when it is complete
          onResponse(buffer.trim());
          buffer = ''; // Reset buffer for next message
        }
      },
      onError: (error) {
        onResponse('Socket Error: $error\n');
      },
      onDone: () {
        onResponse('Disconnected from server.\n');
      },
      cancelOnError: true,
    );

    return socket;
  } catch (e) {
    onResponse('Connection Error: $e\n');
    return null;
  }
}


void sendMessage(Socket socket, String message, Function(String) onResponse) {
  try {
    String formattedMessage = '$message\r\n'; // Ensure correct SIP2 termination
    socket.write(formattedMessage);
    onResponse('\n-->$formattedMessage');
  } catch (e) {
    onResponse('Error sending message: $e\n');
  }
}

