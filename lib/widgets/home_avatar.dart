import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/widgets/auth/sign_in.dart';
import 'package:provider/provider.dart';

class HomeAvatar extends StatefulWidget {
  const HomeAvatar({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<StatefulWidget> createState() {
    return _HomeAvatarState();
  }
}

class _HomeAvatarState extends State<HomeAvatar> {
  void openSignUpModal() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => const SignIn(),
    );
  }

  @override
  build(BuildContext context) {
    final authState = context.watch<AuthProvider>().getState;
    final profileImage = authState.user?.userMetadata?['image_url'];
    final displayName = authState.user?.userMetadata?['display_name'];

    Widget avatar = TextButton(
      onPressed: openSignUpModal,
      child: Text("Sign In"),
    );

    if (displayName != null && profileImage == null) {
      final displayName = authState.user!.userMetadata!['display_name'];
      avatar = CircleAvatar(
        child: Text(displayName.substring(0, 2).toString().toUpperCase()),
      );
    }

    if (profileImage != null) {
      avatar = CircleAvatar(backgroundImage: NetworkImage(profileImage));
    }

    return GestureDetector(
      onTap: () => widget.scaffoldKey.currentState?.openEndDrawer(),
      child: Padding(padding: EdgeInsets.only(right: 12), child: avatar),
    );
  }
}
