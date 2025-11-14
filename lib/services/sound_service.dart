import 'dart:async';
import 'dart:io';
import 'package:just_audio_ohos/just_audio_ohos.dart';
import 'package:audio_session/audio_session.dart';

// Abstract class to define the audio interface
abstract class _AudioPlayerInterface {
  Future<void> play([dynamic source]);
  Future<void> stop();
  Future<void> setVolume(double volume);
  Future<void> setAudioSource(dynamic source);
  void dispose();
  Stream get onPlayerStateChanged;
  Stream get onPlayerComplete;
}

// Platform-specific implementations
class _SoundService {
  _AudioPlayerInterface? _player;
  bool _isAudioSupported = true;
  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  _SoundService() {
    // Don't initialize immediately - do lazy initialization
    _isInitialized = false;
  }

  /// Lazy initialization - only initialize when first needed
  Future<void> _ensureInitialized() async {
    // If already initialized, return immediately
    if (_isInitialized && _initCompleter == null) {
      return;
    }

    // If initialization is in progress, wait for it with timeout
    if (_initCompleter != null) {
      try {
        await _initCompleter!.future.timeout(const Duration(seconds: 10));
      } catch (e) {
        print('⚠️ Initialization timeout: $e');
        // Mark as initialized anyway to avoid hanging
        _isInitialized = true;
      }
      return;
    }

    // Start initialization
    _initCompleter = Completer<void>();
    try {
      await _initializeAudio().timeout(const Duration(seconds: 10));
      _isInitialized = true;
      _initCompleter!.complete();
      print('✅ Audio initialization completed');
    } catch (e) {
      print('❌ Audio initialization failed: $e');
      _isInitialized = true; // Mark as initialized to avoid hanging
      _isAudioSupported = false;
      _player = _NoOpAudioPlayer();
      _initCompleter!.completeError(e);
    } finally {
      _initCompleter = null;
    }
  }

  /// Platform detection: Check if running on HarmonyOS
  Future<bool> _isHarmonyOS() async {
    // Check 1: Platform operating system name
    if (Platform.operatingSystem.toLowerCase() == 'harmonyos') {
      print('✅ Detected HarmonyOS via Platform.operatingSystem');
      return true;
    }

    // Check 2a: System properties for HarmonyOS (if running on Android device)
    if (Platform.operatingSystem == 'android') {
      try {
        final result = await Process.run('getprop', ['ro.build.harmonyos']);
        if (result.exitCode == 0) {
          final output = result.stdout.toString().trim();
          if (output.isNotEmpty && output != '0' && output != 'false') {
            print('✅ Detected HarmonyOS via getprop: $output');
            return true;
          }
        }
      } catch (e) {
        // getprop command not available
      }

      // Check 2b: OS version string
      final version = Platform.operatingSystemVersion.toLowerCase();
      if (version.contains('harmonyos') || version.contains('harmony')) {
        print('✅ Detected HarmonyOS via version string');
        return true;
      }
    }

    // Platform is likely supported with just_audio
    return false;
  }

  Future<void> _initializeAudio() async {
    try {
      // Use just_audio_ohos for all platforms (works on HarmonyOS and should be compatible)
      _player = _JustAudioPlayerOhosImpl();
      print('✅ Audio initialized with just_audio_ohos');
      _isAudioSupported = true;
    } catch (e) {
      print('⚠️ Audio initialization failed: $e');
      _isAudioSupported = false;
      _player = _NoOpAudioPlayer();
    }

    _isInitialized = true;
  }

  /// Configure audio session for proper audio playback
  Future<void> _configureAudioSession() async {
    try {
      // Configure audio session with appropriate category and options
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      print('🔊 Audio session configured');

      // On HarmonyOS, we might need to activate the session differently
      final isHarmonyOS = await _isHarmonyOS();
      if (isHarmonyOS) {
        print('🔊 HarmonyOS detected - activating audio session');
        try {
          await session.setActive(true);
          print('🔊 Audio session activated for HarmonyOS');
        } catch (e) {
          print('⚠️ Failed to activate session on HarmonyOS: $e');
        }
      }
    } catch (e) {
      print('⚠️ Audio session configuration failed: $e');
      // Continue without audio session - just_audio will still work
    }
  }

  /// 播放数字声音文件
  Future<void> playNumberSound(int number) async {
    await _ensureInitialized();
    final soundPath = 'assets/sounds/num_$number.mp3';
    await _playSound(soundPath);
  }

  /// 播放倒计时声音
  Future<void> playCountdownSound() async {
    await _ensureInitialized();
    const soundPath = 'assets/sounds/gear.mp3';
    await _playSound(soundPath);
  }

  /// 播放完成声音
  Future<void> playCheerSound() async {
    await _ensureInitialized();
    const soundPath = 'assets/sounds/cheer.mp3';
    await _playSound(soundPath);
  }

