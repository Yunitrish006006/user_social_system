/// Localisation strings for [DmPage].
///
/// All fields have English defaults.
///
/// For existing `Map<String, String>` translation maps use the convenience
/// factory [DmStrings.fromMap].
class DmStrings {
  const DmStrings({
    this.noMessages = 'No messages yet, say Hi!',
    this.youRecalled = 'You recalled a message',
    this.theyRecalled = 'This message was recalled',
    this.sending = 'Sending...',
    this.recallTitle = 'Recall Message',
    this.recallConfirm =
        'Are you sure you want to recall this message? The other party will see "recalled".',
    this.cancel = 'Cancel',
    this.recall = 'Recall',
    this.inputHint = 'Type a message...',
    this.uploadTooltip = 'Upload history to server',
    this.downloadTooltip = 'Download history from server',
    this.syncTooltip = 'Sync from server',
    this.uploadSuccess =
        'Uploaded. Download on another device within 1 hour.',
    this.uploadFailed = 'Upload failed',
    this.syncSuccess = 'Chat history synced',
    this.downloadNoData =
        'No data available (upload from another device first)',
    this.downloadFailed = 'Download failed',
  });

  final String noMessages;
  final String youRecalled;
  final String theyRecalled;
  final String sending;
  final String recallTitle;
  final String recallConfirm;
  final String cancel;
  final String recall;
  final String inputHint;
  final String uploadTooltip;
  final String downloadTooltip;
  final String syncTooltip;
  final String uploadSuccess;
  final String uploadFailed;
  final String syncSuccess;
  final String downloadNoData;
  final String downloadFailed;

  /// Build from an existing `Map<String, String>` translation map.
  factory DmStrings.fromMap(Map<String, String> t) {
    String s(String key) => t[key] ?? key;
    return DmStrings(
      noMessages: s('No messages yet, say Hi!'),
      youRecalled: s('You recalled a message'),
      theyRecalled: s('This message was recalled'),
      sending: s('Sending...'),
      recallTitle: s('Recall Message'),
      recallConfirm: s(
        'Are you sure you want to recall this message? The other party will see "recalled".',
      ),
      cancel: s('Cancel'),
      recall: s('Recall'),
      inputHint: s('Type a message...'),
      uploadTooltip: s('Upload history to server'),
      downloadTooltip: s('Download history from server'),
      syncTooltip: s('Sync from server'),
      uploadSuccess: s('Uploaded. Download on another device within 1 hour.'),
      uploadFailed: s('Upload failed'),
      syncSuccess: s('Chat history synced'),
      downloadNoData: s(
        'No data available (upload from another device first)',
      ),
      downloadFailed: s('Download failed'),
    );
  }
}
