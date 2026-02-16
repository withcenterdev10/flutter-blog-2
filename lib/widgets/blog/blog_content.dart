import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/blogs_model.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:flutter_blog_2/widgets/blog/blog.dart';
import 'package:flutter_blog_2/widgets/spinner.dart';
import 'package:provider/provider.dart';

class BlogContent extends StatelessWidget {
  const BlogContent({super.key});

  @override
  Widget build(BuildContext context) {
    final blogsState = context.select<BlogProvider, BlogsModel>(
      (p) => p.getBlogsState,
    );
    Widget content = Align(
      alignment: AlignmentGeometry.center,
      child: Spinner(),
    );

    if (blogsState.blogs.isNotEmpty && !blogsState.loading) {
      content = Selector<BlogProvider, BlogsModel>(
        selector: (_, provider) => provider.getBlogsState,
        builder: (_, value, _) {
          return ListView.builder(
            itemCount: value.blogs.length,
            itemBuilder: (BuildContext context, int index) {
              return Blog(blog: value.blogs[index]);
            },
          );
        },
      );
    }

    if (blogsState.blogs.isEmpty && !blogsState.loading) {
      content = Center(child: Text("No blogs found"));
    }

    return content;
  }
}
