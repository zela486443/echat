import 'package:shared_preferences/shared_preferences.dart';

class StarsService {
  static const String _starsKey = 'echat_stars_balance';

  Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 100 as per web app's giftsService.ts
    return prefs.getInt(_starsKey) ?? 100;
  }

  Future<void> addStars(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getBalance();
    await prefs.setInt(_starsKey, current + amount);
  }

  Future<bool> deductStars(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getBalance();
    if (current < amount) return false;
    await prefs.setInt(_starsKey, current - amount);
    return true;
  }
}
