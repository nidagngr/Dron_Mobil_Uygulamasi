import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

// Ana uygulama sınıfı
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Bildirim Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DroneNotificationPage(),
    );
  }
}

// Drone bildirim ana sayfa sınıfı
class DroneNotificationPage extends StatefulWidget {
  @override
  _DroneNotificationPageState createState() => _DroneNotificationPageState();
}

class _DroneNotificationPageState extends State<DroneNotificationPage> {
  List<NotificationItem> notifications = [];

  void _addNotification(String title, String description) {
    setState(() {
      notifications.add(NotificationItem(title: title, description: description));
    });
  }

  void _removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  Future<void> _fetchAnimalDetection() async {
    final url = 'http://raspberrypi.local/animal_detection'; // Raspberry Pi'den hayvan tespiti URL'si

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _addNotification('Hayvan Tespiti', data['description']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hayvan tespiti alınamadı')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  Future<void> _fetchHumanDetection() async {
    final url = 'http://raspberrypi.local/human_detection'; // Raspberry Pi'den insan tespiti URL'si

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _addNotification('İnsan Tespiti', data['description']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İnsan tespiti alınamadı')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  Future<void> _fetchLiveImage() async {
    final imageUrl = 'http://raspberrypi.local/live_image.jpg'; // Raspberry Pi'den anlık görüntü URL'si

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Uint8List imageBytes = response.bodyBytes;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationPage(
              location: 'Anlık Görüntü',
              imageBytes: imageBytes,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anlık görüntü alınamadı')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drone Bildirim Uygulaması', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF50C878),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () async {
                final location = 'Enlem: 40.7128, Boylam: -74.0060'; // Örnek konum bilgisi
                final imageUrl = 'http://raspberrypi.local/captured_image.jpg'; // Raspberry Pi'den görüntü URL'si

                try {
                  final response = await http.get(Uri.parse(imageUrl));
                  if (response.statusCode == 200) {
                    final Uint8List imageBytes = response.bodyBytes;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationPage(
                          location: location,
                          imageBytes: imageBytes,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Görüntü alınamadı')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bir hata oluştu: $e')),
                  );
                }
              },
              child: Text('Konumu Görüntüle', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFFFFF),
              ),
            ),
            SizedBox(height: 16),
            Text('Hareket Komutu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 16),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Color(0xFF50C878),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      left: 75,
                      child: _buildMovementButton(Icons.arrow_upward, () {}),
                    ),
                    Positioned(
                      top: 75,
                      left: 16,
                      child: _buildMovementButton(Icons.arrow_back, () {}),
                    ),
                    Positioned(
                      top: 75,
                      right: 16,
                      child: _buildMovementButton(Icons.arrow_forward, () {}),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 75,
                      child: _buildMovementButton(Icons.arrow_downward, () {}),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchLiveImage,
              child: Text('Anlık Görüntü Gönder', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFFFFF),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAnimalDetection,
              child: Text('Hayvan Tespiti Bildirimleri', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFFFFF),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchHumanDetection,
              child: Text('İnsan Tespiti Bildirimleri', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFFFFF),
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: notifications.asMap().entries.map((entry) {
                int index = entry.key;
                NotificationItem item = entry.value;
                return Dismissible(
                  key: Key(item.title + index.toString()),
                  onDismissed: (direction) {
                    _removeNotification(index);
                  },
                  child: item,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Icon(icon, color: Colors.black),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class LocationPage extends StatelessWidget {
  final String location;
  final Uint8List imageBytes;

  LocationPage({required this.location, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konum Bilgisi', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF50C878),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Konum: $location',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              SizedBox(height: 16),
              Image.memory(imageBytes),
            ],
          ),
        ),
      ),
    );
  }
}

// Bildirim öğesi sınıfı
class NotificationItem extends StatelessWidget {
  final String title;
  final String description;

  NotificationItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFFFFFFF),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.black),
          onPressed: () {
            // Bildirimi silmek için gereken işlemler
          },
        ),
      ),
    );
  }
}
