import 'package:flutter/material.dart';
import 'package:flutter_blog_2/models/blog_model.dart';
import 'package:flutter_blog_2/utils.dart';

class ViewBlogContent extends StatefulWidget {
  const ViewBlogContent({super.key, required this.blog});

  final BlogModel blog;

  @override
  State<ViewBlogContent> createState() {
    return _VewBlogContentState();
  }
}

class _VewBlogContentState extends State<ViewBlogContent> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    widget.blog.user?.imageUrl != null
                        ? CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              widget.blog.user!.imageUrl!,
                            ),
                          )
                        : CircleAvatar(
                            radius: 25,
                            child: Text(
                              widget.blog.user!.displayName!
                                  .substring(0, 2)
                                  .toUpperCase(),
                            ),
                          ),
                    const SizedBox(width: 8),
                    Text(
                      toUpperCaseFirstChar(widget.blog.user!.displayName!),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 6),
            child: const Divider(),
          ),
          Text(
            toUpperCaseFirstChar(widget.blog.title!),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 15),
          Text(widget.blog.blog!),
          const SizedBox(height: 15),
          if (widget.blog.imageUrls != null)
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.blog.imageUrls!.length,
              itemBuilder: (BuildContext context, int index) => Padding(
                padding: EdgeInsetsGeometry.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: Image.network(
                    widget.blog.imageUrls![index],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
