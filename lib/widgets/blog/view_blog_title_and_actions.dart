import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/screens/edit_blog_screen.dart';
import 'package:flutter_blog_2/screens/home_screen.dart';
import 'package:flutter_blog_2/utils.dart';
import 'package:provider/provider.dart';

class ViewBlogTitleAndActions extends StatelessWidget {
  const ViewBlogTitleAndActions({super.key, required this.showDeleteDialog});
  final void Function() showDeleteDialog;

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 900;
    return Row(
      children: [
        if (isDesktop)
          IconButton(
            onPressed: () {
              HomeScreen.go(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_sharp),
          ),

        if (isDesktop) ...<Widget>[
          Expanded(
            child: Selector<BlogProvider, String>(
              selector: (_, provider) => provider.getBlogState.title!,
              builder: (_, title, _) => Text(
                softWrap: true,
                toUpperCaseFirstChar(title),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),
          const Spacer(),
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
    );
  }
}
