import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  bool _isInitialized = false;
  
  // Test Ad Unit IDs (use these for testing)
  // Replace with your actual Ad Unit IDs before publishing
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Your actual Ad Unit IDs (replace with real IDs from AdMob console)
  static const String _androidBannerAdUnitId = 'ca-app-pub-3453955058123201/7401175652';
  static const String _androidInterstitialAdUnitId = 'ca-app-pub-3453955058123201/4775012316';
  static const String _androidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Not created yet, using test ID

  static const String _iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910';
  static const String _iosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';

  // Get appropriate ad unit IDs based on platform
  static String get bannerAdUnitId {
    // Always use real ads now that we have them configured
    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _iosBannerAdUnitId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    // Always use real ads now that we have them configured
    if (Platform.isAndroid) {
      return _androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _iosInterstitialAdUnitId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      return _testRewardedAdUnitId;
    }
    if (Platform.isAndroid) {
      return _androidRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return _iosRewardedAdUnitId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('AdMob already initialized');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('✅ AdMob initialized successfully');
      
      // Request configuration for better ad targeting
      final configuration = RequestConfiguration(
        testDeviceIds: ['TEST_DEVICE_ID'], // Add your test device ID here
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
      );
      MobileAds.instance.updateRequestConfiguration(configuration);
      
    } catch (e) {
      debugPrint('❌ Error initializing AdMob: $e');
      rethrow;
    }
  }

  bool get isInitialized => _isInitialized;

  // Create ad request
  static AdRequest getAdRequest() {
    return const AdRequest(
      keywords: ['job', 'employment', 'part-time', 'work', 'hiring'],
      nonPersonalizedAds: false,
    );
  }

  // Dispose method (if needed)
  void dispose() {
    _isInitialized = false;
  }
}
