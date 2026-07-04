import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform => android;

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDG8xzDdrV_3Uml_Hzuf6CP3-LDxppTisI',
    appId: '1:613338648473:android:57fea70fb736a0d2c4cd08',
    messagingSenderId: '613338648473',
    projectId: 'jsor-platform',
    storageBucket: 'jsor-platform.firebasestorage.app',
  );
}