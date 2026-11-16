import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForTestingPurposesOnly123456',
    appId: '1:123456789000:web:abcdef',
    messagingSenderId: '123456789000',
    projectId: 'glamfit-sample',
    authDomain: 'glamfit-sample.firebaseapp.com',
    storageBucket: 'glamfit-sample.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForTestingPurposesOnly123456',
    appId: '1:123456789000:android:abcdef123456',
    messagingSenderId: '123456789000',
    projectId: 'glamfit-sample',
    storageBucket: 'glamfit-sample.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForTestingPurposesOnly123456',
    appId: '1:123456789000:ios:abcdef123456',
    messagingSenderId: '123456789000',
    projectId: 'glamfit-sample',
    storageBucket: 'glamfit-sample.appspot.com',
    iosBundleId: 'com.elegancegowns.eleganceGowns',
  );
}
