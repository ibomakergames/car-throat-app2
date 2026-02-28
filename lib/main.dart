import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const CarThroatApp());
}

class CarThroatApp extends StatelessWidget {
  const CarThroatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAR THROAT',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  int _loadingProgress = 0;
  
  final String _adUnitIdAndroid = 'ca-app-pub-7832824627179138/1234567890';
  final String _adUnitIdiOS = 'ca-app-pub-7832824627179138/0987654321';

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _loadingProgress += 2;
      });
      if (_loadingProgress >= 100) {
        timer.cancel();
        _loadAd();
      }
    });
  }

  void _loadAd() {
    String adUnitId = Platform.isAndroid ? _adUnitIdAndroid : _adUnitIdiOS;
    
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          setState(() {
            _isAdLoaded = true;
          });
          Timer(const Duration(milliseconds: 500), () {
            _showInterstitialAd();
          });
        },
        onAdFailedToLoad: (error) {
          print('Ad failed to load: ${error.message}');
          Timer(const Duration(seconds: 1), () {
            _goToMainScreen();
          });
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _goToMainScreen();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _goToMainScreen();
        },
      );
      
      _interstitialAd!.show();
    } else {
      _goToMainScreen();
    }
  }

  void _goToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFFE1BE78).withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'CAR THROAT',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFFE1BE78),
                  letterSpacing: 10,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'ANTI MOTION SICKNESS',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFE1BE78),
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 120,
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xFFE1BE78), Colors.transparent],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                'Crafted by',
                style: TextStyle(fontSize: 12, color: Colors.white54, letterSpacing: 3),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ibrahim Alhusseini',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFE1BE78),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 60),
              Container(
                width: 200,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _loadingProgress / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1BE78),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isAdLoaded ? 'Loading ad...' : 'Loading...',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isDarkMode = true;
  bool isFloatingMode = false;
  double gyroSensitivity = 60;
  double responseSpeed = 75;
  double currentSpeed = 45;
  StreamSubscription? _gyroscopeSubscription;

  @override
  void initState() {
    super.initState();
    _initGyroscope();
  }

  void _initGyroscope() {
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      double intensity = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      setState(() {
        currentSpeed = (intensity * 10).clamp(0, 120);
      });
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1a1a2e) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 20),
                    _buildToggleSection(),
                    const SizedBox(height: 20),
                    _buildControlsSection(),
                    const SizedBox(height: 20),
                    _buildContactSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isFloatingMode ? _buildFloatingWidget() : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
              : [const Color(0xFFfafafa), Colors.white],
        ),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? const Color(0xFFE1BE78).withOpacity(0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _showMenu(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFFE1BE78).withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(),
                  const SizedBox(height: 4),
                  _buildDot(),
                  const SizedBox(height: 4),
                  _buildDot(),
                ],
              ),
            ),
          ),
          Text(
            'CAR THROAT',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? const Color(0xFFE1BE78) : const Color(0xFF1a1a2e),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFFE1BE78) : const Color(0xFF1a1a2e),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0f3460), Color(0xFF16213e)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0f3460).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE1BE78).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سرعة الحركة المكتشفة',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentSpeed.toInt().toString(),
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE1BE78),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'km/h',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode ? const Color(0xFFE1BE78).withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الوضع العائم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF1a1a2e),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'الظهور فوق التطبيقات الأخرى',
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.white54 : Colors.grey,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isFloatingMode = !isFloatingMode;
              });
            },
            child: Container(
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: isFloatingMode ? const Color(0xFFE1BE78) : (isDarkMode ? Colors.white24 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isFloatingMode ? [BoxShadow(color: const Color(0xFFE1BE78).withOpacity(0.3), blurRadius: 10)] : null,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: isFloatingMode ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isFloatingMode ? const Color(0xFF1a1a2e) : (isDarkMode ? Colors.white54 : Colors.white),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingWidget() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE1BE78), Color(0xFFC9A227)],
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE1BE78).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.water_drop,
        color: Color(0xFF1a1a2e),
        size: 35,
      ),
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? const Color(0xFFE1BE78).withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFE1BE78), Color(0xFFC9A227)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune, color: Color(0xFF1a1a2e), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'إعدادات الحساسية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? const Color(0xFFE1BE78) : const Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildSlider('حساسية الجيروسكوب', gyroSensitivity, (value) {
            setState(() => gyroSensitivity = value);
          }),
          Divider(color: isDarkMode ? Colors.white12 : Colors.grey.shade200, height: 40),
          _buildSlider('سرعة استجابة النقاط', responseSpeed, (value) {
            setState(() => responseSpeed = value);
          }),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE1BE78),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFE1BE78),
            inactiveTrackColor: isDarkMode ? Colors.white12 : Colors.grey.shade200,
            thumbColor: const Color(0xFFE1BE78),
            overlayColor: const Color(0xFFE1BE78).withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? const Color(0xFFE1BE78).withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? const Color(0xFFE1BE78) : const Color(0xFF1a1a2e),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  'Telegram',
                  '✈',
                  const LinearGradient(colors: [Color(0xFF0088cc), Color(0xFF0066aa)]),
                  'https://t.me/HH2J2',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildContactButton(
                  'Instagram',
                  '📷',
                  const LinearGradient(colors: [Color(0xFF833ab4), Color(0xFFfd1d1d), Color(0xFFf77737)]),
                  'https://www.instagram.com/3q635?igsh=YW5mcXVrZ2pjajA1',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(String label, String icon, Gradient gradient, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1a1a2e) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            border: Border(top: BorderSide(color: const Color(0xFFE1BE78).withOpacity(0.3))),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMenuItem(Icons.tune, 'إعدادات الحساسية'),
                _buildMenuItem(Icons.water_drop, 'مظهر النقاط'),
                _buildMenuItem(Icons.layers, 'الوضع العائم'),
                _buildMenuItem(
                  isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                  isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
                  onTap: () {
                    setState(() => isDarkMode = !isDarkMode);
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(Icons.info_outline, 'عن التطبيق'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String text, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE1BE78).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFE1BE78)),
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF1a1a2e),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}
