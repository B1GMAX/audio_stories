import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_cliper.dart';
import 'home_bloc.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.height;
    return Provider<HomeBloc>(
      create: (BuildContext context) => HomeBloc(),
      builder: (context, child) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                  ),
                  child: Text('Drawer Header'),
                ),
                ListTile(
                  title: const Text('Profile'),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Item 2'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              ClipPath(
                clipper: MyCustomClipper(),
                child: Container(
                  height: height * 0.6,
                  color: Colors.deepPurple,
                ),
              ),
              Positioned(
                child: IconButton(
                  onPressed: () {
                    _scaffoldKey.currentState!.openDrawer();

                  },
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                ),
                left: 4,
                top: kToolbarHeight * 0.59,
              ),
              Positioned(
                top: 160,
                left: 25,
                right: 25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF71A59F).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      height: height / 3.5,
                      width: width / 5.2,
                      child: const Center(child: Text('text')),
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1B488).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: height / 8.2,
                          width: width / 5.2,
                          child: const Center(child: Text('text')),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF678BD2).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: height / 8.2,
                          width: width / 5.2,
                          child: const Center(child: Text('text')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10,left: 10),
                child: DraggableScrollableSheet(
                  initialChildSize: 0.4,
                  maxChildSize: 0.8,
                  minChildSize: 0.3,
                  builder:
                      (BuildContext context, ScrollController scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text('dsds'),
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: context.read<HomeBloc>().items.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  height: 30,
                                  color: Colors.white,
                                  child: Text(context.read<HomeBloc>().items[index]),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
