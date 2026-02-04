import 'package:flutter/material.dart';
import 'package:flutter_blog_2/providers/auth_providers.dart';
import 'package:flutter_blog_2/providers/blog_providers.dart';
import 'package:provider/provider.dart';

class EditBlog extends StatefulWidget {
  const EditBlog({super.key});

  @override
  State<EditBlog> createState() {
    return _EditBlogState();
  }
}

class _EditBlogState extends State<EditBlog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController blogController;

  @override
  void initState() {
    final blogState = context.read<BlogProvider>().getBlogState;
    titleController = TextEditingController(text: blogState.title);
    blogController = TextEditingController(text: blogState.blog);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AuthProvider>().getState;
    final blogState = context.watch<BlogProvider>().getBlogState;

    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        final title = titleController.text;
        final blog = blogController.text;
        final userId = userState.user!.id;
        String message = "";
        try {
          await context.read<BlogProvider>().updateBlog(
            id: blogState.id,
            blog: blog,
            userId: userId,
            title: title,
          );
          message = "Update blog success";
        } catch (error) {
          message = "Update blog failed";
          debugPrint(error.toString());
        } finally {
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextFormField(
              autofocus: true,
              maxLength: 50,
              controller: titleController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title of your blog';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),

            TextFormField(
              maxLines: 8,
              controller: blogController,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title of your blog';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmit,
                child: blogState.loading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text("Submitting..."),
                        ],
                      )
                    : Text(
                        "Submit",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
