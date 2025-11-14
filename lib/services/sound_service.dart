import 'dart:io';
import 'package:flutter/foundation.dart';

// Abstract class to define the audio interface
abstract class _AudioPlayerInterface {
  Future<void> play(dynamic source);
  Future<void> stop();
  void dispose();
  Stream get onPlayerStateChanged;
  Stream get onPlayerComplete;
}

// Platform-specific implementations
class _SoundService {
  _AudioPlayerInterface? _player;
  bool _isAudioSupported = true;

  _SoundService() {
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    // Check if we're on HarmonyOS or other unsupported platform
    final isUnsupported = await _isUnsupportedPlatform();

    if (isUnsupported) {
      print('🔇 Audio not supported on this platform (detected at init)');
      _isAudioSupported = false;
      _player = _NoOpAudioPlayer();
      return;
    }

    // Try to initialize audio players
    try {
      _player = _AudioPlayerImpl();
      _isAudioSupported = true;
      print('✅ Audio player initialized successfully');
    } catch (e) {
      print('⚠️ Audio plugin initialization failed: $e');
      _isAudioSupported = false;
      _player = _NoOpAudioPlayer();
    }
  }

  /// Platform detection approach 1: Check Platform.operatingSystem
  bool _isHarmonyOSByPlatform() {
    final os = Platform.operatingSystem.toLowerCase();
    if (os == 'harmonyos') {
      print('✅ Detected HarmonyOS via Platform.operatingSystem');
      return true;
    }
    return false;
  }

