import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/widgets/home_avatar.dart';
import 'package:flutter_blog_2/widgets/my_drawer.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<Auth>().getState;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [HomeAvatar(scaffoldKey: scaffoldKey)],
      ),
      endDrawer: authState.user != null ? const MyDrawer() : null,
      body: Center(child: Text("Blogs here soon.")),
    );
  }
}