  /// 播放咕嘟声音（休息中计时）
  Future<void> playGuduSound() async {
    await _ensureInitialized();
    const soundPath = 'assets/sounds/gudu.mp3';
    await _playSound(soundPath);
  }

  /// 播放休息开始声音
  Future<void> playRestStartSound() async {
    await _ensureInitialized();
    const soundPath = 'assets/sounds/rest-start.mp3';
    await _playSound(soundPath);
  }

  /// 播放开始声音
  Future<void> playStartSound() async {
    await _ensureInitialized();
    const soundPath = 'assets/sounds/start.mp3';
    await _playSound(soundPath);
  }

  /// 播放休息结束声音
  Future<void> playRestEndSound() async {
    await _ensureInitialized();
    const soundPath = 'assets/sounds/rest-end.mp3';
    await _playSound(soundPath);
  }

  /// 播放所有训练完成声音
  Future<void> playAllDoneSound() async {
    await _ensureInitialized();
    const soundPath = 'assets/sounds/all_done.mp3';
    await _playSound(soundPath);
  }

  /// 播放自定义声音文件
  Future<void> playCustomSound(String soundPath) async {
    await _ensureInitialized();
    await _playSound(soundPath);
  }

  /// 测试音频播放 - 用于调试
  Future<void> testAudioPlayback() async {
    print('🧪 开始音频测试...');
    await _ensureInitialized();

    // Test with a simple sound
    const testPath = 'assets/sounds/gear.mp3';
    print('🧪 测试播放: $testPath');

    try {
      await _playSound(testPath);
      print('🧪 音频测试完成');
    } catch (e) {
      print('🧪 音频测试失败: $e');
    }
  }

  /// 获取详细音频状态信息
  Future<Map<String, dynamic>> getAudioStatus() async {
    final status = <String, dynamic>{};

    try {
      final playerImpl = _player as _JustAudioPlayerOhosImpl;
      final player = playerImpl._player;
      status['isAudioSupported'] = _isAudioSupported;
      status['platform'] = Platform.operatingSystem;
      status['processingState'] = player.processingState.toString();
      status['playing'] = player.playing;
      status['volume'] = player.volume;
      status['speed'] = player.speed;
      status['position'] = player.position.inMilliseconds;
      status['duration'] = player.duration?.inMilliseconds;
    } catch (e) {
      status['error'] = e.toString();
    }

    return status;
  }

  /// 播放声音的通用方法
  Future<void> _playSound(String soundPath) async {
    if (!_isAudioSupported || _player == null) {
      print('🔇 Audio not supported on this platform: $soundPath');
      return;
    }

    try {
      // 使用同一个AudioPlayer实例，但先停止当前播放的声音
      await _player!.stop();

      // Create the asset source
      final assetSource = AudioSource.asset(soundPath);

      print('🔊 播放音频: $soundPath');

      // Load the audio source
      print('🔄 Loading audio source...');
      await _player!.setAudioSource(assetSource);
      print('✅ Audio source loaded');

      // Wait a moment for the duration to be available
      final playerImpl = _player as _JustAudioPlayerOhosImpl;
      final player = playerImpl._player;
      int waitCount = 0;
      while (player.duration == null && waitCount < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }

      if (player.duration != null) {
        print('✅ Audio duration available: ${player.duration!.inMilliseconds}ms');
      } else {
        print('⚠️ Audio duration not available after 5 seconds');
      }

      // Set volume to maximum for debugging
      await _player!.setVolume(1.0);
      print('🔊 Volume set to: 1.0');

      print('▶️ Starting playback...');
      await _player!.play();

      // 监听播放状态
      _player!.onPlayerStateChanged.listen((state) {
        print('🔊 音频状态: $state for $soundPath');
      });

      _player!.onPlayerComplete.listen((_) {
        print('🔊 音频播放完成: $soundPath');
      });

      // Log player details for debugging
      _logPlayerDetails();

    } catch (e) {
      print('❌ 音频播放失败: $soundPath, 错误: $e');
      print('❌ 错误详情: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
      _isAudioSupported = false;
      _player = _NoOpAudioPlayer();
    }
  }

  /// Log detailed player information for debugging
  Future<void> _logPlayerDetails() async {
    try {
      final playerImpl = _player as _JustAudioPlayerOhosImpl;
      final player = playerImpl._player;
      final processingState = player.processingState;
      final playing = player.playing;
      final volume = player.volume;
      final speed = player.speed;
      final position = player.position;
      final duration = player.duration;

      print('📊 Player State Debug:');
      print('   Processing State: $processingState');
      print('   Playing: $playing');
      print('   Volume: $volume (0.0-1.0)');
      print('   Speed: $speed');
      print('   Position: $position');
      print('   Duration: $duration');

      if (duration != null) {
        print('   Duration in seconds: ${duration.inSeconds}s');
      }
    } catch (e) {
      print('⚠️ Failed to log player details: $e');
    }
  }

  /// Request audio focus before playing audio
  Future<void> _requestAudioFocus() async {
    try {
      final session = await AudioSession.instance;
      print('🔊 Requesting audio focus...');
      final result = await session.setActive(true);
      if (result) {
        print('🔊 ✅ Audio focus acquired successfully');
      } else {
        print('⚠️ ⚠️ Failed to acquire audio focus (returned false)');
      }

      // Log current audio mode
      try {
        final androidAudioMode = session.androidAudioAttributes;
        print('🔊 Android audio attributes: $androidAudioMode');
      } catch (e) {
        // Not on Android, that's ok
      }
    } catch (e) {
      print('⚠️ Audio focus request failed: $e');
      // Continue without audio focus - some systems may not require it
    }
  }

  /// 停止所有正在播放的声音
  Future<void> stopAllSounds() async {
    if (_isAudioSupported && _player != null) {
      await _player!.stop();
    }
  }

  /// 释放所有资源
  void dispose() {
    if (_player != null) {
      _player!.dispose();
    }
  }

  /// 检查音频是否支持
  bool get isAudioSupported => _isAudioSupported;
}

// No-op implementation for platforms without audio support
class _NoOpAudioPlayer implements _AudioPlayerInterface {
  @override
  Future<void> play([source]) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> setAudioSource(source) async {}

