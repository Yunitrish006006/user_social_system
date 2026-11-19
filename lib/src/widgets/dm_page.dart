import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/dm_strings.dart';
import '../models/chat_message.dart';
import '../services/dm_service.dart';

/// A full-page DM chat screen backed by a [DmService].
///
/// Handles message display, sending, recall, and cross-device sync.
///
/// [onActiveConversationChanged] is called with [friendId] on open and
/// with `null` on close — use this to suppress push-notification badges.
///
/// ```dart
/// DmPage(
///   service: myDmService,
///   friendId: 42,
///   friendName: 'Alice',
///   currentUserId: 1,
///   strings: DmStrings.fromMap(translationMap),
///   onActiveConversationChanged: notificationService.setActiveConversation,
/// )
/// ```
class DmPage extends StatefulWidget {
  const DmPage({
    super.key,
    required this.service,
    required this.friendId,
    required this.friendName,
    required this.currentUserId,
    this.strings = const DmStrings(),
    this.onActiveConversationChanged,
  });

  final DmService service;
  final int friendId;
  final String friendName;
  final int currentUserId;
  final DmStrings strings;

  /// Called with [friendId] when the page opens and `null` when it closes.
  final void Function(int? friendId)? onActiveConversationChanged;

  @override
  State<DmPage> createState() => _DmPageState();
}

class _DmPageState extends State<DmPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<ChatMessage>? _subscription;
  bool _loading = true;
  bool _syncing = false;
  bool _uploading = false;
  bool _downloading = false;
  String? _error;

  DmStrings get _s => widget.strings;

  @override
  void initState() {
    super.initState();
    widget.onActiveConversationChanged?.call(widget.friendId);
    _loadHistory();
    widget.service.connectToDm(
      widget.currentUserId,
      widget.friendId,
      isCaller: true,
    );
    _subscription = widget.service.messageStream.listen((msg) {
      setState(() {
        int idx = -1;
        if (msg.pendingId != null) {
          idx = _messages.indexWhere((m) => m.pendingId == msg.pendingId);
        }
        if (idx < 0) {
          final key = '${msg.createdAt}_${msg.senderId}';
          idx = _messages.indexWhere(
            (m) => '${m.createdAt}_${m.senderId}' == key,
          );
        }
        if (idx >= 0) {
          _messages[idx] = msg;
        } else {
          _messages.add(msg);
        }
      });
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget.onActiveConversationChanged?.call(null);
    widget.service.disconnect();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── data ───────────────────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    try {
      final history = await widget.service.fetchHistory(
        widget.currentUserId,
        widget.friendId,
      );
      setState(() {
        _messages.addAll(history);
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _syncFromServer() async {
    setState(() => _syncing = true);
    try {
      final history = await widget.service.syncFromServer(
        widget.currentUserId,
        widget.friendId,
      );
      setState(() {
        _messages
          ..clear()
          ..addAll(history);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _uploadSync() async {
    setState(() => _uploading = true);
    try {
      await widget.service.uploadSyncData(
        widget.currentUserId,
        widget.friendId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_s.uploadSuccess)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_s.uploadFailed)));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _downloadSync() async {
    setState(() => _downloading = true);
    try {
      await widget.service.downloadAndMergeSyncData(widget.friendId);
      final history = await widget.service.syncFromServer(
        widget.currentUserId,
        widget.friendId,
      );
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(history);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_s.syncSuccess)));
    } catch (e) {
      if (!mounted) return;
      final msg =
          e.toString().contains('No data') || e.toString().contains('404')
          ? _s.downloadNoData
          : _s.downloadFailed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    await widget.service.sendMessage(widget.friendId, text);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
        actions: [
          IconButton(
            icon: _uploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload),
            tooltip: _s.uploadTooltip,
            onPressed:
                (_uploading || _downloading || _syncing) ? null : _uploadSync,
          ),
          IconButton(
            icon: _downloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            tooltip: _s.downloadTooltip,
            onPressed:
                (_uploading || _downloading || _syncing)
                ? null
                : _downloadSync,
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: _s.syncTooltip,
            onPressed: _syncing ? null : _syncFromServer,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_messages.isEmpty) {
      return Center(child: Text(_s.noMessages));
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _buildBubble(_messages[index]),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isMine = msg.senderId == widget.currentUserId;

    if (msg.isRecalled) {
      return Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            isMine ? _s.youRecalled : _s.theyRecalled,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: isMine
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            msg.text,
            style: TextStyle(
              color: isMine
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (isMine && msg.isPending)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _s.sending,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );

    if (!isMine) return Align(alignment: Alignment.centerLeft, child: bubble);

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onLongPress: () => _confirmRecall(msg),
        child: bubble,
      ),
    );
  }

  Future<void> _confirmRecall(ChatMessage msg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_s.recallTitle),
        content: Text(_s.recallConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_s.recall),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.service.recallMessage(msg);
    }
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: _s.inputHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
