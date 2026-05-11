# TalkVerse - AI对话应用

一个基于Flutter开发的AI对话应用，支持多角色对话、智能问答等功能。

## 功能特性

### 已实现功能
- ✅ 底部导航栏（聊天、角色列表、个人中心）
- ✅ 聊天界面（消息列表、输入框、发送按钮）
- ✅ 角色列表展示与管理（创建、编辑、删除）
- ✅ 个人中心页面
- ✅ 毛玻璃效果
- ✅ 小圆角设计风格
- ✅ 亮色主题
- ✅ AI对话功能（Anthropic API 流式SSE）
- ✅ 聊天记录持久化存储（SQLite）
- ✅ 消息懒加载（进入聊天时异步加载）
- ✅ 重发功能（长按最后一条消息）
- ✅ Token用量追踪与统计
- ✅ 多API配置切换

### 待实现功能
- 🔄 用户登录注册
- 🔄 消息通知
- 🔄 语音输入
- 🔄 图片/文件发送
- 🔄 消息搜索

## 项目结构

```
lib/
├── ai_modules/         # AI 提供商模块
│   ├── ai_provider.dart
│   └── anthropic/
├── constants/          # 常量定义
│   ├── app_colors.dart
│   ├── app_dimensions.dart
│   └── app_text_styles.dart
├── models/             # 数据模型
│   ├── message.dart
│   ├── chat_session.dart
│   ├── character.dart
│   ├── ai_settings.dart
│   └── token_record.dart
├── screens/            # 页面
│   ├── main_screen.dart
│   ├── chat_list_screen.dart
│   ├── chat_screen.dart
│   ├── character_list_screen.dart
│   ├── character_detail_screen.dart
│   ├── character_edit_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   ├── chat_settings_screen.dart
│   └── token_usage_screen.dart
├── services/           # 服务层
│   ├── database_helper.dart
│   ├── chat_storage_service.dart
│   ├── message_dao.dart
│   ├── token_usage_service.dart
│   ├── character_storage_service.dart
│   └── settings_service.dart
├── utils/              # 工具类
│   └── date_utils.dart
├── widgets/            # 可复用组件
│   ├── chat_bubble.dart
│   ├── chat_input.dart
│   ├── glass_container.dart
│   ├── character_card.dart
│   ├── glass_header.dart
│   └── warm_background.dart
└── main.dart           # 应用入口
```

## 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart
- **数据库**: SQLite（sqflite_common_ffi）
- **配置存储**: SharedPreferences
- **状态管理**: Stateful（计划接入 Provider）
- **AI接口**: Anthropic API（流式SSE）
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

## 数据库设计

使用 SQLite 存储结构化数据，支持 Windows/Linux/macOS/Android/iOS。

| 表名 | 说明 | 关键字段 |
|------|------|---------|
| sessions | 会话元数据 | id, character_id, last_message_content, updated_at |
| messages | 消息记录 | id, session_id, content, type, timestamp, status |
| token_records | Token用量 | id, session_id, input_tokens, output_tokens |
| characters | 角色数据 | id, name, avatar, personality, greeting |

### 性能优化
- 主页只查询会话元数据，不加载消息内容
- 聊天页异步加载消息，显示加载指示器
- 消息保存采用增量 INSERT/UPDATE，不全量重写
- messages 表按 session_id 建索引

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

## 更新日志

### v1.1.0 (2026-05-11)
- ✨ 迁移至 SQLite 数据库，主页加载性能大幅提升
- ✨ 消息懒加载，进入聊天时显示加载指示器
- ✨ 新增长按重发功能（AI消息可删除重新请求）
- ✨ Token 用量使用 API 实际返回值
- ✨ 移除发现页默认角色卡

### v1.0.0 (2026-05-06)
- ✨ 初始版本发布
- ✨ 实现底部导航栏
- ✨ 实现聊天界面
- ✨ 实现角色列表
- ✨ 实现个人中心
- ✨ 添加毛玻璃效果
- ✨ 采用小圆角设计风格
