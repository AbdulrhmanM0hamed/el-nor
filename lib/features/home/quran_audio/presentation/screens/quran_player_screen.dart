import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../data/models/quran_reciter_model.dart';
import '../../../../../core/utils/theme/app_colors.dart';

enum RepeatMode {
  off,
  one,
  all,
}

class QuranPlayerScreen extends StatefulWidget {
  static const String routeName = '/quran-player';
  final QuranCollection collection;

  const QuranPlayerScreen({
    Key? key,
    required this.collection,
  }) : super(key: key);

  @override
  State<QuranPlayerScreen> createState() => _QuranPlayerScreenState();
}

class _QuranPlayerScreenState extends State<QuranPlayerScreen> {
  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;
  QuranSurah? _currentSurah;
  bool _isLoading = true;
  double currentSpeed = 1.0;
  RepeatMode _repeatMode = RepeatMode.off;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  Future<void> _setupAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    
    // Create playlist from all surahs
    _playlist = ConcatenatingAudioSource(
      children: widget.collection.surahs.map((surah) {
        return AudioSource.uri(
          Uri.parse(surah.url),
          tag: MediaItem(
            id: surah.order.toString(),
            title: surah.formattedName,
            artist: widget.collection.shortDescription,
            artUri: Uri.parse('asset:///assets/images/quran_bg.jpg'),
          ),
        );
      }).toList(),
    );

    try {
      await _audioPlayer.setAudioSource(_playlist);
      setState(() {
        _isLoading = false;
        _currentSurah = widget.collection.surahs.first;
      });

      // Listen to state changes
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _handlePlaybackCompletion();
        }
      });

      // Listen to current playing surah
      _audioPlayer.currentIndexStream.listen((index) {
        if (index != null && mounted) {
          setState(() {
            _currentSurah = widget.collection.surahs[index];
          });
        }
      });
    } catch (e) {
      debugPrint('Error loading audio source: $e');
    }
  }

  void _handlePlaybackCompletion() {
    if (_repeatMode == RepeatMode.one) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else if (_repeatMode == RepeatMode.all) {
      if (_audioPlayer.currentIndex == widget.collection.surahs.length - 1) {
        _audioPlayer.seek(Duration.zero, index: 0);
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.collection.title,
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.logoTeal,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Cover art and current surah info
                  Container(
                    height: 250.h, // تقليل الارتفاع لتجنب تجاوز البكسل
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.logoTeal,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60.r, // تقليل حجم الصورة أكثر
                          backgroundImage: const AssetImage('assets/images/mushaf_1.png'),
                        ),
                        SizedBox(height: 12.h), // تقليل المسافة
                        Text(
                          _currentSurah?.formattedName ?? '',
                          style: TextStyle(
                            fontSize: 20.sp, // تقليل حجم الخط
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6.h), // تقليل المسافة
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              widget.collection.description, // استخدام الوصف الكامل بدلاً من المختصر
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress bar
                  StreamBuilder<Duration>(
                    stream: _audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = _audioPlayer.duration ?? Duration.zero;
                      
                      return Column(
                        children: [
                          Slider(
                            value: position.inSeconds.toDouble(),
                            max: duration.inSeconds.toDouble(),
                            activeColor: AppColors.logoTeal,
                            onChanged: (value) {
                              _audioPlayer.seek(Duration(seconds: value.toInt()));
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(position)),
                                Text(_formatDuration(duration)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Playback controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _repeatMode == RepeatMode.off
                              ? Icons.repeat
                              : _repeatMode == RepeatMode.one
                                  ? Icons.repeat_one
                                  : Icons.repeat,
                          color: _repeatMode != RepeatMode.off
                              ? AppColors.logoTeal
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _repeatMode = RepeatMode.values[
                                (_repeatMode.index + 1) % RepeatMode.values.length];
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 32),
                        onPressed: () => _audioPlayer.seekToPrevious(),
                      ),
                      StreamBuilder<PlayerState>(
                        stream: _audioPlayer.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;

                          if (processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering) {
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              width: 64.0,
                              height: 64.0,
                              child: const CircularProgressIndicator(),
                            );
                          } else if (playing != true) {
                            return IconButton(
                              icon: const Icon(Icons.play_circle, size: 64),
                              onPressed: _audioPlayer.play,
                            );
                          } else {
                            return IconButton(
                              icon: const Icon(Icons.pause_circle, size: 64),
                              onPressed: _audioPlayer.pause,
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 32),
                        onPressed: () => _audioPlayer.seekToNext(),
                      ),
                      PopupMenuButton<double>(
                        icon: const Icon(Icons.speed),
                        onSelected: (speed) {
                          setState(() {
                            currentSpeed = speed;
                            _audioPlayer.setSpeed(speed);
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                          const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                          const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                          const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                          const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                          const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                        ],
                      ),
                    ],
                  ),

                  // Playlist
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.collection.surahs.length,
                      itemBuilder: (context, index) {
                        final surah = widget.collection.surahs[index];
                        return ListTile(
                          leading: Text(
                            '${surah.order}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          title: Text(
                            surah.formattedName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: _currentSurah?.order == surah.order
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _currentSurah?.order == surah.order
                                  ? AppColors.logoTeal
                                  : null,
                            ),
                          ),
                          subtitle: Text(surah.size),
                          onTap: () {
                            _audioPlayer.seek(Duration.zero, index: index);
                            _audioPlayer.play();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
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