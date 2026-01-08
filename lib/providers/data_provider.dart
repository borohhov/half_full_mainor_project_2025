import '../models/day_consumption.dart';
import '../models/profile.dart';

abstract class DataProvider {
  Future<void> initialize();
  Future<Profile?> fetchProfile();
  Future<void> saveProfile(Profile profile);
  Future<List<DayConsumption>> fetchHistory();
  Future<void> saveConsumption(DayConsumption day);
}
