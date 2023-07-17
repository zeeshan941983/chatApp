import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/chatStyle.dart';

import '../components/textfieldForMsg.dart';
import '../services/chat/chat_service.dart';

class Chatpage extends StatefulWidget {
  final String reciveuserEmail;
  final String reciveuserID;
  final String reciverName;
  final String reciverimage;
  final bool? isonline;

  const Chatpage({
    Key? key,
    required this.reciverName,
    this.isonline,
    required this.reciveuserEmail,
    required this.reciveuserID,
    required this.reciverimage,
  }) : super(key: key);

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  final Timestamp isonlinetime = Timestamp.now();
  String isonline = '';
  String name = '';
  String sentMessageId = '';
  String data = '';
  ScrollController _scrollController = ScrollController();
  void _update() {
    String chatRoomId = _getChatRoomId();
    _chatService.ref
        .doc(chatRoomId)
        .collection('messages')
        .doc(name)
        .update({'read': 'seen'});
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      _chatService.sendMessage(
        widget.reciveuserID,
        _messageController.text,
      );
      _update();
    }
    _messageController.clear();
  }

//////pic
  File? _image;

  Future<XFile?> getimageGellary() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return XFile(pickedFile.path);
    }
    return null;
  }

  Future<XFile?> getimageCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return XFile(pickedFile.path);
    }
    return null;
  }

  ///
  ///bottomsheet

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 500,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 100,
                          backgroundImage: FileImage(File(_image!.path)),
                        )
                      : CircleAvatar(
                          radius: 100,
                          child: Icon(
                            Icons.person,
                            size: 100,
                          ),
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final image = await getimageGellary();
                          setState(() {
                            _image = image != null ? File(image.path) : null;
                          });
                        },
                        icon: Icon(
                          Icons.image,
                          color: Colors.deepPurple,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final image = await getimageCamera();
                          setState(() {
                            _image = image != null ? File(image.path) : null;
                          });
                        },
                        icon: Icon(
                          Icons.camera,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_image != null) {
                        final ref = storage.ref('/images/' +
                            DateTime.now().microsecondsSinceEpoch.toString());
                        final ploadTask = ref.putFile(_image!);
                        await Future.value(ploadTask);
                        var newurl = await ref.getDownloadURL();

                        FirebaseFirestore.instance
                            .collection('chat_images')
                            .doc()
                            .collection('messages')
                            .add({'image': newurl.toString()});
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Send'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    _messageController.clear();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.reciveuserID)
        .snapshots()
        .listen((snapshot) {
      final status = snapshot.data()?['isOnline'];
      setState(() {
        isonline = status;
      });
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getChatRoomId() {
    List<String> ids = [
      _firebaseAuth.currentUser!.uid,
      widget.reciveuserID,
    ];
    ids.sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: size.height * 0.049,
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 30,
                  )),
              SizedBox(
                width: size.width * 0.020,
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: SizedBox(
                            height: MediaQuery.of(context).size.height / 2.5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 130,
                                  backgroundImage:
                                      NetworkImage(widget.reciverimage),
                                ),
                                shight(size: size),
                                Text(
                                  widget.reciverName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(widget.reciveuserEmail,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(widget.reciverimage),
                ),
              ),
              SizedBox(
                width: size.width * 0.020,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 50),
                child: Column(
                  children: [
                    Text(
                      widget.reciverName,
                      style: GoogleFonts.aBeeZee(fontSize: 20),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.circle_sharp,
                          size: 10,
                          color:
                              isonline == 'offline' ? Colors.red : Colors.green,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        isonline == 'offline'
                            ? Text(
                                'Offline',
                                style: GoogleFonts.aBeeZee(),
                              )
                            : Text(
                                "Online",
                                style: GoogleFonts.poppins(fontSize: 15),
                              )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Expanded(child: _buildMessageList()), // Wrap with Flexible
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.reciveuserID,
        _firebaseAuth.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('loading');
        }

        // Delay scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        return ListView(
          controller: _scrollController, // Attach ScrollController
          children: documents.map((document) {
            Map<String, dynamic> messageData =
                document.data() as Map<String, dynamic>;
            String documentId = document.id;
            name = documentId;

            return Column(
              children: [
                GestureDetector(
                  onLongPress: () {
                    _showDeleteConfirmationDialog(documentId);
                  },
                  child: _buildMessageItem(documentId, messageData),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(String messageId, Map<String, dynamic> messageData) {
    var alignment = (messageData['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    DateTime messageTime = (messageData['timestamp'] as Timestamp).toDate();

    return Container(
      alignment: alignment,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
          crossAxisAlignment:
              (messageData['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          mainAxisAlignment:
              (messageData['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            chatstyle(
              border: messageData['senderId'] == _firebaseAuth.currentUser!.uid
                  ? BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20))
                  : BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
              color: messageData['senderId'] == _firebaseAuth.currentUser!.uid
                  ? Colors.deepPurple
                  : Colors.grey,
              Message: messageData['message'],
              time: _formatMessageTime(messageTime),
            ),
            SizedBox(height: 5),
            messageData['senderId'] == _firebaseAuth.currentUser!.uid
                ? Text(messageData['read'])
                : Text('')
          ]),
    );
  }

  Widget _buildimage(String messageId, Map<String, dynamic> messageData) {
    var alignment = (messageData['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    DateTime messageTime = (messageData['timestamp'] as Timestamp).toDate();

    return Container(
      alignment: alignment,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
          crossAxisAlignment:
              (messageData['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          mainAxisAlignment:
              (messageData['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            chatstyle(
              border: messageData['senderId'] == _firebaseAuth.currentUser!.uid
                  ? BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20))
                  : BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
              color: messageData['senderId'] == _firebaseAuth.currentUser!.uid
                  ? Colors.deepPurple
                  : Colors.grey,
              Message: messageData['message'],
              image: messageData['image'],
              time: _formatMessageTime(messageTime),
            ),
            SizedBox(height: 5),
            messageData['senderId'] == _firebaseAuth.currentUser!.uid
                ? Text(messageData['read'])
                : Text('')
          ]),
    );
  }

  String _formatMessageTime(DateTime messageTime) {
    final DateFormat formatter = DateFormat('h:mm a');
    return formatter.format(messageTime);
  }

  ///build msg input
  Widget _buildMessageInput() {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              _showBottomSheet();
            },
            icon: Icon(Icons.photo)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: msgTextfield(
              controller: _messageController,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 15),
          child: IconButton(
            onPressed: () async {
              sendMessage();

              _messageController.clear();
            },
            icon: Icon(
              Icons.send,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor: Colors.black,
          backgroundColor: Colors.deepPurple,
          contentTextStyle: TextStyle(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white),
          title: Text("Delete message"),
          content:
              Text("This Message will delete from everyone Are you sure ?"),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _deleteMessage();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage() {
    String chatRoomId = _getChatRoomId();
    _chatService.ref.doc(chatRoomId).collection('messages').doc(name).delete();
  }
}
