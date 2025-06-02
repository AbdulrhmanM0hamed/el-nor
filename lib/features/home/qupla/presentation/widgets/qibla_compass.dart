import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblaDirection extends StatefulWidget {
  const QiblaDirection({Key? key}) : super(key: key);

  @override
  State<QiblaDirection> createState() => _QiblaDirectionState();
}

class _QiblaDirectionState extends State<QiblaDirection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double begin = 0.0;
  double? _qiblaDirection;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _getLocationAndCalculateQibla();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getLocationAndCalculateQibla() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // التحقق من أذونات الموقع
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'تم رفض إذن الموقع';
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'تم رفض إذن الموقع بشكل دائم، يرجى تمكينه من إعدادات الجهاز';
        });
        return;
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      // إحداثيات الكعبة المشرفة (مكة المكرمة)
      const double kaabaLatitude = 21.4225;
      const double kaabaLongitude = 39.8262;

      // حساب اتجاه القبلة
      double direction = _calculateQiblaDirection(
        userLatitude, 
        userLongitude, 
        kaabaLatitude, 
        kaabaLongitude
      );

      setState(() {
        _qiblaDirection = direction;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ: $e';
      });
    }
  }

  double _calculateQiblaDirection(double lat1, double lon1, double lat2, double lon2) {
    // تحويل الإحداثيات من درجات إلى راديان
    lat1 = pi * lat1 / 180.0;
    lon1 = pi * lon1 / 180.0;
    lat2 = pi * lat2 / 180.0;
    lon2 = pi * lon2 / 180.0;

    // حساب الاتجاه باستخدام صيغة الدائرة العظمى
    double y = sin(lon2 - lon1) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - 
              sin(lat1) * cos(lat2) * cos(lon2 - lon1);
    
    // حساب الزاوية بالراديان
    double bearing = atan2(y, x);
    
    // تحويل من راديان إلى درجات مئوية
    double bearingDegrees = bearing * 180.0 / pi;
    
    // تحويل من -180 ~ 180 إلى 0 ~ 360
    return (bearingDegrees + 360.0) % 360.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _getLocationAndCalculateQibla,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return _qiblaDirection != null
        ? QiblahStreamBuilder(
            animationController: _animationController,
            begin: begin,
            qiblaDirection: _qiblaDirection!,
          )
        : const Center(child: Text('Unable to determine Qiblah direction'));
  }
}

class QiblahStreamBuilder extends StatefulWidget {
  final AnimationController animationController;
  final double begin;
  final double qiblaDirection;

  const QiblahStreamBuilder({
    Key? key,
    required this.animationController,
    required this.begin,
    required this.qiblaDirection,
  }) : super(key: key);

  @override
  State<QiblahStreamBuilder> createState() => _QiblahStreamBuilderState();
}

class _QiblahStreamBuilderState extends State<QiblahStreamBuilder> {
  late Animation<double> animation;
  double begin = 0.0;

  @override
  void initState() {
    super.initState();
    begin = widget.begin;
    animation = Tween(begin: begin, end: begin).animate(widget.animationController);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final compassEvent = snapshot.data;
        if (compassEvent == null) {
          return const Center(child: Text('Unable to fetch Qiblah direction'));
        }

        // حساب اتجاه القبلة بالنسبة للشمال المغناطيسي
        double heading = compassEvent.heading! * (pi / 180);
        double qiblaAngle = widget.qiblaDirection * (pi / 180);

        // تحديث الرسوم المتحركة
        animation = Tween(
          begin: begin,
          end: qiblaAngle - heading,
        ).animate(widget.animationController);

        begin = qiblaAngle - heading;
        widget.animationController.forward(from: 0);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${compassEvent.heading!.toInt()}°',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontFamily: 'Rubik',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
              SizedBox(
                height: 300,
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: animation.value,
                      child: Image.asset('assets/images/qiblahImage.png'),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
            ],
          ),
        );
      },
    );
  }
}