  @override
  void dispose() {}

  @override
  Stream get onPlayerStateChanged => const Stream.empty();

  @override
  Stream get onPlayerComplete => const Stream.empty();
}

// Just Audio implementation for HarmonyOS (using just_audio_ohos)
class _JustAudioPlayerOhosImpl implements _AudioPlayerInterface {
  final AudioPlayer _player;

  _JustAudioPlayerOhosImpl()
      : _player = AudioPlayer(),
        super() {
    // Initialize HarmonyOS-specific player
    print('🔊 Initializing HarmonyOS audio player...');
  }

  @override
  Future<void> play([dynamic source]) async {
    if (source != null) {
      await _player.setAudioSource(source);
    }
    await _player.play();
    print('🔊 HarmonyOS audio playback started');
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    print('🔊 HarmonyOS audio playback stopped');
  }

  @override
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    print('🔊 HarmonyOS audio volume set to: $volume');
  }

  @override
  Future<void> setAudioSource(dynamic source) async {
    await _player.setAudioSource(source);
    print('🔊 HarmonyOS audio source set: $source');
  }

  @override
  void dispose() {
    _player.dispose();
    print('🔊 HarmonyOS audio player disposed');
  }

  @override
  Stream get onPlayerStateChanged {
    return _player.playerStateStream.map((state) {
      // Convert just_audio_ohos state to our format
      switch (state.processingState) {
        case ProcessingState.idle:
        case ProcessingState.loading:
          return 'loading';
        case ProcessingState.buffering:
          return 'buffering';
        case ProcessingState.ready:
          return 'playing';
        case ProcessingState.completed:
          return 'completed';
      }
    });
  }

  @override
  Stream get onPlayerComplete {
    return _player.playerStateStream.where((state) {
      return state.processingState == ProcessingState.completed;
    }).map((_) => null);
  }
}

// SoundService public interface - delegates to the appropriate implementation
class SoundService {
  static SoundService? _instance;
  static final _SoundService _delegate = _SoundService();

  // Singleton pattern to avoid creating multiple instances
  factory SoundService() {
    _instance ??= SoundService._();
    return _instance!;
  }

  SoundService._();

  /// 播放数字声音文件
  Future<void> playNumberSound(int number) => _delegate.playNumberSound(number);

  /// 播放倒计时声音
  Future<void> playCountdownSound() => _delegate.playCountdownSound();

  /// 播放完成声音
  Future<void> playCheerSound() => _delegate.playCheerSound();

  /// 播放咕嘟声音（休息中计时）
  Future<void> playGuduSound() => _delegate.playGuduSound();

  /// 播放休息开始声音
  Future<void> playRestStartSound() => _delegate.playRestStartSound();

  /// 播放开始声音
  Future<void> playStartSound() => _delegate.playStartSound();

  /// 播放休息结束声音
  Future<void> playRestEndSound() => _delegate.playRestEndSound();

  /// 播放所有训练完成声音
  Future<void> playAllDoneSound() => _delegate.playAllDoneSound();

  /// 播放自定义声音文件
  Future<void> playCustomSound(String soundPath) => _delegate.playCustomSound(soundPath);

  /// 测试音频播放 - 用于调试
  Future<void> testAudioPlayback() => _delegate.testAudioPlayback();

  /// 获取详细音频状态信息
  Future<Map<String, dynamic>> getAudioStatus() => _delegate.getAudioStatus();

  /// 停止所有正在播放的声音
  Future<void> stopAllSounds() => _delegate.stopAllSounds();

  /// 释放所有资源
  void dispose() => _delegate.dispose();

  /// 检查音频是否支持
  bool get isAudioSupported => _delegate.isAudioSupported;
}
