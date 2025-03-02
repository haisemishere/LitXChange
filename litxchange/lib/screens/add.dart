import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddPage(),
    );
  }
}

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _authorNameController = TextEditingController();
  String _selectedCondition = 'New'; // Default selected condition
  String _selectedGenre = 'Fiction'; // Default selected genre
  File? _image;
  String? _bookNameError;
  String? _authorNameError;

  final List<String> _conditionItems = ['New', 'Like New', 'Very Good', 'Good', 'Acceptable'];

  final List<String> _genreItems = [
    'Fiction',
    'Non-fiction',
    'Mystery',
    'Thriller',
    'Science Fiction (Sci-Fi)',
    'Fantasy',
    'Romance',
    'Historical Fiction',
    'Horror',
    'Adventure',
    'Crime',
    'Biography',
    'Autobiography',
    'Memoir',
    'Young Adult (YA)',
    "Children's",
    'Comedy',
    'Satire',
    'Poetry',
    'Drama',
    'Self-help',
    'Business',
    'Travel',
    'Science',
    'Philosophy',
    'Psychology',
    'Religion/Spirituality',
    'Cookbooks',
    'Art/Photography',
    'Graphic Novels/Comics',
    'Music',
    'Sports',
    'Health/Fitness',
    'Education',
    'Technology',
    'Parenting/Family',
    'LGBTQ+',
    'Military/War',
    'Supernatural/Paranormal',
    'Western',
    'Urban',
    'Environmental',
    'Dystopian',
    'Utopian',
    'Post-Apocalyptic',
    'Steampunk',
    'Cyberpunk',
    'Gothic',
    'Bildungsroman (Coming-of-age)',
    'Experimental/Avant-Garde',
  ];

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path); // Convert PickedFile to File
      } else {
        print('No image selected.');
      }
    });
  }

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('New Post'),
      ),
      body: SingleChildScrollView( // Wrap the entire content with SingleChildScrollView
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
              child:TextButton(
                  onPressed: _getImage,
                  child: Text(
                    'Pick Image',
                    style: TextStyle(color: Color(0xFF457a8b),fontSize: 16,fontWeight: FontWeight.bold), // Button text style
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Book Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _bookNameController,
                decoration: InputDecoration(
                  hintText: 'Enter the book name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                  errorText: _bookNameError,
                ),
                cursorColor:Color(0xFF457a8b),
              ),
              SizedBox(height: 16),
              Text(
                'Author',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _authorNameController,
                decoration: InputDecoration(
                  hintText: 'Enter the Author Name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                  errorText: _authorNameError,
                ),
                cursorColor:Color(0xFF457a8b),
              ),
              SizedBox(height: 16),
              Text(
                'Book Condition',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCondition = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                ),

                items: _conditionItems.map((condition) {
                  return DropdownMenuItem<String>(
                    value: condition,
                    child: Text(condition,),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text(
                'Genre',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                onChanged: (newValue) {
                  setState(() {
                    _selectedGenre = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF457a8b),
                    ),
                  ),
                ),

                items: _genreItems.map((genre) {
                  return DropdownMenuItem<String>(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              _image != null
                  ? Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : SizedBox.shrink(),
              SizedBox(height: 16),
              Container(
                height: 60,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(69, 122, 139, 1.0),
                      Color.fromRGBO(69, 122, 139, 1.0),
                    ],
                  ),
                ),
                child: _isSaving ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
                    : ElevatedButton(
                  onPressed: () {
                    // Set _isSaving to true when button is pressed
                    setState(() {
                      _isSaving = true;
                    });
                    _savePost().then((_) {
                      // After _savePost() completes, set _isSaving to false
                      setState(() {
                        _isSaving = false;
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF457a8b),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Post',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _savePost() async {
    String bookName = _bookNameController.text.trim();
    String authorName = _authorNameController.text.trim();
    String condition = _selectedCondition;
    String genre = _selectedGenre;
    String? imageUrl;

    setState(() {
      // Reset previous error messages
      _bookNameError = null;
      _authorNameError = null;
    });

    if (bookName.isEmpty) {
      setState(() {
        _bookNameError = 'Book name cannot be empty';
      });
      return;
    }

    if (authorName.isEmpty) {
      setState(() {
        _authorNameError = 'Author name cannot be empty';
      });
      return;
    }

    try {
      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');
        final uploadTask = storageRef.putFile(_image!);
        await uploadTask;
        imageUrl = await storageRef.getDownloadURL();
      }
      else
        {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Add an image for this post'),
            ),
          );
              return;
        }
      String postId = FirebaseFirestore.instance.collection('posts').doc().id;

      await FirebaseFirestore.instance.collection('posts').add({
        'postId':postId,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'bookName': bookName,
        'authorName': authorName,
        'condition': condition,
        'genre': genre,
        'date': DateTime.now(),
        'imageUrl': imageUrl ?? '',
      });

      _bookNameController.clear();
      _authorNameController.clear();
      setState(() {
        _selectedCondition = _conditionItems[0];
        _selectedGenre = _genreItems[0];
        _image = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post Added Successfully.'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add post'),
        ),
      );
      print("Error adding post: $error");
    }
  }
}


