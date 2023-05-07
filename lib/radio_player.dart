import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class RadioPlayer extends StatefulWidget {
  final String streamUrl;

  RadioPlayer({required this.streamUrl});

  @override
  _RadioPlayerState createState() => _RadioPlayerState();
}

class _RadioPlayerState extends State<RadioPlayer> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _play() async {
    await _audioPlayer.play(widget.streamUrl);
  }

  void _stop() async {
    await _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _play,
          child: Text("Play"),
        ),
        ElevatedButton(
          onPressed: _stop,
          child: Text("Stop"),
        ),
      ],
    );
  }
}
