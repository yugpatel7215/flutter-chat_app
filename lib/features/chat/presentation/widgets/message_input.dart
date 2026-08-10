import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final ValueChanged<String> onEdit;
  final MessageModel? editingMessage;
  final VoidCallback onCancelEdit;

  const MessageInput({
    super.key,
    required this.onSend,
    required this.onEdit,
    this.editingMessage,
    required this.onCancelEdit,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController(
      text: widget.editingMessage?.text ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldMessageId = oldWidget.editingMessage?.messageId;
    final newMessageId = widget.editingMessage?.messageId;

    // Editing started or changed to another message.
    if (oldMessageId != newMessageId) {
      if (widget.editingMessage != null) {
        _messageController.text = widget.editingMessage!.text;

        _messageController.selection = TextSelection.collapsed(
          offset: _messageController.text.length,
        );
      } else {
        // Editing cancelled/completed.
        _messageController.clear();
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    if (widget.editingMessage != null) {
      // Don't update Firestore if nothing actually changed.
      if (text == widget.editingMessage!.text.trim()) {
        widget.onCancelEdit();
        return;
      }

      widget.onEdit(text);
    } else {
      widget.onSend(text);
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingMessage != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: isEditing ? 'Edit message...' : 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  prefixIcon: isEditing
                      ? IconButton(
                          onPressed: widget.onCancelEdit,
                          icon: const Icon(Icons.close),
                          tooltip: 'Cancel edit',
                        )
                      : null,
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _submit,
              icon: Icon(isEditing ? Icons.check : Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
