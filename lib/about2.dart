import 'package:flutter/material.dart';

class About2 extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About2> {
  @override
  Widget build(BuildContext context) {
    // Fetch screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Calculate sizing based on screen width
    double avatarRadius = screenWidth * 0.10;  // Example: 15% of screen width
    double spacingVertical = screenHeight * 0.03;
    double spacingHorizontal = screenWidth * 0.05;
    double textSpacing = screenWidth * 0.02;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ABOUT US'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
              children: <Widget>[
                SizedBox(height: spacingVertical),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: spacingHorizontal),
                    ProfileAvatar(screenWidth, avatarRadius, 'assets/maamnel.jpg', "Maria Neliza Fuertes", "Group Managing Director"),
                    SizedBox(height: spacingVertical),
                  ],
                ),
                SizedBox(height: spacingVertical + 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: spacingHorizontal),
                    ProfileAvatar(screenWidth, avatarRadius, 'assets/sirelison.jpg', "Elison M. Tan", "Project Manager"),
                    SizedBox(width: spacingHorizontal),
                    ProfileAvatar(screenWidth, avatarRadius, 'assets/maamtina.jpg', "Maria Cristina C. Evarle", "Supervisor/System Analyst"),
                    SizedBox(height: spacingVertical),
                  ],
                ),
                SizedBox(height: spacingVertical + 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ProfileAvatar(screenWidth, avatarRadius, 'assets/andrei.jpg', "Andrei Niño T. Calope", "System Analyst"),
                    SizedBox(width: spacingHorizontal - 30),
                    ProfileAvatar(screenWidth, avatarRadius, 'assets/james.jpg', "James Matthew P. Remolador", "Programmer"),
                    SizedBox(width: spacingHorizontal - 30),
                    ProfileAvatar(screenWidth, avatarRadius, 'assets/jomari.jpg', "Jomari Galleros", "Programmer"),
                    SizedBox(height: spacingVertical),
                  ],
                ),
                SizedBox(height: spacingVertical + 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: spacingHorizontal),
                    ProfileAvatar(screenWidth, avatarRadius, 'assets/renan.jpg', "Renan A. Ocoy", "Former Programmer"),
                    SizedBox(width: spacingHorizontal + 50),
                    ProfileAvatar(screenWidth, avatarRadius, 'assets/pj.jpg', "Paul Jearic P. Niones", "Former Programmer"),
                    SizedBox(height: spacingVertical),
                  ],
                ),
                SizedBox(height: spacingVertical + 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("For questions and support, please contact CORP. IT-SYSDEV", style: TextStyle(fontSize: 12.0),),
                  ],
                ),
                SizedBox(height: 3.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("IP Phone Numbers: 1825 / 1819 ", style: TextStyle(fontSize: 12.0),),
                  ],
                ),
              ]
          ),
        ),
      ),
    );
  }

  Widget ProfileAvatar(double screenWidth, double avatarRadius, String imagePath, String name, String role) {
    return FadeIn(
      child: Column(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundImage: AssetImage(imagePath),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(name, style: TextStyle(fontSize: screenWidth * 0.025, fontWeight: FontWeight.bold)),
          Text(role, style: TextStyle(fontSize: screenWidth * 0.02, color: Colors.grey)),
        ],
      ),
    );
  }
}

class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeIn({@required this.child, this.duration = const Duration(milliseconds: 1000)});

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,
    );
  }
}
