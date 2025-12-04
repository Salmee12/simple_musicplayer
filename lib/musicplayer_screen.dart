import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:simple_musicplayer/song.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();

  int currentIndex = 0;
  bool isPlaying = false;
  Duration currentPos = Duration.zero;
  Duration totalDuration = Duration.zero;

  final List<Song> playlist = [
    Song(
      title: "Oniket Prantor",
      artist: "Artcell",
      url: "https://samplelib.com/lib/preview/mp3/sample-3s.mp3",
      thumnailURL:
          "https://tse3.mm.bing.net/th/id/OIP.T6nYAeTgm5ldiJV0ONKbnQHaHa?rs=1&pid=ImgDetMain&o=7&rm=3",
      durationSeconds: 180,
    ),
    Song(
      title: "Tor Ekta Photo",
      artist: "Habib",
      url: "https://samplelib.com/lib/preview/mp3/sample-6s.mp3",
      thumnailURL:
          "https://tse3.mm.bing.net/th/id/OIP.T6nYAeTgm5ldiJV0ONKbnQHaHa?rs=1&pid=ImgDetMain&o=7&rm=3",
      durationSeconds: 200,
    ),
    Song(
      title: "Bondho Janala",
      artist: "Shironamhin",
      url: "https://samplelib.com/lib/preview/mp3/sample-12s.mp3",
      thumnailURL:
          "https://tse3.mm.bing.net/th/id/OIP.T6nYAeTgm5ldiJV0ONKbnQHaHa?rs=1&pid=ImgDetMain&o=7&rm=3",
      durationSeconds: 240,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _setupAudioPlayer();
    playSong(currentIndex);
  }

  void _setupAudioPlayer() {
    _player.onDurationChanged.listen((d) {
      setState(() => totalDuration = d);
    });

    _player.onPositionChanged.listen((p) {
      setState(() => currentPos = p);
    });

    _player.onPlayerComplete.listen((event) {
      nextSong(); // auto next
    });

    // Listen to player state changes
    _player.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  Future<void> playSong(int index) async {
    try {
      currentIndex = index;
      isPlaying = false;
      setState(() {
        currentPos = Duration.zero;
        totalDuration = Duration.zero; // Reset while loading
      });

      await _player.stop();
      await _player.play(UrlSource(playlist[index].url));

      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print('Error playing song: $e');
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play: ${e.toString()}')),
      );
    }
  }

  void togglePlayPause() async {
    try {
      if (isPlaying) {
        await _player.pause();
      } else {
        await _player.resume();
      }
      // State will be updated via onPlayerStateChanged listener
    } catch (e) {
      print('Error toggling play/pause: $e');
    }
  }

  void nextSong() async {
    int nextIndex = (currentIndex + 1) % playlist.length;
    await playSong(nextIndex);
  }

  Future<void> prevSong() async {
    int prevIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    await playSong(prevIndex);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = playlist[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Music Player")),
      body: Column(
        children: [
          // TOP PLAYER SECTION
          Container(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentSong.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentSong.artist,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 16),

                // Slider
                Slider(
                  value: currentPos.inSeconds.toDouble().clamp(
                    0,
                    totalDuration.inSeconds.toDouble(),
                  ),
                  min: 0,
                  max: totalDuration.inSeconds.toDouble() == 0
                      ? 1
                      : totalDuration.inSeconds.toDouble(),
                  onChanged: (value) {
                    //_player.seek(Duration(seconds: value.toInt()));
                  },
                ),

                // Time Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatTime(currentPos)),
                    Text(formatTime(totalDuration)),
                  ],
                ),

                const SizedBox(height: 16),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 38,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: prevSong,
                    ),
                    IconButton(
                      iconSize: 50,
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                      ),
                      onPressed: togglePlayPause,
                    ),
                    IconButton(
                      iconSize: 38,
                      icon: const Icon(Icons.skip_next),
                      onPressed: nextSong,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // SONG LIST
          Expanded(
            child: ListView.builder(
              itemCount: playlist.length,
              itemBuilder: (context, index) {
                final song = playlist[index];

                return ListTile(
                  leading: Text(
                    "${index + 1}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                  onTap: () => playSong(index),
                  selected: index == currentIndex,
                  selectedTileColor: Colors.blue.withOpacity(0.1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
