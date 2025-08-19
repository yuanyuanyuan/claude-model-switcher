# Claude Model Switcher v5.0.0 - 模块化架构

一个强大的 Claude Code 安装器和多模型管理系统，采用模块化架构设计，遵循《设计模式》和《代码简洁之道》的最佳实践。

## 🏗️ 架构特性

### ✨ 核心改进

- **模块化设计**: 将单个378行文件拆分为多个专门模块，每个模块不超过500行
- **配置驱动**: 完全消除硬编码，所有配置集中管理
- **测试驱动**: 支持TDD/BDD的完整测试框架
- **关注点分离**: 每个模块职责单一，易于维护和扩展
- **依赖注入**: 模块间松耦合，便于单独测试

### 🎯 设计原则

1. **单一职责原则 (SRP)**: 每个模块只负责一个功能域
2. **开闭原则 (OCP)**: 对扩展开放，对修改关闭
3. **依赖倒置原则 (DIP)**: 依赖抽象而非具体实现
4. **配置化管理**: 所有可变参数外部化配置
5. **测试优先**: 支持单元测试、集成测试和BDD场景测试

## 📁 目录结构

```
claude-model-switcher/
├── main.sh                    # 主入口点 - 模块编排器
├── install.sh                 # 简化的安装引导脚本
├── config/                    # 配置文件目录
│   ├── app.conf              # 应用程序配置
│   ├── models.conf           # 模型定义配置
│   └── providers.conf        # 提供商配置
├── lib/                      # 核心库目录
│   ├── core/                 # 核心模块
│   │   ├── logger.sh         # 日志模块
│   │   ├── config_loader.sh  # 配置加载器
│   │   └── validator.sh      # 验证器模块
│   ├── installers/           # 安装器模块
│   │   ├── nodejs_installer.sh  # Node.js安装器
│   │   └── claude_installer.sh  # Claude Code安装器
│   ├── managers/             # 管理器模块
│   │   └── model_manager.sh  # 模型管理器
│   └── utils/                # 工具模块 (待扩展)
├── tests/                    # 测试框架
│   ├── test_runner.sh        # 测试运行器
│   ├── unit/                 # 单元测试
│   ├── integration/          # 集成测试
│   └── bdd/                  # BDD场景测试
└── templates/                # 模板文件 (待扩展)
```

## 🚀 快速开始

### 安装

```bash
# 克隆或下载项目
git clone <repository-url>
cd claude-model-switcher

# 运行安装脚本
./install.sh
```

### 基本使用

```bash
# 列出可用模型
list_models

# 切换到指定模型
use_model kimi

# 使用 Claude Code
claude "你的提示词"
```

### 高级管理

```bash
# 使用完整CLI
~/.claude/claude-model-switcher/main.sh --help

# 系统状态检查
~/.claude/claude-model-switcher/main.sh status

# 添加自定义模型
~/.claude/claude-model-switcher/main.sh add-model my-model openai gpt-4

# 运行测试
~/.claude/claude-model-switcher/tests/test_runner.sh
```

## 🔧 模块详解

### 核心模块 (lib/core/)

#### logger.sh - 日志模块
- **职责**: 统一的日志记录和输出格式化
- **特性**: 多级别日志、文件输出、彩色控制台输出
- **函数**: `log_info()`, `log_error()`, `log_success()`, `log_debug()`

#### config_loader.sh - 配置加载器
- **职责**: 配置文件的加载、验证和缓存管理
- **特性**: 自动重载、语法验证、依赖检查
- **函数**: `config_load()`, `config_validate_syntax()`, `config_load_all()`

#### validator.sh - 验证器模块
- **职责**: 输入验证和系统环境检查
- **特性**: 多种验证规则、详细错误信息
- **函数**: `validate_model_alias()`, `validate_api_key()`, `validate_system_requirements()`

### 安装器模块 (lib/installers/)

#### nodejs_installer.sh - Node.js安装器
- **职责**: Node.js和NVM的安装管理
- **特性**: 版本检查、平台适配、安装验证
- **函数**: `install_nodejs()`, `validate_nodejs()`, `upgrade_nodejs()`

#### claude_installer.sh - Claude Code安装器
- **职责**: Claude Code CLI的安装和配置
- **特性**: NPM包管理、配置文件生成
- **函数**: `install_claude_code()`, `update_claude_code()`, `test_claude_installation()`

