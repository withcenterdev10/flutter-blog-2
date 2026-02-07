import 'package:flutter/material.dart';

class CommentReply extends StatelessWidget {
  const CommentReply({super.key, required this.onClick});

  final void Function() onClick;

  @override
  build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: onClick,
      icon: Icon(Icons.reply, size: 18),
      label: Text(
        "Reply",
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
