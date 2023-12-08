import 'package:firebase_auth/firebase_auth.dart';

class Utils {
  static String? getCurrentUserId()  {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }
}
