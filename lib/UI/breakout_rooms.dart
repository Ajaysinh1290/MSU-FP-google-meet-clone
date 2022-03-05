import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gmeet/Services/agora.dart';

class BreakoutRooms extends StatefulWidget {
  final Agora agora;
  const BreakoutRooms({Key key, @required this.agora}) : super(key: key);

  @override
  _BreakoutRoomsState createState() => _BreakoutRoomsState();
}

class _BreakoutRoomsState extends State<BreakoutRooms> {
  int rooms = 1;
  List<BreakoutRoom> breakOutRooms = [];
  bool isLoading = false;

  Future<void> createRooms() async {
    setState(() {
      isLoading = true;
    });

    //Firebase code for creating rooms
    await FirebaseFirestore.instance
        .collection("mettings")
        .doc(widget.agora.code)
        .set({'broakOutRooms': breakOutRooms}, SetOptions(merge: true));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    print("In this screen");

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text('Breakout Rooms'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Rooms",
                    style: TextStyle(fontSize: 18),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      if (rooms > 1) {
                        setState(() {
                          rooms--;
                        });
                      }
                    },
                    icon: Icon(Icons.remove),
                  ),
                  Text(rooms.toString()),
                  IconButton(
                    onPressed: () {
                      if (rooms < widget.agora.users.length) {
                        setState(() {
                          rooms++;
                        });
                      }
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              Expanded(child: Builder(builder: (context) {
                breakOutRooms = [];
                for (int i = 0;
                    i < widget.agora.users.length / rooms + 1;
                    i += rooms) {
                  breakOutRooms.add(BreakoutRoom(
                    users: widget.agora.users.sublist(
                        i,
                        (i + rooms) > widget.agora.users.length
                            ? (widget.agora.users.length)
                            : (i + rooms)),
                    roomName: 'Broadcast Room ${i + 1}',
                  ));
                }
                // if (breakOutRooms.last.users.isEmpty) {
                //   return SizedBox();
                // }
                return ListView.builder(
                  itemCount: breakOutRooms.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(breakOutRooms[index].roomName),
                        SizedBox(
                          height: 10,
                        ),
                        ...breakOutRooms[index]
                            .users
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width,
                                height: 70,
                                color: e.joinedNow
                                    ? Colors.teal[50]
                                    : Colors.transparent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      color: Colors.grey[200],
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      child: Center(
                                        child: ClipRRect(
                                          child: Image.network(
                                            e.image,
                                            height: 50,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(widget.agora.users[index].name)
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  },
                );
              })),
            ],
          ),
        ),
        // body: StreamBuilder(
        //   stream: FirebaseFirestore.instance
        //       .collection('meetings')
        //       .doc(widget.meetingCode)
        //       .collection('users')
        //       .snapshots(),
        //   builder: (context, snapshot) {
        //     if (!snapshot.hasData) {
        //       return Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     }
        //     if(snapshot.hasError) {
        //       return Center(
        //         child: Text('Error'),
        //       );
        //     }
        //     return ListView.builder(
        //       itemCount: snapshot.data.docs.length,
        //       itemBuilder: (context, index) {
        //         print("Data :"+snapshot.data.toString());
        //         return ListTile(
        //           title: Text(snapshot.data.docs[index].data['name']),
        //           leading: CircleAvatar(child: Image.network(snapshot.data.docs[index].data['image_url'])),
        //           subtitle:
        //               Text(snapshot.data.docs[index].data['description']),
        //           trailing: Icon(Icons.arrow_forward_ios),
        //           onTap: () {
        //             // Navigator.push(
        //             //   context,
        //             //   MaterialPageRoute(
        //             //     builder: (context) => BreakoutRoom(
        //             //       meetingCode: widget.meetingCode,
        //             //       roomCode: snapshot.data.documents[index].data['code'],
        //             //     ),
        //             //   ),
        //             // );
        //           },
        //         );
        //       },
        //     );
        //   },
        // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: GestureDetector(
          onTap: createRooms,
          child: Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.teal, borderRadius: BorderRadius.circular(10)),
            child: isLoading
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(
                    "Create Room",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ));
  }
}

class BreakoutRoom {
  String roomName;
  List users;
  BreakoutRoom({this.roomName, this.users});
}
