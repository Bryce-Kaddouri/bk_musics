class Music {
  final String name;
  final String artist;
  final String genre;
  String title;
  final Future<String> downloadUrl; // Use Future<String> for download URL

  Music({
    required this.name,
    required this.artist,
    required this.genre,
    required this.title,
    required this.downloadUrl,
  });
}
