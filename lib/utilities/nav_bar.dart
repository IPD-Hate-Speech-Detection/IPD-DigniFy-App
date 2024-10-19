import 'package:dignify/screens/homepage/favourites_page.dart';
import 'package:dignify/screens/homepage/home_page.dart';
import 'package:dignify/screens/homepage/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int myIndex = 0;
  final List _screens = [
    const HomePage(),
   const FavouritesPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[myIndex],
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: GNav(
            // backgroundColor: Colors.black,
            color: const Color.fromARGB(255, 188, 188, 186),
            activeColor: Colors.white,
            tabBackgroundColor: const Color(0xFF616161),
            padding: const EdgeInsets.all(7),
            onTabChange: (index) {
              setState(() {
                myIndex = index;
              });
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                icon: Icons.favorite,
                text: "Favourites",
              ),
              GButton(
                icon: Icons.person,
                text: "Profile",
              )
            ],
          ),
        ),
      ),
    );
  }
}
