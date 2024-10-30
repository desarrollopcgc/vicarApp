import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:vicar_app/constants.dart';
import 'package:vicar_app/components/data.dart';
import 'package:vicar_app/components/components.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SizeConfig sizeConfig = SizeConfig();
  String currentServiceName = infoServices[0].name;
  Color currentServiceColor = infoServices[0].color;
  String currentServiceDescription = infoServices[0].description;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizeConfig.init(context);
  }

  _confirmLogOut(context) async {
    await Alert(
        context: context,
        type: AlertType.warning,
        title: "Estas a punto de salir",
        desc: "¿Estas seguro?",
        buttons: [
          DialogButton(
              onPressed: () async {
                SystemNavigator.pop(); // Navigates to home screen
              },
              color: Colors.greenAccent.shade700,
              child: const Text("Si",
                  style: TextStyle(
                      color: kTextColor, fontSize: 18, fontFamily: "Arial"))),
          DialogButton(
              onPressed: () => Navigator.pop(context),
              color: Colors.redAccent.shade700,
              child: const Text(
                "No",
                style: TextStyle(
                    color: Colors.white, fontSize: 18, fontFamily: "Arial"),
              ))
        ]).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('PC Grupo Consultor SAS',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kTextColor,
                fontSize: sizeConfig.safeBlockVertical * 2.7,
                fontFamily: "Arial")),
        leading: IconButton(
            onPressed: () {
              _confirmLogOut(context);
            },
            icon: Icon(
              Icons.exit_to_app_rounded,
              color: kTextColor,
              size: sizeConfig.safeBlockVertical * 3.5,
            )),
        centerTitle: true,
        backgroundColor: kBackgroundColor,
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: kBackgroundColor,
            elevation: 0,
            pinned: true,
            stretch: true,
            centerTitle: false,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  SizedBox(height: sizeConfig.safeBlockVertical * 4),
                  Image.asset(
                    "assets/images/logo_pc.png",
                    fit: BoxFit.cover,
                    height: sizeConfig.safeBlockVertical * 15,
                  ),
                  SizedBox(height: sizeConfig.safeBlockVertical * 5),
                  Text(
                    'Somos la solución a sus necesidades',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                        fontSize: sizeConfig.safeBlockVertical * 2.3),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  color: kTextColor,
                  child: Column(
                    children: [
                      SizedBox(height: sizeConfig.safeBlockVertical * 5),
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only(left: 20),
                        child: ListView.builder(
                          itemCount: infoServices.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 30),
                              child: Column(
                                children: [
                                  Container(
                                    height: 65,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: kTextColor,
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          currentServiceName =
                                              infoServices[index].name;
                                          currentServiceDescription =
                                              infoServices[index].description;
                                          currentServiceColor =
                                              infoServices[index].color;
                                        });
                                      },
                                      icon: Icon(infoServices[index].icon),
                                      iconSize: 50,
                                      color: infoServices[index].color,
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                currentServiceName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: currentServiceColor,
                                  fontSize: sizeConfig.safeBlockVertical * 2.3,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                currentServiceDescription,
                                style: TextStyle(
                                  color: kColor4,
                                  fontSize: sizeConfig.safeBlockVertical * 2.3,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            SizedBox(height: sizeConfig.safeBlockVertical * 1),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final member = teamMembers[index];
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: member.color,
                    ),
                    height: sizeConfig.safeBlockHorizontal * 38,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: sizeConfig.safeBlockVertical * 0.9),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            member.name,
                            style: TextStyle(
                              color: kTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: sizeConfig.safeBlockVertical * 2.3,
                            ),
                          ),
                        ),
                        SizedBox(height: sizeConfig.safeBlockVertical * 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Text(
                                  member.description,
                                  style: TextStyle(
                                    color: kTextColor,
                                    fontSize:
                                        sizeConfig.safeBlockVertical * 2.0,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                            SizedBox(width: sizeConfig.safeBlockHorizontal * 5),
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: kTextColor,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  member.photo,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: teamMembers.length,
            ),
          )
        ],
      ),
    );
  }
}
