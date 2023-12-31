// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
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
    apiKey: 'AIzaSyAwm20Rnt0_YmE5OWHvwma76Md8H3B5s6Q',
    appId: '1:918467237308:web:085b469d319c9e41ca87b9',
    messagingSenderId: '918467237308',
    projectId: 'doorapp2-6f309',
    authDomain: 'doorapp2-6f309.firebaseapp.com',
    storageBucket: 'doorapp2-6f309.appspot.com',
    measurementId: 'G-12WL3TERZG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_ERUa1irFoJ2yPHILWspfXfbVqO3wp5s',
    appId: '1:918467237308:android:73ed235629a20cfdca87b9',
    messagingSenderId: '918467237308',
    projectId: 'doorapp2-6f309',
    storageBucket: 'doorapp2-6f309.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQkTmMfxAlRRSwtbUW_6nwJvOwT--aFEg',
    appId: '1:918467237308:ios:d4bbb54cc98cb575ca87b9',
    messagingSenderId: '918467237308',
    projectId: 'doorapp2-6f309',
    storageBucket: 'doorapp2-6f309.appspot.com',
    androidClientId: '918467237308-hp9tnu5smsle9u5ja0e0gf9di847d244.apps.googleusercontent.com',
    iosClientId: '918467237308-avfddg1kppr098o3fogm9a2q77g2eaf9.apps.googleusercontent.com',
    iosBundleId: 'com.example.doorapp2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQkTmMfxAlRRSwtbUW_6nwJvOwT--aFEg',
    appId: '1:918467237308:ios:43857d77970b42f5ca87b9',
    messagingSenderId: '918467237308',
    projectId: 'doorapp2-6f309',
    storageBucket: 'doorapp2-6f309.appspot.com',
    androidClientId: '918467237308-hp9tnu5smsle9u5ja0e0gf9di847d244.apps.googleusercontent.com',
    iosClientId: '918467237308-5ef7p0dcov5n2orejrfotlfoatvt5bkg.apps.googleusercontent.com',
    iosBundleId: 'com.example.doorapp2.RunnerTests',
  );
}