### 管理器模块 (lib/managers/)

#### model_manager.sh - 模型管理器
- **职责**: AI模型的切换、配置和管理
- **特性**: 动态配置加载、提供商适配、会话管理
- **函数**: `list_models()`, `use_model()`, `add_model()`, `remove_model()`

## 🧪 测试框架

### 测试类型

1. **单元测试** (`tests/unit/`): 测试单个模块的功能
2. **集成测试** (`tests/integration/`): 测试模块间的协作
3. **BDD测试** (`tests/bdd/`): 基于用户场景的行为驱动测试

### 运行测试

```bash
# 运行所有测试
./tests/test_runner.sh

# 运行特定类型的测试
./tests/test_runner.sh unit
./tests/test_runner.sh integration
./tests/test_runner.sh bdd

# 运行特定测试文件
./tests/test_runner.sh tests/unit/test_logger.sh
```

### 测试断言函数

- `assert_success()` - 命令应该成功
- `assert_failure()` - 命令应该失败
- `assert_equals()` - 字符串相等
- `assert_file_exists()` - 文件存在
- `assert_contains()` - 字符串包含

## ⚙️ 配置管理

### 配置文件

#### config/app.conf - 应用配置
```bash
APP_VERSION="5.0.0"
SWITCHER_DIR="$HOME/.claude/claude-model-switcher"
CLAUDE_DEFAULT_TEMPERATURE="0.6"
LOG_LEVEL="INFO"
```

#### config/models.conf - 模型配置
```bash
# 模型定义
MODEL_PROVIDERS["kimi"]="moonshot"
MODEL_API_NAMES["kimi"]="kimi-k2-turbo-preview"
MODEL_CONTEXTS["kimi"]="128K tokens"
```

#### config/providers.conf - 提供商配置
```bash
# 提供商配置
PROVIDER_MOONSHOT_BASE_URL="https://api.moonshot.cn/anthropic/"
PROVIDER_ZHIPU_BASE_URL="https://open.bigmodel.cn/api/anthropic"
```

## 🔄 扩展指南

### 添加新的AI提供商

1. 在 `config/providers.conf` 中添加提供商配置
2. 在 `lib/managers/model_manager.sh` 中添加提供商逻辑
3. 更新 `config/models.conf` 中的可用提供商列表
4. 编写相应的测试用例

### 添加新的模块

1. 在适当的 `lib/` 子目录中创建新模块
2. 遵循现有的命名约定和代码风格
3. 在 `main.sh` 中引入新模块
4. 编写对应的单元测试和集成测试

### 自定义配置

所有配置都可以通过修改 `config/` 目录下的文件进行自定义，无需修改代码。

## 🛠️ 开发工具

### 代码风格
- 使用清晰的变量命名
- 全局配置使用大写，局部变量使用小写
- 每个函数包含详细注释
- 错误处理和返回码一致性

### 调试支持
```bash
# 启用调试模式
export LOG_LEVEL="DEBUG"

# 查看日志文件
tail -f ~/.claude/claude-model-switcher/logs/installer.log
```

## 📊 性能优化

- 配置文件缓存机制，避免重复加载
- 模块按需加载，减少启动时间
- 并行化处理，提升安装速度
- 智能备份策略，节省存储空间

## 🔒 安全特性

- API密钥仅在会话中存储，不写入文件
- 所有文件修改前自动备份
- 原子操作，防止配置损坏
- 输入验证，防止注入攻击

## 📈 监控和日志

- 结构化日志记录
- 多级别日志控制
- 操作审计追踪
- 性能指标收集

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支
3. 编写测试用例
4. 提交代码变更
5. 创建 Pull Request

## 📝 版本历史

### v5.0.0 (当前版本)
- 🎉 完全模块化重构
- ✅ 实现配置驱动架构
- 🧪 添加完整测试框架
- 📚 改进文档和用户体验

### v4.2.0 (遗留版本)
- 单文件架构
- 硬编码配置
- 基本功能实现

## 📞 支持

如有问题或建议，请：
1. 查看本文档
2. 运行 `./main.sh --help` 获取帮助
3. 检查日志文件
4. 提交 Issue

---

**Claude Model Switcher v5.0.0** - 让AI模型切换变得简单而强大！ 🚀
