import 'package:flutter/material.dart';
import 'package:flutter_application/core/config/roble_config.dart';
import 'package:dio/dio.dart';

class RobleTestScreen extends StatefulWidget {
  @override
  _RobleTestScreenState createState() => _RobleTestScreenState();
}

class _RobleTestScreenState extends State<RobleTestScreen> {
  String testResult = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test ROBLE API'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Configuración ROBLE:', 
                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Base URL: ${RobleConfig.baseUrl}'),
                    Text('DB Name: ${RobleConfig.dbName}'),
                    Text('Login URL: ${RobleConfig.baseUrl}${RobleConfig.loginEndpoint}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            Row(
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : _testBasicConnection,
                  child: Text('Test Conexión Básica'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isLoading ? null : _testLogin,
                  child: Text('Test Login'),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            if (isLoading)
              Center(child: CircularProgressIndicator()),
            
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(testResult.isEmpty ? 'Presiona un botón para hacer test...' : testResult),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testBasicConnection() async {
    setState(() {
      isLoading = true;
      testResult = 'Testing conexión básica...\n';
    });

    try {
      final dio = Dio();
      final response = await dio.get('${RobleConfig.baseUrl}/health');
      
      setState(() {
        testResult += 'SUCCESS: Servidor responde\n';
        testResult += 'Status: ${response.statusCode}\n';
        testResult += 'Data: ${response.data}\n';
      });
    } catch (e) {
      setState(() {
        testResult += 'ERROR en conexión básica: $e\n';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _testLogin() async {
    setState(() {
      isLoading = true;
      testResult = 'Testing login endpoint...\n';
    });

    try {
      final dio = Dio();
      
      // Test con credenciales de prueba
      final response = await dio.post(
        '${RobleConfig.baseUrl}${RobleConfig.loginEndpoint}',
        data: {
          'email': 'test@test.com',
          'password': 'test123'
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      setState(() {
        testResult += 'SUCCESS: Login endpoint responde\n';
        testResult += 'Status: ${response.statusCode}\n';
        testResult += 'Data: ${response.data}\n';
      });
    } on DioException catch (e) {
      setState(() {
        testResult += 'DioException en login:\n';
        testResult += 'Status: ${e.response?.statusCode}\n';
        testResult += 'Message: ${e.message}\n';
        testResult += 'Response: ${e.response?.data}\n';
      });
    } catch (e) {
      setState(() {
        testResult += 'ERROR inesperado: $e\n';
      });
    }

    setState(() {
      isLoading = false;
    });
  }
}