import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions have not been configured for web.',
      );
    }
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfk_Z1WzIBaaS1FwBwZQj5kDjDvZEzyfA',
    appId: '1:139309390784:android:afaf36d8cb13354d620625',
    messagingSenderId: '139309390784',
    projectId: 'reels-2519d',
    storageBucket: 'reels-2519d.firebasestorage.app',
  );
}