  /// Platform detection approach 2a: Check system property via getprop
  Future<bool> _isHarmonyOSBySystemProperty() async {
    try {
      // Check for HarmonyOS-specific system property
      final result = await Process.run('getprop', ['ro.build.harmonyos']);

      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        print('✅ Detected HarmonyOS via getprop: $output');
        return output.isNotEmpty && output != '0' && output != 'false';
      }
    } catch (e) {
      // getprop command not available on this platform
    }
    return false;
  }

  /// Platform detection approach 2b: Check OS version string
  bool _isHarmonyOSByVersionString() {
    // Check if the OS version string contains HarmonyOS indicators
    final version = Platform.operatingSystemVersion.toLowerCase();

    if (version.contains('harmonyos')) {
      print('✅ Detected HarmonyOS via operatingSystemVersion');
      return true;
    }

    // Check build fingerprint for HarmonyOS
    if (version.contains('harmony')) {
      print('✅ Detected HarmonyOS via build fingerprint');
      return true;
    }

    return false;
  }

  /// Combined platform detection: Check if platform doesn't support audio plugin
  Future<bool> _isUnsupportedPlatform() async {
    // Check 1: Platform operating system name
    if (_isHarmonyOSByPlatform()) {
      return true;
    }

    // Check 2a: System properties for HarmonyOS (if running on Android device)
    if (Platform.operatingSystem == 'android') {
      final isHarmonyOSByProp = await _isHarmonyOSBySystemProperty();
      if (isHarmonyOSByProp) {
        return true;
      }

      // Check 2b: OS version string
      final isHarmonyOSByVersion = _isHarmonyOSByVersionString();
      if (isHarmonyOSByVersion) {
        return true;
      }
    }

    // Platform is likely supported
    print('🔊 Audio plugin supported on this platform');
    return false;
  }

  /// 播放数字声音文件
  Future<void> playNumberSound(int number) async {
    final soundPath = 'sounds/num_$number.mp3';
    await _playSound(soundPath);
  }

  /// 播放倒计时声音
  Future<void> playCountdownSound() async {
    const soundPath = 'sounds/gear.mp3';
    await _playSound(soundPath);
  }

  /// 播放完成声音
  Future<void> playCheerSound() async {
    const soundPath = 'sounds/cheer.mp3';
    await _playSound(soundPath);
  }

  /// 播放咕嘟声音（休息中计时）
  Future<void> playGuduSound() async {
    const soundPath = 'sounds/gudu.mp3';
    await _playSound(soundPath);
  }

  /// 播放休息开始声音
  Future<void> playRestStartSound() async {
    const soundPath = 'sounds/rest-start.mp3';
    await _playSound(soundPath);
  }

  /// 播放开始声音
  Future<void> playStartSound() async {
    const soundPath = 'sounds/start.mp3';
    await _playSound(soundPath);
  }

  /// 播放休息结束声音
  Future<void> playRestEndSound() async {
    const soundPath = 'sounds/rest-end.mp3';
    await _playSound(soundPath);
  }

  /// 播放所有训练完成声音
  Future<void> playAllDoneSound() async {
    const soundPath = 'sounds/all_done.mp3';
    await _playSound(soundPath);
  }

  /// 播放自定义声音文件
  Future<void> playCustomSound(String soundPath) async {
    await _playSound(soundPath);
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

      // 检查音频文件是否存在 - we need AssetSource
      final assetSource = _getAssetSource(soundPath);
      if (assetSource == null) {
        print('❌ Cannot create asset source for unsupported platform: $soundPath');
        return;
      }

      print('🔊 播放音频: $soundPath');

      await _player!.play(assetSource);

      // 监听播放状态
      _player!.onPlayerStateChanged.listen((state) {
        print('🔊 音频状态: $state for $soundPath');
      });

      _player!.onPlayerComplete.listen((_) {
        print('🔊 音频播放完成: $soundPath');
      });

    } catch (e) {
      print('❌ 音频播放失败: $soundPath, 错误: $e');
      // If audio fails, we might be on HarmonyOS where plugin isn't supported
      if (e.toString().contains('MissingPluginException')) {
        _isAudioSupported = false;
        _player = _NoOpAudioPlayer();
        print('🔇 Disabling audio for this platform due to MissingPluginException');
      }
    }
  }

  /// Create asset source conditionally
  dynamic _getAssetSource(String soundPath) {
    try {
      // This will only work if audioplayers is available
      return _createAssetSource(soundPath);
    } catch (e) {
      return null;
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

// No-op implementation for platforms without audioplayers support
class _NoOpAudioPlayer implements _AudioPlayerInterface {
  @override
  Future<void> play(source) async {}

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}

  @override
  Stream get onPlayerStateChanged => const Stream.empty();

  @override
  Stream get onPlayerComplete => const Stream.empty();
}

// SoundService public interface - delegates to the appropriate implementation
class SoundService {
  final _SoundService _delegate = _SoundService();

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

  /// 停止所有正在播放的声音
  Future<void> stopAllSounds() => _delegate.stopAllSounds();

  /// 释放所有资源
  void dispose() => _delegate.dispose();

  /// 检查音频是否支持
  bool get isAudioSupported => _delegate.isAudioSupported;
}

// Conditional dynamic implementation for audioplayers
class _AudioPlayerImpl implements _AudioPlayerInterface {
  dynamic _player;

  _AudioPlayerImpl() {
    try {
      _player = _createAudioPlayer();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> play(source) async {
    try {
      return await _player.play(source);
    } catch (e) {
      throw Exception('Audio not supported: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      return await _player.stop();
    } catch (e) {
      throw Exception('Audio not supported: $e');
    }
  }

  @override
  void dispose() {
    try {
      _player.dispose();
    } catch (e) {
      // Ignore disposal errors on unsupported platforms
    }
  }

  @override
  Stream get onPlayerStateChanged {
    try {
      return _player.onPlayerStateChanged;
    } catch (e) {
      return const Stream.empty();
    }
  }

  @override
  Stream get onPlayerComplete {
    try {
      return _player.onPlayerComplete;
    } catch (e) {
      return const Stream.empty();
    }
  }
}

// Conditional creation of audio components
dynamic _createAudioPlayer() {
  try {
    // This will trigger a MissingPluginException on HarmonyOS
    return _AudioPlayerConstructor();
  } catch (e) {
    throw Exception('AudioPlayer not available on this platform');
  }
}

dynamic _createAssetSource(String path) {
  try {
    return _AssetSourceConstructor(path);
  } catch (e) {
    throw Exception('AssetSource not available on this platform');
  }
}

// These functions will be replaced by the actual audioplasses if available
// On HarmonyOS, they will throw exceptions that get caught and handled
class _AudioPlayerConstructor {
  _AudioPlayerConstructor() {
    throw Exception('AudioPlayer not implemented');
  }

  void play(dynamic source) {}
  Future<void> stop() async {}
  void dispose() {}
  Stream get onPlayerStateChanged => const Stream.empty();
  Stream get onPlayerComplete => const Stream.empty();
}

class _AssetSourceConstructor {
  _AssetSourceConstructor(String path) {
    throw Exception('AssetSource not implemented');
  }
}
