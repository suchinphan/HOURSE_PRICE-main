import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController minimartController = TextEditingController();

  bool loading = false;
  String? error;
  int? price;
  String? currency;

  Future<void> calculatePrice() async {
    final age = int.tryParse(ageController.text);
    final distance = int.tryParse(distanceController.text);
    final minimart = int.tryParse(minimartController.text);

    if (age == null || distance == null || minimart == null) {
      setState(() {
        error = 'กรุณากรอกข้อมูลให้ครบถ้วน';
        price = null;
        currency = null;
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
      price = null;
      currency = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/house'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'age': age,
          'distance': distance,
          'minimart': minimart,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          price = data['price'];
          currency = data['currency'];
        });
      } else {
        setState(() {
          error = 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์';
        });
      }
    } catch (e) {
      setState(() {
        error = 'ไม่สามารถเชื่อมต่อกับ API หรือเกิดข้อผิดพลาดในการดึงข้อมูล';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ประเมินราคาบ้าน',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'อายุบ้าน (ปี)',
                    border: OutlineInputBorder(),
                    hintText: '0 - 120',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: distanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ระยะทางถึง MRT (เมตร)',
                    border: OutlineInputBorder(),
                    hintText: '0 - 10000',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: minimartController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'จำนวนร้านสะดวกซื้อใกล้เคียง',
                    border: OutlineInputBorder(),
                    hintText: '0 - 20',
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading ? null : calculatePrice,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('คำนวณราคา', style: TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 16),

                if (error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.red[100],
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                if (price != null && currency != null)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border(left: BorderSide(color: Colors.green[700]!, width: 5)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'ราคาประเมินบ้าน',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.green),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${price!.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} $currency',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
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
