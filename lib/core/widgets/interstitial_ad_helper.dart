import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:partt/core/services/admob_service.dart';

class InterstitialAdHelper {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;
  static int _loadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  // Load an interstitial ad
  static void loadAd({VoidCallback? onAdLoaded}) {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId,
      request: AdMobService.getAdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Interstitial ad loaded');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _loadAttempts = 0;

          // Set up full screen content callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('Interstitial ad showed full screen');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Interstitial ad dismissed');
              ad.dispose();
              _isAdLoaded = false;
              _interstitialAd = null;
              // Preload next ad
              loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('❌ Interstitial ad failed to show: $error');
              ad.dispose();
              _isAdLoaded = false;
              _interstitialAd = null;
            },
            onAdImpression: (ad) {
              debugPrint('Interstitial ad impression recorded');
            },
          );

          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Interstitial ad failed to load: $error');
          _loadAttempts++;
          _isAdLoaded = false;
          _interstitialAd = null;

          // Retry loading if under max attempts
          if (_loadAttempts < _maxLoadAttempts) {
            debugPrint('Retrying interstitial ad load (attempt $_loadAttempts)');
            Future.delayed(const Duration(seconds: 2), () {
              loadAd(onAdLoaded: onAdLoaded);
            });
          }
        },
      ),
    );
  }

  // Show the interstitial ad if loaded
  static Future<void> showAd({VoidCallback? onAdClosed}) async {
    if (_isAdLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
      onAdClosed?.call();
    } else {
      debugPrint('⚠️ Interstitial ad not ready to show');
      onAdClosed?.call();
      // Try to load an ad for next time
      loadAd();
    }
  }

  // Check if ad is ready
  static bool get isAdReady => _isAdLoaded && _interstitialAd != null;

  // Dispose the ad
  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    _loadAttempts = 0;
  }
}
