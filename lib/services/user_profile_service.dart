
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Enum to represent the subscription tiers
enum SubscriptionTier {
  none,
  gold,
  diamond,
  vip,
}

class UserProfileService with ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();

  factory UserProfileService() {
    return _instance;
  }

  UserProfileService._internal() {
    _listenToUserProfile();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<DocumentSnapshot>? _userProfileSubscription;

  File? _image;
  File? get image => _image;

  String _username = "Your Name";
  String get username => _username;

  String _age = "25";
  String get age => _age;

  String _location = "Unknown";
  String get location => _location;
  
  int _coins = 0;
  int get coins => _coins;

  SubscriptionTier _subscriptionTier = SubscriptionTier.none;
  SubscriptionTier get subscriptionTier => _subscriptionTier;

  final List<File> _userPhotos = [];
  List<File> get userPhotos => _userPhotos;

  void _listenToUserProfile() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _userProfileSubscription?.cancel();
        _userProfileSubscription = _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            _username = data['username'] ?? _username;
            _age = data['age']?.toString() ?? _age;
            _location = data['location'] ?? _location;
            _coins = data['coins'] ?? _coins;
            _subscriptionTier = _mapStringToSubscriptionTier(data['subscriptionTier']);
            notifyListeners();
          }
        });
      } else {
        _userProfileSubscription?.cancel();
      }
    });
  }

  SubscriptionTier _mapStringToSubscriptionTier(String? tierString) {
    switch (tierString) {
      case 'gold':
        return SubscriptionTier.gold;
      case 'diamond':
        return SubscriptionTier.diamond;
      case 'vip':
        return SubscriptionTier.vip;
      default:
        return SubscriptionTier.none;
    }
  }

  void setImage(File image) {
    _image = image;
    notifyListeners();
  }

  Future<void> setProfile(String newName, String newAge, String newLocation) async {
    _username = newName;
    _age = newAge;
    _location = newLocation;
    notifyListeners();
  }

  Future<void> addUserPhoto(File image) async {
    if (_userPhotos.length < 3) {
      _userPhotos.add(image);
      notifyListeners();
    }
  }

  // This method is now handled by the stream
  // void setSubscriptionTier(SubscriptionTier tier) {
  //   _subscriptionTier = tier;
  //   notifyListeners();
  // }

  @override
  void dispose() {
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}
