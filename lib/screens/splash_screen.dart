import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:day_05_todo_list_ui/screens/todo_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _controller.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);
    
    await Future.delayed(const Duration(milliseconds: 2500));
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TodoScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E1E1E),
                    const Color(0xFF2C2C2C),
                    const Color(0xFF1E1E1E),
                  ]
                : [
                    const Color(0xFF6750A4),
                    const Color(0xFF9C27B0),
                    const Color(0xFF6750A4),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo Container
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.white.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 60,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Animated App Title
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              'TodoMaster',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Organize your life beautifully',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: isDark
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Animated Loading Indicator
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark
                                ? Colors.white.withOpacity(0.8)
                                : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Floating Particles Animation Widget
class FloatingParticles extends StatefulWidget {
  final bool isDark;
  
  const FloatingParticles({super.key, required this.isDark});

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  
  @override
  void initState() {
    super.initState();
    _initializeParticles();
  }
  
  void _initializeParticles() {
    _controllers = List.generate(6, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 3000 + (index * 500)),
        vsync: this,
      );
    });
    
    _animations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 1),
        end: const Offset(0, -1),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));
    }).toList();
    
    for (var controller in _controllers) {
      controller.repeat();
    }
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _animations.asMap().entries.map((entry) {
        int index = entry.key;
        Animation<Offset> animation = entry.value;
        
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Positioned(
              left: 50.0 + (index * 60),
              child: Transform.translate(
                offset: Offset(
                  0,
                  animation.value.dy * MediaQuery.of(context).size.height,
                ),
                child: Container(
                  width: 4 + (index % 3) * 2,
                  height: 4 + (index % 3) * 2,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}