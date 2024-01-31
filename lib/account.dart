import 'package:firebase_auth/firebase_auth.dart';

class Account {

   //its a class that make a simple model of sign in signout system
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? get currentUser => _auth.currentUser;
    Stream<User?> get authStateChanges => _auth.authStateChanges();

    Future<void> signInWithEmailAndPassword({
      required String email,
      required String password}) async {
        await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
        );
      }

    Future<void> signOut() async {
    await _auth.signOut();
  
}
}