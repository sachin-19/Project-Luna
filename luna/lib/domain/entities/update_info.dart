class UpdateInfo {
  const UpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.isMandatory,
    required this.minSupportedVersion,
  });

  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;
  final bool isMandatory;
  final String minSupportedVersion;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
        latestVersion: json['latest_version'] as String,
        downloadUrl: json['download_url'] as String,
        releaseNotes: json['release_notes'] as String? ?? '',
        isMandatory: json['mandatory'] as bool? ?? false,
        minSupportedVersion: json['min_supported_version'] as String? ?? '1.0.0',
      );
}
