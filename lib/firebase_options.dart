// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAaK-1Qpe0bAyO1SOfMaHuxLiuc9V8uhKM",
    authDomain: "cam-sat-klima.firebaseapp.com",
    projectId: "cam-sat-klima",
    storageBucket: "cam-sat-klima.appspot.com",
    messagingSenderId: "931289080351",
    appId: "1:931289080351:web:c9331150db72e02cb7ab2a",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAaK-1Qpe0bAyO1SOfMaHuxLiuc9V8uhKM",
    appId: "1:931289080351:android:0a65bffb8fdc92e6b7ab2a",
    messagingSenderId: "931289080351",
    projectId: "cam-sat-klima",
    storageBucket: "cam-sat-klima.appspot.com",
  );
}
