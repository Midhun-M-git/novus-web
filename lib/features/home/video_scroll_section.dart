import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScrollSection extends StatefulWidget {
  final double scrollProgress; // 0.0 to 1.0 over the video section
  final VoidCallback onGetStarted;

  const VideoScrollSection({
    super.key,
    required this.scrollProgress,
    required this.onGetStarted,
  });

  @override
  State<VideoScrollSection> createState() => _VideoScrollSectionState();
}

class _VideoScrollSectionState extends State<VideoScrollSection>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  double _lastTargetProgress = -1.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/video/scroll_video.mp4');
      await _controller!.initialize();
      await _controller!.setVolume(0.0);
      await _controller!.setLooping(false);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _updateVideoPosition();
      }
    } catch (e) {
      debugPrint("Error loading scroll video: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant VideoScrollSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollProgress != widget.scrollProgress) {
      _updateVideoPosition();
    }
  }

  void _updateVideoPosition() {
    if (_controller == null || !_isInitialized) return;
    
    final progress = widget.scrollProgress.clamp(0.0, 1.0);
    // Avoid redundant seeking if change is tiny
    if ((progress - _lastTargetProgress).abs() < 0.005) return;
    _lastTargetProgress = progress;

    final duration = _controller!.value.duration;
    if (duration.inMilliseconds > 0) {
      final targetMs = (duration.inMilliseconds * progress).round();
      _controller!.seekTo(Duration(milliseconds: targetMs));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final progress = widget.scrollProgress.clamp(0.0, 1.0);

    return SizedBox(
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          // 1. Video Player Background / Canvas Fallback
          Positioned.fill(
            child: _isInitialized && _controller != null
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width > 0
                            ? _controller!.value.size.width
                            : size.width,
                        height: _controller!.value.size.height > 0
                            ? _controller!.value.size.height
                            : size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  )
                : _buildFallbackBackground(),
          ),

          // 2. Cinematic Gradient Overlay & Vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F172A).withOpacity(0.55),
                    const Color(0xFF0F172A).withOpacity(0.35),
                    const Color(0xFF0F172A).withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 3. Interactive Floating Glassmorphism Cards & Typography
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _buildStageContent(progress),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Floating HUD Scroll Scrub Progress Bar & Milestones
          Positioned(
            right: 24,
            top: size.height * 0.25,
            bottom: size.height * 0.25,
            child: _buildScrollTimelineHUD(progress),
          ),

          // 5. Bottom Scroll Arrow Prompt (Only visible in initial stage)
          if (progress < 0.15)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "SCROLL TO UNLOCK EXPERIENCE",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _pulseController.value * 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF3B82F6).withOpacity(0.2),
                              border: Border.all(
                                color: const Color(0xFF3B82F6).withOpacity(0.5),
                              ),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.2,
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF0F172A),
            Color(0xFF020617),
          ],
        ),
      ),
    );
  }

  Widget _buildStageContent(double progress) {
    if (progress < 0.28) {
      return _buildHeroStage(key: const ValueKey('stage_1'), progress: progress);
    } else if (progress < 0.58) {
      return _buildIoTStage(key: const ValueKey('stage_2'));
    } else if (progress < 0.82) {
      return _buildAppsStage(key: const ValueKey('stage_3'));
    } else {
      return _buildCtaStage(key: const ValueKey('stage_4'));
    }
  }

  Widget _buildHeroStage({required Key key, required double progress}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF60A5FA).withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: -2,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bolt, color: Color(0xFF60A5FA), size: 18),
              SizedBox(width: 8),
              Text(
                "DYNAMIC SCROLL ENGINE ACTIVE",
                style: TextStyle(
                  color: Color(0xFF93C5FD),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Main Headline with Gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF93C5FD), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            "Turning Vision Into\nDigital Reality",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 62,
              height: 1.08,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2.0,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Text(
            "We engineer next-gen IoT safety ecosystems, scalable web platforms, and mobile products for visionary startups.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.88),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 40),

        // CTA Button
        _buildGlowButton(
          label: "Get Started Now",
          icon: Icons.arrow_forward_rounded,
          onTap: widget.onGetStarted,
        ),
      ],
    );
  }

  Widget _buildIoTStage({required Key key}) {
    return _buildGlassCard(
      key: key,
      tag: "HARDWARE & IOT INNOVATION",
      title: "Smart Connected Safety & Edge Intelligence",
      description:
          "From embedded firmware and ESP32 microcontrollers to real-time LoRaWAN network integration, NovusTech bridges physical sensors directly to intelligent cloud dashboards.",
      highlights: [
        "Real-Time Sensor telemetry",
        "Edge AI & Automation",
        "Custom PCB & IoT Firmware",
        "Sub-second Alert Triggering",
      ],
      icon: Icons.memory_rounded,
      accentColor: const Color(0xFF10B981), // Emerald
    );
  }

  Widget _buildAppsStage({required Key key}) {
    return _buildGlassCard(
      key: key,
      tag: "WEB & MOBILE ENGINEERING",
      title: "Ultra-Fast Cross-Platform Apps & Cloud Web",
      description:
          "Crafting pixel-perfect Flutter apps and high-performance React/Next.js web applications built to scale effortlessly to millions of active users.",
      highlights: [
        "60FPS Fluid Animations",
        "Cross-Platform iOS, Android & Web",
        "Enterprise Microservices",
        "Bank-Grade Data Encryption",
      ],
      icon: Icons.developer_mode_rounded,
      accentColor: const Color(0xFF8B5CF6), // Purple
    );
  }

  Widget _buildCtaStage({required Key key}) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.65),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.25),
                blurRadius: 40,
                spreadRadius: -5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Color(0xFF60A5FA),
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Ready to Elevate Your Startup?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(
                  "Let's turn your breakthrough concept into enterprise-ready hardware and software.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              _buildGlowButton(
                label: "Schedule Consultation",
                icon: Icons.calendar_today_rounded,
                onTap: widget.onGetStarted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required Key key,
    required String tag,
    required String title,
    required String description,
    required List<String> highlights,
    required IconData icon,
    required Color accentColor,
  }) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.65),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: accentColor.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: -4,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    tag,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                description,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: highlights.map((h) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: accentColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          h,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlowButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, 6),
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
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollTimelineHUD(double progress) {
    final percent = (progress * 100).round();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Percentage Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
          ),
          child: Text(
            "$percent%",
            style: const TextStyle(
              color: Color(0xFF60A5FA),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Vertical Track
        Container(
          width: 4,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 160 * progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.8),
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
