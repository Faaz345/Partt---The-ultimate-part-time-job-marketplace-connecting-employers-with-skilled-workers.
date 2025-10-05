import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:partt/core/services/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final bool showErrorWidget;
  
  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.showErrorWidget = false,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _retryAttempt = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adUnitId = AdMobService.bannerAdUnitId;
    debugPrint('🔄 Loading banner ad (Attempt ${_retryAttempt + 1}/$_maxRetries)');
    debugPrint('📱 Using Ad Unit ID: $adUnitId');
    
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: widget.adSize,
      request: AdMobService.getAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner ad loaded successfully');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _hasError = false;
              _retryAttempt = 0;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner ad failed to load: ${error.code} - ${error.message}');
          debugPrint('   Domain: ${error.domain}');
          ad.dispose();
          
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _hasError = true;
              _errorMessage = error.message;
            });
            
            // Retry logic for specific errors
            if (_retryAttempt < _maxRetries && 
                (error.code == 0 || error.code == 3)) {
              _retryAttempt++;
              debugPrint('🔄 Retrying banner ad in 3 seconds...');
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  _loadAd();
                }
              });
            }
          }
        },
        onAdOpened: (ad) {
          debugPrint('📱 Banner ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('📱 Banner ad closed');
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If ad loaded successfully, show it
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    
    // If has error and max retries reached, show error or empty space
    if (_hasError && _retryAttempt >= _maxRetries) {
      if (widget.showErrorWidget) {
        return Container(
          height: widget.adSize.height.toDouble(),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.ad_units, color: Colors.grey[400], size: 24),
                const SizedBox(height: 4),
                Text(
                  'Ad not available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }
      // Return empty SizedBox if not showing error widget
      return const SizedBox.shrink();
    }
    
    // Show loading indicator while ad is loading
    return SizedBox(
      height: widget.adSize.height.toDouble(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading ad...',
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
