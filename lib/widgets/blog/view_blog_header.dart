import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/blog_user_model.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/edit_blog_screen.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:flutter_blog_2/widgets/avatar.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewBlogHeader extends StatelessWidget {
  const ViewBlogHeader({super.key, required this.showDeleteDialog});
  final void Function() showDeleteDialog;

  @override
  Widget build(BuildContext context) {
    final userAuthenticated = context.select<AuthProvider, User?>(
      (p) => p.getState.user,
    );
    final (:blogUser, :createdAt) = context
        .select<BlogProvider, ({BlogUserModel? blogUser, String? createdAt})>(
          (p) => (blogUser: p.blog.user, createdAt: p.blog.createdAt),
        );

    bool isDesktop = MediaQuery.of(context).size.width >= 900;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (blogUser != null)
            Avatar(
              profileImage: blogUser.imageUrl,
              displayName: blogUser.displayName!,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                if (blogUser != null)
                  Text(
                    toUpperCaseFirstChar(blogUser.displayName!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                if (createdAt != null)
                  Text(
                    timeAgo(createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (isDesktop && userAuthenticated != null) ...<Widget>[
            IconButton(
              onPressed: () {
                EditBlogScreen.push(context);
              },
              icon: const Icon(Icons.edit, size: 20),
            ),
            IconButton(
              onPressed: showDeleteDialog,
              icon: const Icon(Icons.delete, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
