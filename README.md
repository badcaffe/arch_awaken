# 足弓觉醒 (Arch Awaken)

一款专为扁平足训练设计的Flutter应用程序，帮助用户通过科学训练改善足弓健康。

## 📱 应用简介

足弓觉醒是一款专注于扁平足康复训练的移动应用，提供个性化的训练计划和追踪功能。通过简单易用的界面和专业的训练指导，帮助用户逐步改善足弓功能。

## ✨ 主要功能

### 🏠 今日训练
- 个性化每日训练计划
- 智能训练项目推荐
- 训练进度实时追踪

### 📋 训练项目列表
六大核心训练项目，以大图标形式清晰展示：

1. **夹球踮脚** - 计次训练，增强足底肌肉
2. **瑜伽砖踮脚** - 计次训练，提高踝关节稳定性
3. **瑜伽砖捡球** - 计次训练，改善足部灵活性
4. **青蛙趴** - 计时训练，拉伸足底筋膜
5. **臀桥** - 计次训练，强化臀部支撑
6. **拉伸** - 计时训练，全方位放松

### ⏱️ 训练界面
**计时界面**：
- 开始、暂停、重置控制按钮
- 清晰的倒计时显示
- 自动完成提醒

**计次界面**：
- 开始、暂停、重置控制按钮
- 实时训练次数统计
- 1-5报数功能，每次动作完成后自动计数

### 📊 训练记录
- 历史训练数据保存
- 训练进度可视化
- 个人成就系统

### ⚙️ 个性化设置
- 训练目标设定
- 难度等级调整
- 提醒时间设置

## 🛠️ 技术架构

- **框架**: Flutter 3.9.2+
- **状态管理**: Provider 6.1.2
- **路由导航**: GoRouter 14.6.1
- **数据存储**: SharedPreferences 2.3.2
- **音频播放**: AudioPlayers 6.5.1

## 📦 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── training_model.dart   # 训练数据模型
│   ├── goal_model.dart       # 目标设置模型
│   └── today_exercises_model.dart # 今日训练模型
├── screens/                  # 页面组件
│   ├── home_screen.dart      # 首页
│   ├── training_list_screen.dart    # 训练列表
│   ├── timer_screen.dart     # 计时页面
│   ├── counter_screen.dart   # 计次页面
│   ├── training_records_screen.dart # 训练记录
│   └── ...
├── widgets/                  # 自定义组件
│   └── training_grid_widget.dart # 训练项目网格
├── services/                 # 服务层
│   └── sound_service.dart    # 音频播放服务
└── theme/                    # 主题样式
    ├── app_theme.dart        # 应用主题
    └── animations.dart       # 动画效果
```

## 🚀 快速开始

### 环境要求
- Flutter SDK 3.9.2 或更高版本
- Dart SDK 兼容版本
- Android Studio / VS Code
- Android SDK (Android开发)
- Xcode (iOS开发)

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/your-username/arch_awaken.git
   cd arch_awaken
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **检查环境**
   ```bash
   flutter doctor
   ```

4. **运行应用**
   ```bash
   flutter run
   ```

### 构建发布版本

**Android APK**:
```bash
flutter build apk --release
```

**iOS IPA**:
```bash
flutter build ios --release
```

## 🎯 训练指导

### 训练频率建议
- **初级阶段**: 每周3-4次，每次15-20分钟
- **进阶阶段**: 每周5-6次，每次25-30分钟
- **巩固阶段**: 每周2-3次，每次20-25分钟

### 注意事项
1. 训练前请充分热身
2. 根据个人能力调整训练强度
3. 如感到不适请立即停止训练
4. 建议在专业医师指导下进行训练
5. 坚持长期训练才能获得最佳效果

## 📱 系统支持

- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **平台**: 支持 Android、iOS、Web、macOS

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进项目！

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue: [GitHub Issues](https://github.com/your-username/arch_awaken/issues)
- 邮箱: your-email@example.com

## 🙏 致谢

感谢所有为扁平足康复研究做出贡献的医疗专家和开发者。

---

**免责声明**: 本应用仅为辅助训练工具，不能替代专业医疗建议。使用前请咨询专业医师。