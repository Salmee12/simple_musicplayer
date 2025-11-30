// song.dart
class Song {
  final String title;
  final String artist;
  final String url;
  final String thumnailURL;
  final int durationSeconds;



  const Song({
    required this.title,
    required this.artist,
    required this.url,
    required this.thumnailURL,
    required this.durationSeconds,
  });

  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }




}