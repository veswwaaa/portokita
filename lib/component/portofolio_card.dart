import 'package:flutter/material.dart';

class PortofolioCard extends StatefulWidget {
  const PortofolioCard({super.key});

  @override
  State<PortofolioCard> createState() => _CardPortofolioState();
}

class _CardPortofolioState extends State<PortofolioCard> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Column(
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
                      child: Image.asset(
                        "assets/img/img1.jpg",
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
                          "Design Reze Cantik banget aduhaiiii",
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
                                  child: Text("Mas Amba"),
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
        );
      },
    );
  }
}
