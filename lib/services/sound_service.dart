import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  /// 播放数字声音文件
  Future<void> playNumberSound(int number) async {
    final soundPath = 'sounds/num_$number.mp3';
    await _playSound(soundPath);
  }

  /// 播放倒计时声音
  Future<void> playCountdownSound() async {
    final soundPath = 'sounds/gear.mp3';
    await _playSound(soundPath);
  }

  /// 播放完成声音
  Future<void> playCheerSound() async {
    final soundPath = 'sounds/cheer.mp3';
    await _playSound(soundPath);
  }

  /// 播放咕嘟声音（休息中计时）
  Future<void> playGuduSound() async {
    final soundPath = 'sounds/gudu.mp3';
    await _playSound(soundPath);
  }

  /// 播放休息开始声音
  Future<void> playRestStartSound() async {
    final soundPath = 'sounds/rest-start.mp3';
    await _playSound(soundPath);
  }

  /// 播放休息结束声音
  Future<void> playRestEndSound() async {
    final soundPath = 'sounds/rest-end.mp3';
    await _playSound(soundPath);
  }

  /// 播放自定义声音文件
  Future<void> playCustomSound(String soundPath) async {
    await _playSound(soundPath);
  }

  /// 播放声音的通用方法
  Future<void> _playSound(String soundPath) async {
    try {
      // 使用同一个AudioPlayer实例，但先停止当前播放的声音
      await _player.stop();

      // 检查音频文件是否存在
      final assetSource = AssetSource(soundPath);
      print('🔊 播放音频: $soundPath');

      await _player.play(assetSource);

      // 监听播放状态
      _player.onPlayerStateChanged.listen((state) {
        print('🔊 音频状态: $state for $soundPath');
      });

      _player.onPlayerComplete.listen((_) {
        print('🔊 音频播放完成: $soundPath');
      });

    } catch (e) {
      print('❌ 音频播放失败: $soundPath, 错误: $e');
    }
  }

  /// 停止所有正在播放的声音
  Future<void> stopAllSounds() async {
    await _player.stop();
  }

  /// 释放所有资源
  void dispose() {
    _player.dispose();
  }
}
