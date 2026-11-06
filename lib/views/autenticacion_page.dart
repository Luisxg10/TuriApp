import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/autenticacion_repository.dart';
import '../repositories/administracion_catalogo_repository.dart';
import 'administracion_catalogo_page.dart';

class AutenticacionPage extends StatefulWidget {
  const AutenticacionPage({super.key});

  @override
  State<AutenticacionPage> createState() => _AutenticacionPageState();
}

class _AutenticacionPageState extends State<AutenticacionPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmacionController = TextEditingController();
  final _autenticacion = AutenticacionRepository();
  final _administracionCatalogo = AdministracionCatalogoRepository();

  bool _esRegistro = false;
  bool _cargando = false;
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmacionController.dispose();
    super.dispose();
  }

  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    try {
      if (_esRegistro) {
        await _autenticacion.registrar(
          correo: _correoController.text,
          contrasena: _contrasenaController.text,
        );
      } else {
        await _autenticacion.iniciarSesion(
          correo: _correoController.text,
          contrasena: _contrasenaController.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      _mostrarMensaje(_mensajeDeError(error));
    } catch (_) {
      _mostrarMensaje('Ocurrió un error. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _restablecerContrasena() async {
    final correo = _correoController.text.trim();
    if (correo.isEmpty || !correo.contains('@')) {
      _mostrarMensaje('Escribe un correo válido para recibir el enlace.');
      return;
    }

    setState(() => _cargando = true);
    try {
      await _autenticacion.enviarRestablecimiento(correo);
      _mostrarMensaje('Si el correo está registrado, recibirás un enlace.');
    } on FirebaseAuthException catch (error) {
      _mostrarMensaje(_mensajeDeError(error));
    } catch (_) {
      _mostrarMensaje('No se pudo enviar el correo. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cerrarSesion() async {
    setState(() => _cargando = true);
    try {
      await _autenticacion.cerrarSesion();
      _mostrarMensaje('Sesión cerrada.');
    } catch (_) {
      _mostrarMensaje('No se pudo cerrar la sesión.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  String _mensajeDeError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'too-many-requests':
        return 'Hubo demasiados intentos. Espera un momento e inténtalo otra vez.';
      case 'network-request-failed':
        return 'No hay conexión. Revisa tu internet e inténtalo de nuevo.';
      case 'operation-not-allowed':
        return 'El acceso por correo y contraseña no está habilitado en Firebase.';
      default:
        return 'No se pudo completar la operación. Intenta de nuevo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta')),
      body: StreamBuilder<User?>(
        stream: _autenticacion.cambiosDeSesion,
        builder: (context, snapshot) {
          final usuario = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (usuario != null) return _construirCuenta(usuario);
          return _construirFormulario();
        },
      ),
    );
  }

  Widget _construirCuenta(User usuario) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_circle,
              size: 88,
              color: Color(0xFF008577),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sesión iniciada',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(usuario.email ?? 'Correo no disponible'),
            const SizedBox(height: 24),
            FutureBuilder<bool>(
              future: _administracionCatalogo.esAdministrador(usuario.uid),
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdministracionCatalogoPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Administrar lugares'),
                  ),
                );
              },
            ),
            FilledButton.icon(
              onPressed: _cargando ? null : _cerrarSesion,
              icon: const Icon(Icons.logout),
              label: Text(_cargando ? 'Cerrando sesión…' : 'Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFormulario() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.travel_explore,
                  size: 72,
                  color: Color(0xFF008577),
                ),
                const SizedBox(height: 16),
                Text(
                  _esRegistro ? 'Crear cuenta' : 'Iniciar sesión',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    final correo = valor?.trim() ?? '';
                    if (correo.isEmpty || !correo.contains('@')) {
                      return 'Escribe un correo válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contrasenaController,
                  obscureText: _ocultarContrasena,
                  autofillHints: _esRegistro
                      ? const [AutofillHints.newPassword]
                      : const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _ocultarContrasena
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: () => setState(
                        () => _ocultarContrasena = !_ocultarContrasena,
                      ),
                      icon: Icon(
                        _ocultarContrasena
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (valor) {
                    if ((valor ?? '').length < 6) {
                      return 'Usa al menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                if (_esRegistro) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmacionController,
                    obscureText: _ocultarContrasena,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor != _contrasenaController.text) {
                        return 'Las contraseñas no coinciden.';
                      }
                      return null;
                    },
                  ),
                ],
                if (!_esRegistro)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _cargando ? null : _restablecerContrasena,
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _cargando ? null : _enviarFormulario,
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_esRegistro ? 'Crear cuenta' : 'Iniciar sesión'),
                ),
                TextButton(
                  onPressed: _cargando
                      ? null
                      : () => setState(() => _esRegistro = !_esRegistro),
                  child: Text(
                    _esRegistro
                        ? 'Ya tengo una cuenta: iniciar sesión'
                        : '¿No tienes cuenta? Crear una',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
