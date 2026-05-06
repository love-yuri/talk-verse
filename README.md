# TalkVerse - AI对话应用

一个基于Flutter开发的AI对话应用，支持多角色对话、智能问答等功能。

## 功能特性

### 已实现功能
- ✅ 底部导航栏（聊天、角色列表、个人中心）
- ✅ 聊天界面（消息列表、输入框、发送按钮）
- ✅ 角色列表展示
- ✅ 个人中心页面
- ✅ 毛玻璃效果
- ✅ 小圆角设计风格
- ✅ 亮色主题

### 待实现功能
- 🔄 AI对话功能接入
- 🔄 角色详情页面
- 🔄 聊天记录保存
- 🔄 用户登录注册
- 🔄 消息通知
- 🔄 语音输入
- 🔄 图片/文件发送

## 项目结构

```
lib/
├── constants/          # 常量定义
│   ├── app_colors.dart
│   ├── app_dimensions.dart
│   └── app_text_styles.dart
├── models/             # 数据模型
│   ├── message.dart
│   ├── chat_session.dart
│   └── character.dart
├── screens/            # 页面
│   ├── main_screen.dart
│   ├── chat_list_screen.dart
│   ├── chat_screen.dart
│   ├── character_list_screen.dart
│   └── profile_screen.dart
├── utils/              # 工具类
│   └── date_utils.dart
├── widgets/            # 可复用组件
│   ├── chat_bubble.dart
│   ├── chat_input.dart
│   └── glass_container.dart
└── main.dart           # 应用入口
```

## 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart
- **状态管理**: Provider (待接入)
- **国际化**: intl
- **图标**: font_awesome_flutter

## 设计规范

### 颜色系统
- 主色调: `#6366F1` (靛蓝色)
- 背景色: `#F8FAFC` (浅灰色)
- 表面色: `#FFFFFF` (白色)
- 文本色: `#1E293B` (深灰色)

### 圆角规范
- 小圆角: 4px - 8px
- 中圆角: 12px - 16px
- 大圆角: 20px

### 间距系统
- 基础间距: 4px
- 常用间距: 8px, 12px, 16px, 20px, 24px, 32px

## 开发指南

### 环境要求
- Flutter SDK: >=3.11.5
- Dart SDK: >=3.11.5

### 运行项目

```bash
# 获取依赖
flutter pub get

# 运行调试版本
flutter run

# 构建Linux桌面版本
flutter build linux

# 构建Android版本
flutter build apk
```

### 代码规范
- 使用Dart官方代码风格
- 添加必要的注释
- 遵循单一职责原则
- 使用常量管理颜色、尺寸等

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式

- 项目链接: [GitHub Repository](https://github.com/yourusername/talkverse)
- 问题反馈: [Issues](https://github.com/yourusername/talkverse/issues)

## 更新日志

### v1.0.0 (2026-05-06)
- ✨ 初始版本发布
- ✨ 实现底部导航栏
- ✨ 实现聊天界面
- ✨ 实现角色列表
- ✨ 实现个人中心
- ✨ 添加毛玻璃效果
- ✨ 采用小圆角设计风格
