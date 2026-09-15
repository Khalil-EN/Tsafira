/*import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  late RewardedAd _rewardedAd;
  bool _isRewardedAdReady = false;

  void loadRewardedAd(Function(bool watchedFullAd) onAdFinished) {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Test ID, replace with real
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;

          _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              print('Ad dismissed');
              // If reward not earned, user skipped
              onAdFinished(false);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              print('Failed to show ad: $error');
              onAdFinished(false);
            },
          );

          _rewardedAd.setImmersiveMode(true);
          _rewardedAd.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
              print('User earned reward: ${reward.amount} ${reward.type}');
              onAdFinished(true); // Ad fully watched
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          onAdFinished(false);
        },
      ),
    );
  }
}*/
