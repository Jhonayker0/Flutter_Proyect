import 'package:flutter/material.dart';
import 'package:flutter_application/core/config/roble_config.dart';
import 'package:flutter_application/core/services/roble_http_service.dart';
import 'package:flutter_application/auth/domain/models/auth_models.dart';

class NetworkDebugScreen extends StatefulWidget {
  @override
  _NetworkDebugScreenState createState() => _NetworkDebugScreenState();
}

class _NetworkDebugScreenState extends State<NetworkDebugScreen> {
  final RobleHttpService _httpService = RobleHttpService();
  String _debugInfo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debug ROBLE API')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuración ROBLE:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Base URL: ${RobleConfig.baseUrl}'),
            Text('DB Name: ${RobleConfig.dbName}'),
            Text('Login URL: ${RobleConfig.baseUrl}${RobleConfig.loginEndpoint}'),
            SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _testConnection,
              child: Text('Test Conexión'),
            ),
            
            SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                child: Text(_debugInfo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _debugInfo = 'Iniciando test de conexión...\n';
    });

    try {
      // Test básico de conexión
      _updateDebugInfo('📡 Testing conexión básica...');
      
      final testRequest = LoginRequest(
        email: 'test@uninorte.edu.co',
        password: 'test123',
      );

      await _httpService.login(testRequest);
      
    } catch (e) {
      _updateDebugInfo('❌ Error capturado: $e');
    }
  }

  void _updateDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
  }
}