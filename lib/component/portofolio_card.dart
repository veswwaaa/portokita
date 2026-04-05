import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class PortofolioCard extends StatefulWidget {

  final QueryDocumentSnapshot data;


  const PortofolioCard({super.key, required this.data});

  @override
  State<PortofolioCard> createState() => _CardPortofolioState();
}

class _CardPortofolioState extends State<PortofolioCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return _buildDetailPopUp(context);
          }
          );
      },
      child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  margin: EdgeInsets.only(bottom: 30.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
      
                    ///
                    borderRadius: BorderRadius.circular(20.0),
      
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
      
                  width: 450,
                  height: 380,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          widget.data['imageUrl'],
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
      
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                          child: Text(
                            widget.data['title'],
                            textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
      
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 20,
                              top: 14,
                              child: Row(
                                children: [
                                  Container(
                                    width: 30.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    child: Icon(Icons.person_2),
                                  ),
      
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(widget.data['username']),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          children: [
                            Icon(Icons.favorite_border, size: 20),
                            SizedBox(width: 5),
                            Text("725"),
                            SizedBox(width: 20),
                            Icon(Icons.chat_bubble_outline, size: 20),
                            SizedBox(width: 5),
                            Text("123"),
                            SizedBox(width: 5),
                            Icon(Icons.remove_red_eye_outlined, size: 20),
                            SizedBox(width: 5),
                            Text("1.2k"),
                          ],
                        ),
                      ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
      }

      Widget _buildDetailPopUp(BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),

          child: ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30)
                ),
                child: Image.network(
                  (widget.data.data() as Map<String,dynamic>).containsKey('imageUrl')
                  ? widget.data['imageUrl']
                  : Icon(Icons.broken_image),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Padding(
                padding: const EdgeInsetsGeometry.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data['title'] ?? 'Unknown Title',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 15),
                        Text(widget.data['username'] ?? 'Unknown User'),
                      ],
                    ),

                    SizedBox(height: 10,),
                    Divider()
                  ],
                ),
              )
            ],
          ),
        );
      }
  }

