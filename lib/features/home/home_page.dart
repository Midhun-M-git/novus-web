import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'curved_divider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _bgAnimationController;
  late Animation<double> _bgScaleAnimation;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Background "Live Wallpaper" Animation
    _bgAnimationController = AnimationController(
      duration: const Duration(seconds: 20), // Slow breathing/zoom
      vsync: this,
    )..repeat(reverse: true);

    _bgScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bgAnimationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic styling based on scroll
    final isScrolled = _scrollOffset > 50;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: isScrolled ? Colors.white.withOpacity(0.8) : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    "NovusTech",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isScrolled ? const Color(0xFF0F172A) : Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      _navButton("Contact", isScrolled, () {
                         _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOut,
                        );
                      }),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Particles
          AnimatedBackground(
            behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
                baseColor: const Color(0xFF3B82F6),
                spawnMinSpeed: 10.0,
                spawnMaxSpeed: 40.0,
                spawnMinRadius: 2.0,
                spawnMaxRadius: 5.0,
                particleCount: 40,
                spawnOpacity: 0.1,
              ),
            ),
            vsync: this,
            child: const SizedBox.expand(),
          ),

          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeroSection(context),
                const CurvedDivider(color: Colors.white, height: 60), // Smooth transition
                _buildAboutSection(),
                _buildServicesSection(context),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(String title, bool isScrolled, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isScrolled ? const Color(0xFF0F172A) : Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height, // Full screen hero
      width: double.infinity,
      child: Stack(
        children: [
          // Live Wallpaper Effect: Animated Background Image
          Positioned.fill(
            child: RepaintBoundary( // Optimization: Isolates repaint layer for GPU
              child: AnimatedBuilder(
                animation: _bgAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bgScaleAnimation.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/neon.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF0F172A).withOpacity(0.3), // Light overlay top
                              const Color(0xFF0F172A).withOpacity(0.7), // Darker bottom for text
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Centered Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 800),
                    child: SlideAnimation(
                      verticalOffset: 30,
                      child: FadeInAnimation(
                        child: Text(
                          "Turning Vision Into\nDigital Reality",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 64, // Big, bold typography
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8), // Stronger shadow
                                offset: const Offset(0, 4),
                                blurRadius: 15,
                              ),
                              Shadow(
                                color: Colors.black.withOpacity(0.5), // Secondary shadow
                                offset: const Offset(0, 2),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 1000),
                    child: SlideAnimation(
                      verticalOffset: 30,
                      child: FadeInAnimation(
                        child: Text(
                          "We build next-gen IoT safety systems and scalable \nmobile & web solutions for forward-thinking startups,projects and organizations.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Buttons
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 1200),
                    child: FadeInAnimation(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPrimaryButton(context, "Get Started"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Scroll Indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withOpacity(0.6),
                size: 40,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, String text) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        onPressed: () => _showPricingDialog(context),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }



  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // Light Blue
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "WHO WE ARE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3B82F6),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Driven by Innovation,\nDefined by Quality.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -1.0,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              "NovusTech is a premier technology firm specializing in life-saving IoT solutions and high-performance digital products. We partner with visionaries to build scalable, beautifully engineered software and hardware ecosystems.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: const Color(0xFF64748B), // Slate 500
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC), // Slate 50
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      child: Column(
        children: [
          Text(
            "Our Expertise",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 60),
          
          AnimationLimiter(
            child: Wrap(
              spacing: 30,
              runSpacing: 30,
              alignment: WrapAlignment.center,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 600),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  _ServiceCard(
                    title: "Website Development",
                    description: "Stunning, high-performance websites tailored to your brand.",
                    icon: Icons.language_rounded,
                  ),
                   _ServiceCard(
                    title: "App Development",
                    description: "Native and cross-platform mobile applications for iOS and Android.",
                    icon: Icons.phone_iphone_rounded,
                  ),
                   _ServiceCard(
                    title: "IoT Solutions",
                    description: "Smart connected devices and industrial automation solutions.",
                    icon: Icons.memory_rounded,
                  ),
                   _ServiceCard(
                    title: "Cybersecurity",
                    description: "Protecting your digital assets with advanced security measures.",
                    icon: Icons.security_rounded,
                  ),
                   _ServiceCard(
                    title: "Project Mentoring",
                    description: "Guiding students and startups from concept to deployment.",
                    icon: Icons.lightbulb_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPricingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: 900, // Max width for desktop
          // Removed fixed height to allow wrapping content
          constraints: const BoxConstraints(maxHeight: 800),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Shrink to fit content
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Choose Your Path",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive Layout Logic
                      final isMobile = constraints.maxWidth < 600;
                      
                      final children = [
                        // Fixed Packages
                        _buildPricingOption(
                          title: "Standard Packages",
                          description: "Starts from ₹599\nPerfect for clear, defined scopes.",
                          features: const ["Web Starter Kit", "App MVP", "Maintenance Plans"],
                          color: const Color(0xFF3B82F6),
                          icon: Icons.grid_view_rounded,
                        ),
                        SizedBox(width: 24, height: isMobile ? 24 : 0), // Responsive spacing
                        // Custom
                        _buildPricingOption(
                          title: "Custom Solutions",
                          description: "Tailored engineering for complex needs.",
                          features: const ["IoT Ecosystems", "Enterprise SaaS", "Strategic Consulting"],
                          color: const Color(0xFF10B981),
                          icon: Icons.handyman_rounded,
                        ),
                      ];

                      return isMobile 
                          ? Column(children: children) 
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: children.map((c) => c is SizedBox ? c : Expanded(child: c)).toList(),
                            );
                    },
                  ),
                ),
              ),

              // Footer Actions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                   color: Colors.grey.shade50,
                   borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _launchURL("https://wa.me/917907194007"),
                      icon: const Icon(Icons.chat_bubble, color: Colors.white),
                      label: const Text("Chat on WhatsApp", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: Color(0xFF0F172A)),
                      ),
                      onPressed: () => _launchURL("mailto:techwithnovus@gmail.com"),
                      icon: const Icon(Icons.email_outlined, color: Color(0xFF0F172A)),
                      label: const Text("Send Email", style: TextStyle(fontSize: 15, color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingOption({
    required String title,
    required String description,
    required List<String> features,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: color),
          const SizedBox(height: 24),
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 12),
          Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          const SizedBox(height: 32),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: color, size: 20),
                const SizedBox(width: 8),
                Text(f, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      debugPrint('Could not launch \$url');
    }
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      color: const Color(0xFF0F172A), // Slate 900
      child: Column(
        children: [
          const Text(
            "NovusTech",
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.white
            ),
          ),
          const SizedBox(height: 30),
          
          // Added Contact Options in Footer
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _launchURL("https://wa.me/917907194007"),
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
                label: const Text(
                  "WhatsApp",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              TextButton.icon(
                onPressed: () => _launchURL("mailto:techwithnovus@gmail.com"),
                icon: const Icon(Icons.email_outlined, color: Colors.white70),
                label: const Text(
                  "Email Us",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          Text(
            "© 2026 All Rights Reserved",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 350,
        height: 280, // Standardized Height for Alignment
        padding: const EdgeInsets.all(32),
        transform: Matrix4.translationValues(0, _isHovered ? -10 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? const Color(0xFF3B82F6).withOpacity(0.2) 
                  : Colors.black.withOpacity(0.05),
              blurRadius: _isHovered ? 30 : 10,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: _isHovered ? const Color(0xFF3B82F6).withOpacity(0.3) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isHovered ? const Color(0xFF3B82F6) : const Color(0xFFEFF6FF),
                shape: BoxShape.circle, // Circular Icon background is more standard
              ),
              child: Icon(
                widget.icon,
                size: 28,
                color: _isHovered ? Colors.white : const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
