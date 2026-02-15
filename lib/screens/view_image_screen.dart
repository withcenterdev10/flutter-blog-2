import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewImageScreen extends StatelessWidget {
  const ViewImageScreen({super.key, required this.imageUrl});
  final String imageUrl;

  static const routeName = '/blogs/:imageUrl';
  static const callRouteName = "/$routeName";

  static Function(BuildContext context, String imageUrl) go =
      (context, imageUrl) =>
          context.go(routeName.replaceFirst(":imageUrl", imageUrl));

  static Function(BuildContext context, String imageUrl) push =
      (context, imageUrl) =>
          context.push(routeName.replaceFirst(":imageUrl", imageUrl));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(child: InteractiveViewer(child: Image.network(imageUrl))),
      ),
    );
  }
}
