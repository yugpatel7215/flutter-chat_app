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

    if (oldMessageId != newMessageId) {
      if (widget.editingMessage != null) {
        _messageController.text = widget.editingMessage!.text;

        _messageController.selection = TextSelection.collapsed(
          offset: _messageController.text.length,
        );
      } else {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isEditing = widget.editingMessage != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Editing message',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: widget.onCancelEdit,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: isEditing
                          ? 'Edit message...'
                          : 'Type a message...',

                      filled: true,

                      fillColor: colorScheme.surfaceContainerHighest,

                      prefixIcon: isEditing
                          ? Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: colorScheme.primary,
                            )
                          : null,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),

                const SizedBox(width: 8),

                Material(
                  color: colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _submit,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Icon(
                        isEditing ? Icons.check : Icons.send_rounded,
                        size: 21,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
