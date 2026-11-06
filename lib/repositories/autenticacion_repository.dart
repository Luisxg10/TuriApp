import 'package:firebase_auth/firebase_auth.dart';

class AutenticacionRepository {
  AutenticacionRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Stream<User?> get cambiosDeSesion => _firebaseAuth.authStateChanges();

  User? get usuarioActual => _firebaseAuth.currentUser;

  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: correo.trim(),
      password: contrasena,
    );
  }

  Future<void> registrar({
    required String correo,
    required String contrasena,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: correo.trim(),
      password: contrasena,
    );
  }

  Future<void> enviarRestablecimiento(String correo) async {
    await _firebaseAuth.sendPasswordResetEmail(email: correo.trim());
  }

  Future<void> cerrarSesion() => _firebaseAuth.signOut();
}
