import 'package:flutter/material.dart';

class ContohApi extends StatefulWidget {
  const ContohApi({Key? key}) : super(key: key);

  @override
  State<ContohApi> createState() => ChatMessageState();
}

class ChatMessageState extends State<ContohApi> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  String _username = 'Eben Hikaru';
  bool _isVoiceIcon = true;

  void _handleSubmitted(String text) {
    if (text.isNotEmpty) {
      _textController.clear();
      ChatMessage message = ChatMessage(
        username: _username,
        text: text,
        isMe: true,
      );
      setState(() {
        _messages.insert(0, message);
        _isVoiceIcon = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              child: Text(
                _username.isNotEmpty ? _username[0] : '',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(width: 10.0),
            Text(
              _username,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Colors.blue),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  setState(() {
                    _isVoiceIcon = text.isEmpty;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: 'Send a message'),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(
                  _isVoiceIcon ? Icons.mic : Icons.send,
                ),
                onPressed: () {
                  if (_isVoiceIcon) {
                    // Add logic for voice action here
                  } else {
                    if (_textController.text.isNotEmpty) {
                      _handleSubmitted(_textController.text);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String username;
  final String text;
  final bool isMe;

  ChatMessage({required this.username, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!isMe)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                child: Text(
                  username.isNotEmpty ? username[0] : '',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 12.0 : 0),
                  topRight: Radius.circular(isMe ? 0 : 12.0),
                  bottomLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
