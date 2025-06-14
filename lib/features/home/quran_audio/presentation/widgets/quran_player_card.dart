import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../data/models/quran_reciter_model.dart';
import '../../../../../core/utils/theme/app_colors.dart';

class QuranPlayerCard extends StatefulWidget {
  final QuranCollection collection;

  const QuranPlayerCard({
    Key? key,
    required this.collection,
  }) : super(key: key);

  @override
  State<QuranPlayerCard> createState() => _QuranPlayerCardState();
}

class _QuranPlayerCardState extends State<QuranPlayerCard> {
  late AudioPlayer _audioPlayer;
  QuranSurah? _currentSurah;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _playNextSurah();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playNextSurah() async {
    if (_currentSurah == null) {
      _currentSurah = widget.collection.surahs.first;
    } else {
      final currentIndex = widget.collection.surahs.indexOf(_currentSurah!);
      if (currentIndex < widget.collection.surahs.length - 1) {
        _currentSurah = widget.collection.surahs[currentIndex + 1];
      } else {
        _currentSurah = widget.collection.surahs.first;
      }
    }
    await _playSurah(_currentSurah!);
  }

  Future<void> _playSurah(QuranSurah surah) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(surah.url),
          tag: MediaItem(
            id: surah.order.toString(),
            title: surah.formattedName,
            artist: widget.collection.shortDescription,
          ),
        ),
      );

      await _audioPlayer.play();
      setState(() {
        _currentSurah = surah;
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // تحسين رسالة الخطأ
      String errorMessage = 'خطأ في تشغيل السورة';
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection') || 
          e.toString().contains('network')) {
        errorMessage = 'خطأ في الاتصال بالإنترنت، تأكد من اتصالك وحاول مرة أخرى';
      } else if (e.toString().contains('404') || 
                e.toString().contains('not found')) {
        errorMessage = 'الملف الصوتي غير متوفر حاليًا';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'حسنًا',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_currentSurah == null) {
        await _playNextSurah();
      } else {
        await _audioPlayer.play();
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.collection.title,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              _currentSurah?.formattedName ?? 'اختر سورة للاستماع',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.logoTeal),
                  )
                else
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle : Icons.play_circle,
                      color: AppColors.logoTeal,
                      size: screenWidth * 0.08,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                IconButton(
                  icon: Icon(
                    Icons.skip_next,
                    color: AppColors.logoTeal,
                    size: screenWidth * 0.06,
                  ),
                  onPressed: _playNextSurah,
                ),
              ],
            ),
          ),
          if (_currentSurah != null) ...[
            const Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
              child: StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _audioPlayer.duration ?? Duration.zero;
                  
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: duration.inSeconds > 0
                            ? position.inSeconds / duration.inSeconds
                            : 0,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.logoTeal,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}