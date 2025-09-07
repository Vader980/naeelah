import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'For Naeelah 💕',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: ShiftTrackerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShiftTrackerScreen extends StatefulWidget {
  @override
  _ShiftTrackerScreenState createState() => _ShiftTrackerScreenState();
}

class _ShiftTrackerScreenState extends State<ShiftTrackerScreen>
    with TickerProviderStateMixin {
  DateTime? shiftEnd;
  Timer? _timer;
  late AnimationController _heartController;
  late AnimationController _bounceController;
  late AnimationController _wiggleController;
  late AnimationController _glowController;
  
  int _encouragementIndex = 0;
  int _quoteIndex = 0;
  bool _showEncouragement = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _encouragementKey = GlobalKey();

  final List<String> quotes = [
    "You got this! 💪",
    "Doing amazing work out there! 🌟",
    "Your patients are lucky to have you! 🏥",
    "Keep being awesome! ✨",
    "Almost there, you're crushing it! 🎯",
    "Your dedication is really impressive! 👏",
    "Taking care of people like a pro! 👩‍⚕️",
    "You make it look easy! 😊"
  ];

  final List<String> encouragements = [
    "Hey beautiful, you're literally out there being a superhero while I'm just here missing you and being proud of everything you do! Your patients have no idea how lucky they are 💕",
    "I know you're probably exhausted right now, but watching you care for people with such dedication makes me fall for you even more. You're incredible, babe 🌟",
    "Even when you're running on empty, you still show up with so much grace and compassion. That's my girl - strong, beautiful, and absolutely amazing ✨",
    "I'm sitting here thinking about how I get to call the most caring, hardworking person I know my girlfriend. Like, how did I get so lucky? 💙",
    "Your patients might not know your name, but they're getting healed by someone with the biggest heart I've ever known. That's pretty magical if you ask me 💫",
    "I hope you know that every life you touch today is better because of your kindness. You're not just doing a job - you're spreading love, one patient at a time 🌈",
    "Babe, I see how much you care about everyone around you, and it makes me so proud to be yours. You're making the world a better place just by being you 👑",
    "You're probably being way too hard on yourself right now. But from where I'm sitting, you're perfect - tired, stressed, beautiful, and absolutely crushing it 💕",
    "Just wanted to remind you that your boyfriend thinks you're the most amazing person in the world. And also that you look cute even when you're exhausted 😘",
    "Long shifts are brutal, but if anyone was born to handle this, it's you. You're tough as nails but soft as silk, and I'm so in love with both sides of you 🚀"
  ];

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _bounceController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _wiggleController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _startTimer();
    _startQuoteTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _heartController.dispose();
    _bounceController.dispose();
    _wiggleController.dispose();
    _glowController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  void _startQuoteTimer() {
    Timer.periodic(Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % quotes.length;
        });
      }
    });
  }

  void _selectEndTime() async {
    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'When does your shift end? ⏰',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink,
              onSurface: Colors.pink.shade700,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (endTime != null) {
      DateTime now = DateTime.now();
      DateTime end = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);
      
      // If end time is before current time, assume it's tomorrow
      if (end.isBefore(now)) {
        end = end.add(Duration(days: 1));
      }
      
      setState(() {
        shiftEnd = end;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shift timer set! You got this! 💪'),
          backgroundColor: Colors.pink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    }
  }

  String _getTimeRemaining() {
    if (shiftEnd == null) return "Tap to set shift end time! ⏰";
    
    DateTime now = DateTime.now();
    if (now.isAfter(shiftEnd!)) {
      return "Shift complete! Time to go home! 🎉";
    }
    
    Duration remaining = shiftEnd!.difference(now);
    int hours = remaining.inHours;
    int minutes = remaining.inMinutes % 60;
    
    return "${hours}h ${minutes}m left";
  }

  double _getProgress() {
    if (shiftEnd == null) return 0.0;
    
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day, 8, 0); // Assume 8 AM start
    
    if (shiftEnd!.day > now.day) {
      // Multi-day shift
      start = DateTime(now.year, now.month, now.day - 1, 8, 0);
    }
    
    Duration total = shiftEnd!.difference(start);
    Duration elapsed = now.difference(start);
    
    if (elapsed.isNegative) return 0.0;
    if (now.isAfter(shiftEnd!)) return 1.0;
    
    return elapsed.inMinutes / total.inMinutes;
  }

  List<Widget> _getAchievements() {
    if (shiftEnd == null) return [];
    
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day, 8, 0);
    
    if (shiftEnd!.day > now.day) {
      start = DateTime(now.year, now.month, now.day - 1, 8, 0);
    }
    
    Duration elapsed = now.difference(start);
    int hoursWorked = elapsed.inHours;
    
    List<String> achievements = [];
    if (hoursWorked >= 4) achievements.add("4 Hours Strong! 💪");
    if (hoursWorked >= 8) achievements.add("Full Day Hero! 🌟");
    if (hoursWorked >= 12) achievements.add("12 Hours?! Amazing! 🏆");
    if (hoursWorked >= 16) achievements.add("16 Hour Legend! 👑");
    if (hoursWorked >= 20) achievements.add("20 Hours! Superhuman! ⭐");
    
    return achievements.map((achievement) => 
      Container(
        margin: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          achievement,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    ).toList();
  }

  void _showEncouragementMessage() async {
    setState(() {
      _showEncouragement = true;
      _encouragementIndex = (_encouragementIndex + 1) % encouragements.length;
    });
    
    // Auto scroll to the encouragement message
    await Future.delayed(Duration(milliseconds: 100));
    if (_encouragementKey.currentContext != null) {
      Scrollable.ensureVisible(
        _encouragementKey.currentContext!,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  // Helper method to get responsive sizing
  double _getResponsiveFontSize(double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    // iPhone 12: 390px, iPhone 12 Mini: 375px, iPhone 12 Pro Max: 428px
    if (screenWidth <= 375) return baseSize * 0.9;  // iPhone 12 Mini
    if (screenWidth <= 390) return baseSize;        // iPhone 12/Pro
    return baseSize * 1.05;                         // iPhone 12 Pro Max
  }

  double _getResponsivePadding(double basePadding) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 375) return basePadding * 0.8;  // iPhone 12 Mini
    if (screenWidth <= 390) return basePadding;        // iPhone 12/Pro
    return basePadding * 1.1;                          // iPhone 12 Pro Max
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isIPhone12Mini = screenWidth <= 375;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF9A9E),
              Color(0xFFFECFEF),
              Color(0xFFFECFEF),
              Color(0xFFFFB6C1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating hearts animation - optimized for iPhone screens
            ...List.generate(isIPhone12Mini ? 6 : 8, (index) => 
              AnimatedBuilder(
                animation: _heartController,
                builder: (context, child) {
                  double offset = (_heartController.value + index * 0.3) % 1.0;
                  return Positioned(
                    left: (index * (screenWidth / (isIPhone12Mini ? 6 : 8)) + 20) % screenWidth,
                    top: screenHeight * (1 - offset) - 50,
                    child: Opacity(
                      opacity: sin(offset * pi).abs() * 0.7,
                      child: Text(
                        index % 2 == 0 ? '💕' : '❤️',
                        style: TextStyle(fontSize: isIPhone12Mini ? 16 : 18),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(_getResponsivePadding(16)),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(_getResponsivePadding(20)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.pink, width: 3),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Hey Naeelah! 💕',
                            style: TextStyle(
                              color: Colors.pink.shade600,
                              fontSize: _getResponsiveFontSize(28),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Made this for you during your shift!',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: _getResponsiveFontSize(16),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: _getResponsivePadding(20)),
                    
                    // Timer Card
                    GestureDetector(
                      onTap: _selectEndTime,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(_getResponsivePadding(20)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border(left: BorderSide(color: Colors.pink, width: 5)),
                        ),
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _bounceController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, sin(_bounceController.value * 2 * pi) * 3),
                                  child: Text(
                                    '🩺',
                                    style: TextStyle(fontSize: _getResponsiveFontSize(50)),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your Shift Tracker',
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(20),
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 12),
                            
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.pink, Colors.pink.shade700],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _getTimeRemaining(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: _getResponsiveFontSize(18),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10),
                                  
                                  Container(
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: _getProgress(),
                                        backgroundColor: Colors.transparent,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  
                                  Text(
                                    shiftEnd != null 
                                        ? '${(_getProgress() * 100).toInt()}% complete!'
                                        : 'Tap to set your shift end time ⏰',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: _getResponsiveFontSize(14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 12),
                            
                            // Fixed achievements layout with proper wrapping
                            Container(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 4,
                                runSpacing: 4,
                                children: _getAchievements(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: _getResponsivePadding(20)),
                    
                    // Message Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(_getResponsivePadding(20)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border(left: BorderSide(color: Colors.pink, width: 5)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Just wanted to say...',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(18),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 12),
                          
                          Text(
                            "You're seriously incredible! While I'm here just chilling and probably playing games or something, you're out there literally saving lives and being the most amazing person ever. That's my girlfriend everyone - the one who makes the world better just by existing! Hope you're staying caffeinated and sneaking in breaks when you can, beautiful! ☕💕",
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(16),
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Fixed emoji row with proper spacing for iPhone screens
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AnimatedBuilder(
                                  animation: _wiggleController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: sin(_wiggleController.value * 2 * pi) * 0.1,
                                      child: Text('💊', style: TextStyle(fontSize: isIPhone12Mini ? 24 : 28)),
                                    );
                                  },
                                ),
                                AnimatedBuilder(
                                  animation: _wiggleController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: sin((_wiggleController.value + 0.25) * 2 * pi) * 0.1,
                                      child: Text('🏥', style: TextStyle(fontSize: isIPhone12Mini ? 24 : 28)),
                                    );
                                  },
                                ),
                                AnimatedBuilder(
                                  animation: _wiggleController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: sin((_wiggleController.value + 0.5) * 2 * pi) * 0.1,
                                      child: Text('❤️', style: TextStyle(fontSize: isIPhone12Mini ? 24 : 28)),
                                    );
                                  },
                                ),
                                AnimatedBuilder(
                                  animation: _wiggleController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: sin((_wiggleController.value + 0.75) * 2 * pi) * 0.1,
                                      child: Text('👩‍⚕️', style: TextStyle(fontSize: isIPhone12Mini ? 24 : 28)),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: _getResponsivePadding(20)),
                    
                    // Reminders Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(_getResponsivePadding(20)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border(left: BorderSide(color: Colors.pink, width: 5)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Random reminders 📝',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(18),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 12),
                          
                          Text(
                            "• Don't forget to eat something!\n"
                            "• Hydrate or die-drate (sorry, dad joke 😅)\n"
                            "• You're doing great even when it's tough\n"
                            "• Take a breather if you can\n"
                            "• Someone's rooting for you! 📣",
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(16),
                              color: Colors.grey.shade600,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: 12),
                          
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFF0F8FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border(left: BorderSide(color: Color(0xFF87CEEB), width: 4)),
                            ),
                            child: Text(
                              quotes[_quoteIndex],
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(16),
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: _getResponsivePadding(20)),
                    
                    // Encouragement Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(_getResponsivePadding(20)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border(left: BorderSide(color: Colors.pink, width: 5)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Need a little boost?',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(18),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 12),
                          
                          Text(
                            "I tried to think of what might help during those crazy long shifts, so I made this little love button for whenever you need a reminder of how absolutely incredible you are...",
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(16),
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: 16),
                          
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pink.withOpacity(0.3 + _glowController.value * 0.4),
                                      blurRadius: 15 + _glowController.value * 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _showEncouragementMessage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pink,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _getResponsivePadding(24), 
                                      vertical: _getResponsivePadding(12)
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 8,
                                  ),
                                  child: Text(
                                    '💕 Send me some love! ✨',
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(16),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    if (_showEncouragement) ...[
                      SizedBox(height: _getResponsivePadding(20)),
                      
                      Container(
                        key: _encouragementKey,
                        width: double.infinity,
                        padding: EdgeInsets.all(_getResponsivePadding(20)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.pink.shade50, Colors.purple.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(color: Colors.pink.withOpacity(0.3), width: 2),
                        ),
                        child: Column(
                          children: [
                            // Fixed header row for encouragement message
                            Container(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('💕', style: TextStyle(fontSize: 20)),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'A message from your boyfriend',
                                          style: TextStyle(
                                            fontSize: _getResponsiveFontSize(18),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pink.shade700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('💕', style: TextStyle(fontSize: 20)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.pink.withOpacity(0.2)),
                              ),
                              child: Text(
                                encouragements[_encouragementIndex],
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(16),
                                  color: Colors.grey.shade700,
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            SizedBox(height: 12),
                            
                            // Fixed bottom emoji row with proper constraints
                            Container(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: screenWidth * 0.04, // Dynamic spacing based on screen width
                                children: [
                                  Text('💖', style: TextStyle(fontSize: isIPhone12Mini ? 18 : 20)),
                                  Text('✨', style: TextStyle(fontSize: isIPhone12Mini ? 18 : 20)),
                                  Text('🌟', style: TextStyle(fontSize: isIPhone12Mini ? 18 : 20)),
                                  Text('💫', style: TextStyle(fontSize: isIPhone12Mini ? 18 : 20)),
                                  Text('💖', style: TextStyle(fontSize: isIPhone12Mini ? 18 : 20)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    SizedBox(height: _getResponsivePadding(30)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}