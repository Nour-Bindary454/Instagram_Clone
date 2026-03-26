import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram_clone/views/profile/widgets/edit_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  String profilePicUrl = '';
  bool isLoading = true;
  bool isSaving = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _usernameController.text = data['username'] ?? '';
      _websiteController.text = data['website'] ?? '';
      _bioController.text = data['bio'] ?? '';
      _emailController.text = data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
      _phoneController.text = data['phone'] ?? '';
      _genderController.text = data['gender'] ?? '';
      profilePicUrl = data['profilePicUrl'] ?? '';
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() { isSaving = true; });
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    String finalPicUrl = profilePicUrl;
    if (_imageFile != null) {
      try {
        final cloudinary = CloudinaryPublic('dewjx1auh', 'insta_clone_preset', cache: false);
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_imageFile!.path, resourceType: CloudinaryResourceType.Image),
        );
        finalPicUrl = response.secureUrl;
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text,
        'username': _usernameController.text,
        'website': _websiteController.text,
        'bio': _bioController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'gender': _genderController.text,
        if (finalPicUrl.isNotEmpty) 'profilePicUrl': finalPicUrl,
      }, SetOptions(merge: true));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
      setState(() { isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('edit_cancel'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
        leadingWidth: 80,
        title: Text('profile_edit'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          isSaving 
            ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.blue))
            : TextButton(
                onPressed: _saveProfile,
                child: Text('edit_done'.tr(), style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _imageFile != null 
                          ? FileImage(_imageFile!) as ImageProvider 
                          : (profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : const AssetImage('assets/images/avatar.png')),
                    ),
                    const SizedBox(height: 15),
                    Text('edit_change_photo'.tr(), style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Divider(color: Colors.grey, height: 1),
            EditTextField(label: 'edit_name'.tr(), controller: _nameController),
            EditTextField(label: 'edit_username'.tr(), controller: _usernameController),
            EditTextField(label: 'edit_website'.tr(), controller: _websiteController),
            EditTextField(label: 'edit_bio'.tr(), controller: _bioController),
            const Divider(color: Colors.grey, height: 20),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text('edit_pro'.tr(), style: const TextStyle(color: Colors.blue, fontSize: 16)),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text('edit_private'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            EditTextField(label: 'edit_email'.tr(), controller: _emailController),
            EditTextField(label: 'edit_phone'.tr(), controller: _phoneController),
            EditTextField(label: 'edit_gender'.tr(), controller: _genderController),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
