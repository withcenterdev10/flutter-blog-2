import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/providers/comment_provider.dart';
import 'package:flutter_blog_2/widgets/blog/view_blog_content.dart';
import 'package:flutter_blog_2/widgets/blog/view_blog_screen_action.dart';
import 'package:flutter_blog_2/widgets/comment/comment_input_box.dart';
import 'package:flutter_blog_2/widgets/layout/appbar.dart';
import 'package:flutter_blog_2/widgets/spinner.dart';
import 'package:flutter_blog_2/widgets/unfocus_close_keyboard.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ViewBlogScreen extends StatefulWidget {
  const ViewBlogScreen({super.key, required this.id});
  final String id;

  static const routeName = '/blogs/:id';
  static const callRouteName = "/$routeName";

  static Function(BuildContext context, String id) go = (context, id) =>
      context.go(routeName.replaceFirst(":id", id));

  static Function(BuildContext context, String id) push = (context, id) =>
      context.push(routeName.replaceFirst(":id", id));

  @override
  State<ViewBlogScreen> createState() {
    return _ViewBlogScreenState();
  }
}

class _ViewBlogScreenState extends State<ViewBlogScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogProvider>().getBlog(widget.id);
    });

    super.initState();
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final blogTitle = context.select<BlogProvider, String?>(
      (p) => p.blog.title,
    );

    final loading = context.select<BlogProvider, bool>((p) => p.blog.loading);

    bool isDesktop(BuildContext context) {
      return MediaQuery.of(context).size.width >= 900;
    }

    return UnfocusCloseKeyboard(
      child: Scaffold(
        key: scaffoldKey,
        appBar: isDesktop(context)
            ? MyAppbar(scaffoldKey: scaffoldKey)
            : AppBar(
                title: blogTitle != null ? Text(blogTitle) : null,
                actions: [ViewBlogScreenAction()],
              ),

        body: PopScope(
          onPopInvokedWithResult: (bool didPop, Object? result) async {
            if (didPop) {
              context.read<BlogProvider>().resetBlogState();
              context.read<CommentProvider>().resetState();
              return;
            }
          },

          child: loading ? Center(child: Spinner()) : ViewBlogContent(),
        ),

        bottomNavigationBar: Selector<AuthProvider, bool>(
          selector: (_, provider) => provider.getState.user != null,
          builder: (context, value, child) {
            if (value) {
              return Row(
                children: [
                  Spacer(),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width >= 500
                          ? 720
                          : MediaQuery.of(context).size.width,
                    ),
                    child: const CommentInput(),
                  ),
                  Spacer(),
                ],
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
