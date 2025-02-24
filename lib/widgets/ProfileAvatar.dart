import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileAvatar extends StatefulWidget {
  final String? imageUrl;
  final void Function(String imageUrl) onUpload;

  const ProfileAvatar(
      {super.key, required this.imageUrl, required this.onUpload});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Center(
        child: CircleAvatar(
          radius: 50,
          backgroundImage:
              widget.imageUrl != null ? NetworkImage(widget.imageUrl!) : null,
          child: widget.imageUrl == null
              ? Image.asset('assets/images/ProfilePic.png', height: 65)
              : null,
        ),
      ),
      Transform(
        transform: Matrix4.translationValues(187, 60, 0),
        child: GestureDetector(
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image =
                await picker.pickImage(source: ImageSource.gallery);
            if (image == null) return;
            final imageExtension = image.path.split('.').last.toLowerCase();
            final imageBytes = await image.readAsBytes();
            final userId = supabase.auth.currentUser!.id;
            final imagePath = '/$userId/profile';
            await supabase.storage.from('profiles').uploadBinary(
                imagePath, imageBytes,
                fileOptions: FileOptions(
                    upsert: true, contentType: 'image/$imageExtension'));
            String imageUrl =
                supabase.storage.from('profiles').getPublicUrl(imagePath);
            imageUrl = Uri.parse(imageUrl).replace(queryParameters: {
              't': DateTime.now().millisecondsSinceEpoch.toString()
            }).toString();
            widget.onUpload(imageUrl);
          },
          child: Container(
            height: 30,
            width: 40,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.green),
            child: const Icon(Icons.camera_enhance, color: Colors.white),
          ),
        ),
      ),
    ]);
  }
}
