import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../models/day_consumption.dart';
import '../models/profile.dart';
import 'data_provider.dart';

class FirestoreDataProvider implements DataProvider {
  FirestoreDataProvider({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore? _firestore;
  bool _initialized = false;

  static const String _profileDocPath = 'profiles/default';
  static const String _consumptionCollection = 'consumption';

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firestore ??= FirebaseFirestore.instance;
    _initialized = true;
  }

  @override
  Future<Profile?> fetchProfile() async {
    await initialize();
    final doc = await _firestore!.doc(_profileDocPath).get();
    final data = doc.data();
    if (data == null) {
      return null;
    }
    return _profileFromMap(data);
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    await initialize();
    await _firestore!.doc(_profileDocPath).set(_profileToMap(profile));
  }

  @override
  Future<List<DayConsumption>> fetchHistory() async {
    await initialize();
    final snapshot = await _firestore!
        .collection(_consumptionCollection)
        .orderBy('date', descending: true)
        .limit(60)
        .get();
    return snapshot.docs
        .map((doc) => _dayConsumptionFromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> saveConsumption(DayConsumption day) async {
    await initialize();
    final normalized = _stripTime(day.dateTime);
    final docId = _docIdForDate(normalized);
    await _firestore!.collection(_consumptionCollection).doc(docId).set({
      'date': Timestamp.fromDate(normalized),
      'consumption': day.consumption,
      'dayGoal': day.dayGoal,
    }, SetOptions(merge: true));
  }

  Map<String, dynamic> _profileToMap(Profile profile) {
    return {
      'weightInKg': profile.weightInKg,
      'heightInCm': profile.heightInCm,
      'gender': profile.gender.name,
      'climate': profile.climate.name,
    };
  }

  Profile _profileFromMap(Map<String, dynamic> data) {
    final genderValue = data['gender'] as String?;
    final climateValue = data['climate'] as String?;
    return Profile(
      weightInKg: (data['weightInKg'] as num?)?.toInt() ?? 70,
      heightInCm: (data['heightInCm'] as num?)?.toInt() ?? 175,
      gender: Gender.values.firstWhere(
        (g) => g.name == genderValue,
        orElse: () => Gender.male,
      ),
      climate: Climate.values.firstWhere(
        (c) => c.name == climateValue,
        orElse: () => Climate.temperate,
      ),
    );
  }

  DayConsumption _dayConsumptionFromMap(Map<String, dynamic> data) {
    final timestamp = data['date'];
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      date = DateTime.now();
    }
    return DayConsumption(
      _stripTime(date),
      (data['consumption'] as num?)?.toDouble() ?? 0,
      (data['dayGoal'] as num?)?.toDouble() ?? 0,
    );
  }

  DateTime _stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _docIdForDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }
}
