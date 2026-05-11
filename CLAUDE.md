# TalkVerse - Claude Code 项目指南

## 项目概述

TalkVerse 是一个基于 Flutter 的 AI 对话应用，支持多角色对话、智能问答等功能。

## 开发规范

### 代码风格
- 遵循 Dart 官方代码规范
- 使用 `flutter_lints` 进行代码检查
- 所有公开 API 必须添加文档注释
- 使用中文注释说明业务逻辑

### 提交规范
- 按功能或模块拆分提交，不要将所有文件一次性打包提交
- 每个提交应对应一个独立的功能点或模块变更
- 提交信息格式：`类型: 简短描述`（如 `feat: 新增AI模块`、`fix: 修复设置页面问题`）

### 文件组织
- `lib/constants/` - 常量定义（颜色、尺寸、文本样式）
- `lib/models/` - 数据模型
- `lib/screens/` - 页面组件
- `lib/services/` - 服务层（数据库、存储、设置）
- `lib/ai_modules/` - AI 提供商抽象与实现
- `lib/widgets/` - 可复用组件
- `lib/utils/` - 工具函数

### 命名规范
- 文件名: 小写字母 + 下划线 (snake_case)
- 类名: 大驼峰 (PascalCase)
- 变量/函数: 小驼峰 (camelCase)
- 常量: 大写字母 + 下划线 (SCREAMING_SNAKE_CASE)

### 设计规范
- **圆角风格**: 使用小圆角 (4px - 16px)
- **颜色系统**: 使用 `AppColors` 常量
- **间距系统**: 使用 `AppDimensions` 常量
- **文本样式**: 使用 `AppTextStyles` 常量
- **视觉效果**: 适当使用毛玻璃和模糊效果

## 关键文件说明

### 主要页面
- `lib/main.dart` - 应用入口，配置主题，初始化数据库
- `lib/screens/main_screen.dart` - 主页面，底部导航
- `lib/screens/chat_screen.dart` - 聊天界面（核心功能），懒加载消息
- `lib/screens/chat_list_screen.dart` - 聊天列表，只加载会话元数据
- `lib/screens/character_list_screen.dart` - 角色列表
- `lib/screens/profile_screen.dart` - 个人中心

### 核心组件
- `lib/widgets/chat_bubble.dart` - 聊天气泡，支持重发、编辑、删除
- `lib/widgets/chat_input.dart` - 聊天输入框
- `lib/widgets/glass_container.dart` - 毛玻璃容器

### 数据模型
- `lib/models/message.dart` - 消息模型
- `lib/models/chat_session.dart` - 聊天会话模型
- `lib/models/character.dart` - AI角色模型
- `lib/models/ai_settings.dart` - AI配置模型（多配置支持）
- `lib/models/token_record.dart` - Token用量记录模型

### 服务层
- `lib/services/database_helper.dart` - SQLite 数据库单例，建表与数据迁移
- `lib/services/chat_storage_service.dart` - 会话元数据 CRUD（SQLite）
- `lib/services/message_dao.dart` - 消息 CRUD（SQLite，按 session_id 分表）
- `lib/services/token_usage_service.dart` - Token用量记录（SQLite）
- `lib/services/character_storage_service.dart` - 角色数据（SQLite）
- `lib/services/settings_service.dart` - AI配置（SharedPreferences）

### AI 模块
- `lib/ai_modules/ai_provider.dart` - AI 服务抽象接口
- `lib/ai_modules/anthropic/anthropic_provider.dart` - Anthropic API 实现（流式SSE）

## 数据库架构

使用 `sqflite_common_ffi` 实现跨平台 SQLite 存储（Windows/Linux/macOS/Android/iOS）。

### 表结构
- **sessions** - 会话元数据（不含消息），主页只查此表
- **messages** - 消息独立存储，通过 `session_id` 关联，带索引
- **token_records** - Token用量记录，通过 `session_id` 关联
- **characters** - 角色数据

### 性能设计
- 主页加载只查 sessions 表的元数据行，不读取消息内容
- 聊天页进入时异步加载消息，显示 loading 指示器
- 消息保存采用增量操作（单条 INSERT/UPDATE），不重写全部
- 会话列表按 `updated_at DESC` 排序

### 数据迁移
首次启动时自动将 SharedPreferences 中的旧数据迁移到 SQLite，迁移完成后删除旧数据。

## 开发工作流

### 1. 新增功能
1. 在 `models/` 中定义数据模型
2. 在 `constants/` 中添加相关常量
3. 在 `widgets/` 中创建可复用组件
4. 在 `screens/` 中实现页面
5. 更新 `main.dart` 中的路由配置

### 2. 修改UI
- 颜色修改: 编辑 `lib/constants/app_colors.dart`
- 尺寸修改: 编辑 `lib/constants/app_dimensions.dart`
- 文本样式: 编辑 `lib/constants/app_text_styles.dart`

### 3. 添加新页面
1. 在 `lib/screens/` 中创建新页面文件
2. 在 `lib/screens/main_screen.dart` 中添加导航
3. 更新底部导航栏配置

## 状态管理

当前使用简单的 Stateful 管理，后续计划接入 Provider：
- 聊天状态管理
- 用户状态管理
- 角色数据管理

## 待优化事项

### 功能完善
- [x] 接入AI对话API（Anthropic 流式SSE）
- [x] 实现消息持久化存储（SQLite）
- [ ] 添加用户认证功能
- [ ] 实现消息通知推送

### 性能优化
- [x] 消息懒加载（进入聊天页时异步加载）
- [x] 会话元数据与消息分离存储
- [x] 增量消息保存（不重写全部）
- [ ] 图片懒加载
- [ ] 列表虚拟化
- [ ] 内存优化

### 用户体验
- [x] 消息加载进度指示器
- [x] 重发功能（长按最后一条消息）
- [ ] 添加更多加载动画
- [ ] 优化键盘弹出体验
- [ ] 添加手势操作

## 调试技巧

### 查看日志
```bash
flutter logs
```

### 热重载
- 保存文件自动热重载
- 按 `r` 键热重载
- 按 `R` 键热重启

### 性能分析
```bash
flutter run --profile
```

## 常见问题

### Q: 如何修改主题颜色？
A: 编辑 `lib/constants/app_colors.dart` 中的 `primary` 颜色值。

### Q: 如何添加新的底部导航项？
A: 在 `lib/screens/main_screen.dart` 中修改 `_pages` 列表和 `_buildNavItem` 方法。

### Q: 如何自定义聊天气泡样式？
A: 编辑 `lib/widgets/chat_bubble.dart` 中的样式配置。

### Q: 数据库文件在哪里？
A: 存储在应用文档目录下的 `talkverse.db`，可通过 `path_provider` 获取路径。

## 版本历史

### v1.1.0 (2026-05-11)
- 迁移存储引擎：SharedPreferences → SQLite（sqflite_common_ffi）
- 会话元数据与消息分离存储，主页秒开
- 聊天页懒加载消息，带 loading 指示器
- 消息增量保存，不再全量序列化
- 新增重发功能：长按最后一条消息可重新请求
- 移除发现页默认角色卡
- Token 统计使用 API 返回的实际值

### v1.0.0 (2026-05-06)
- 初始版本发布
- 实现基础UI框架
- 实现聊天界面
- 实现角色列表
- 实现个人中心
