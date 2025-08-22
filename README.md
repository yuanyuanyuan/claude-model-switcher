# Claude Model Switcher - AI模型管理专家

> 🚀 **Claude Model Switcher v5.0.0** - 专业级Claude Code多模型管理解决方案

一个采用**模块化架构**设计的Claude Code安装器和多模型管理系统，专为开发团队和个人开发者设计，提供企业级的模型管理体验。

## 🎯 解决的核心问题

### 场景痛点
- **多模型切换困难**：不同场景需要不同AI模型，手动切换繁琐
- **配置复杂**：每个模型都有独立的API密钥和配置参数
- **版本管理混乱**：无法追踪和回滚模型配置变更
- **团队协作困难**：团队成员使用不同模型配置，导致结果不一致
- **安装部署复杂**：新手用户难以正确安装和配置Claude Code

### 解决方案
- ✅ **一键切换**：3秒内完成模型切换
- ✅ **配置集中管理**：所有模型配置统一管理，支持版本控制
- ✅ **团队协作**：共享模型配置，确保团队成员使用相同设置
- ✅ **自动化安装**：一键完成Claude Code及其依赖的安装
- ✅ **企业级安全**：API密钥安全存储，支持团队权限管理

## 🏗️ 系统架构

### 核心设计理念
- **模块化架构**：每个功能独立成模块，便于维护和扩展
- **配置驱动**：所有设置外部化，支持热更新
- **测试优先**：完整的TDD/BDD测试框架
- **零依赖部署**：纯Shell脚本，无需额外依赖

### 技术栈
```
├── Shell脚本 (Bash/Zsh兼容)
├── 配置文件 (INI格式，易于编辑)
├── 测试框架 (自定义BDD测试)
├── 日志系统 (结构化日志)
└── 模块系统 (动态加载)
```

## 📁 项目结构

```
claude-model-switcher/
├── 📋 main.sh                    # 主程序入口
├── ⚙️ config/                    # 配置中心
│   ├── app.conf                 # 应用配置
│   ├── models.conf              # 模型定义
│   └── providers.conf           # 提供商配置
├── 🔧 lib/                      # 核心模块库
│   ├── core/                    # 基础模块
│   │   ├── logger.sh           # 日志系统
│   │   ├── config_loader.sh    # 配置管理
│   │   └── validator.sh        # 数据验证
│   ├── installers/             # 安装模块
│   │   ├── nodejs_installer.sh # Node.js管理
│   │   └── claude_installer.sh # Claude安装
│   └── managers/               # 业务模块
│       └── model_manager.sh    # 模型管理
├── 🧪 tests/                   # 测试框架
│   ├── test_runner.sh         # 测试运行器
│   ├── unit/                  # 单元测试
│   ├── integration/           # 集成测试
│   └── bdd/                   # 场景测试
├── 📚 docs/                   # 文档目录
└── 📝 README.md               # 本文档
```

## 🚀 快速入门

### 1. 一键安装

```bash
# 克隆项目
git clone https://github.com/your-repo/claude-model-switcher.git
cd claude-model-switcher

# 可选：自定义安装目录（默认为 /root/claude-model-switcher）
export CLAUDE_INSTALL_DIR="/your/custom/path"

# 执行安装
chmod +x install.sh
./install.sh

# 验证安装
list_models
```

### 2. 基础使用

```bash
# 查看可用模型
list_models

# 切换到Kimi模型
use_model kimi

# 使用Claude Code
claude "请帮我分析这段代码"

# 切换到GPT-4
use_model gpt4
```

### 3. 高级功能

```bash
# 查看系统状态
$CLAUDE_INSTALL_DIR/main.sh status

# 添加自定义模型
$CLAUDE_INSTALL_DIR/main.sh add-model \
  "custom-model" \
  "openai" \
  "gpt-4-turbo-preview" \
  "https://api.openai.com/v1"

# 批量管理模型
$CLAUDE_INSTALL_DIR/main.sh batch-update
```

## ⚙️ 配置详解

### 1. 应用配置 (config/app.conf)

```bash
# 基础设置
APP_NAME="Claude Model Switcher"
APP_VERSION="5.0.0"
INSTALL_DIR="${CLAUDE_INSTALL_DIR:-/root/claude-model-switcher}"

# 日志配置
LOG_LEVEL="INFO"
LOG_FILE="$INSTALL_DIR/logs/app.log"
MAX_LOG_SIZE="10M"

# 性能设置
CACHE_TTL=3600
PARALLEL_JOBS=4
TIMEOUT_SECONDS=30
```

### 2. 模型配置 (config/models.conf)

```bash
# Kimi模型
[kimi]
provider="moonshot"
api_name="kimi-k2-turbo-preview"
context_length="128K"
max_tokens=4096
temperature=0.6

# GPT-4
[gpt4]
provider="openai"
api_name="gpt-4-turbo-preview"
context_length="128K"
max_tokens=4096
temperature=0.7

# Claude 3.5 Sonnet
[claude35]
provider="anthropic"
api_name="claude-3-5-sonnet-20241022"
context_length="200K"
max_tokens=4096
temperature=0.7
```

### 3. 提供商配置 (config/providers.conf)

```bash
# Moonshot (Kimi)
[moonshot]
base_url="https://api.moonshot.cn/anthropic/"
api_key_env="MOONSHOT_API_KEY"
rate_limit=60

# OpenAI
[openai]
base_url="https://api.openai.com/v1"
api_key_env="OPENAI_API_KEY"
rate_limit=100

# Anthropic
[anthropic]
base_url="https://api.anthropic.com"
api_key_env="ANTHROPIC_API_KEY"
rate_limit=50
```

## 🧪 测试驱动开发

### 测试框架特性
- ✅ **单元测试**：每个函数独立测试
- ✅ **集成测试**：模块间协作验证
- ✅ **BDD场景**：用户故事驱动测试
- ✅ **性能测试**：响应时间和资源使用
- ✅ **安全测试**：输入验证和权限控制

### 运行测试

```bash
# 运行所有测试
./tests/test_runner.sh

# 运行特定类型测试
./tests/test_runner.sh unit           # 单元测试
./tests/test_runner.sh integration    # 集成测试
./tests/test_runner.sh bdd           # 场景测试

# 运行特定测试文件
./tests/test_runner.sh tests/unit/test_model_manager.sh

# 调试模式运行测试
DEBUG=1 ./tests/test_runner.sh
```

### 测试断言库

```bash
# 断言成功
assert_success "应该成功切换模型" "use_model kimi"

# 断言失败
assert_failure "应该拒绝无效模型" "use_model invalid-model"

# 断言输出包含
assert_contains "输出应包含模型名称" "$(list_models)" "kimi"

# 断言文件存在
assert_file_exists "配置文件应存在" "$HOME/.claude/config/models.conf"
```

## 🔧 开发指南

### 1. 模块开发规范

#### 模块结构模板
```bash
#!/bin/bash
# Module: my_module.sh
# Purpose: 描述模块用途
# Version: 1.0.0

# 模块状态
MODULE_NAME="my_module"
MODULE_VERSION="1.0.0"
MODULE_ENABLED=true

# 模块初始化
my_module_init() {
    log_info "初始化 $MODULE_NAME v$MODULE_VERSION"
    # 初始化逻辑
}

# 主要功能函数
my_module_main_function() {
    local param1="$1"
    local param2="$2"
    
    # 输入验证
    validate_input "$param1" || return 1
    
    # 核心逻辑
    # ...
    
    # 结果返回
    echo "处理结果"
}

# 清理函数
my_module_cleanup() {
    log_debug "清理 $MODULE_NAME 资源"
    # 清理逻辑
}
```

### 2. 配置扩展

#### 添加新模型
```bash
# 1. 编辑 config/models.conf
[new-model]
provider="new-provider"
api_name="new-model-name"
context_length="32K"
max_tokens=2048

# 2. 添加提供商配置
[new-provider]
base_url="https://api.new-provider.com"
api_key_env="NEW_PROVIDER_API_KEY"
rate_limit=100

# 3. 运行测试验证
./tests/test_runner.sh integration/test_new_model.sh
```

#### 添加新功能模块
```bash
# 1. 创建模块文件
lib/managers/new_feature_manager.sh

# 2. 实现模块接口
new_feature_init()
new_feature_main()
new_feature_cleanup()

# 3. 添加到主程序
# 在 main.sh 中添加：
source "lib/managers/new_feature_manager.sh"

# 4. 编写测试
tests/unit/test_new_feature_manager.sh
```

### 3. 调试工具

```bash
# 启用调试模式
export DEBUG=1
export LOG_LEVEL=DEBUG

# 查看详细日志
tail -f $CLAUDE_INSTALL_DIR/logs/debug.log

# 性能分析
time $CLAUDE_INSTALL_DIR/main.sh list_models

# 内存使用监测
./tests/test_runner.sh performance
```

## 📊 性能优化

### 1. 缓存策略
```bash
# 配置缓存
CACHE_TTL=3600          # 1小时缓存
CACHE_SIZE=100MB        # 最大缓存大小
CACHE_DIR="$HOME/.claude/cache"

# 手动清理缓存
$CLAUDE_INSTALL_DIR/main.sh cache-clear
```

### 2. 并行处理
```bash
# 批量模型检测
PARALLEL_JOBS=4
$CLAUDE_INSTALL_DIR/main.sh batch-check
```

### 3. 内存优化
```bash
# 限制内存使用
MAX_MEMORY=512MB
$CLAUDE_INSTALL_DIR/main.sh optimize-memory
```

## 🔒 安全最佳实践

### 1. API密钥管理
```bash
# 安全存储API密钥
export MOONSHOT_API_KEY="your-key-here"
export OPENAI_API_KEY="your-key-here"

# 使用密钥管理服务
$CLAUDE_INSTALL_DIR/main.sh setup-key-manager
```

### 2. 权限控制
```bash
# 设置文件权限
chmod 600 ~/.claude/config/providers.conf
chmod 755 $CLAUDE_INSTALL_DIR/main.sh

# 用户权限管理
$CLAUDE_INSTALL_DIR/main.sh setup-user-permissions
```

### 3. 审计日志
```bash
# 查看操作日志
$CLAUDE_INSTALL_DIR/main.sh audit-log

# 安全扫描
$CLAUDE_INSTALL_DIR/main.sh security-scan
```

## 🚀 部署方案

### 1. 单机部署
```bash
# 标准安装
./install.sh

# Docker部署
docker run -it \
  -v ~/.claude:/root/.claude \
  claude-model-switcher:latest
```

### 2. 团队部署
```bash
# 共享配置部署
$CLAUDE_INSTALL_DIR/main.sh team-setup \
  --config-repo "git@github.com:team/claude-config.git" \
  --shared-models "kimi,gpt4,claude35"

# 权限管理
$CLAUDE_INSTALL_DIR/main.sh setup-team-permissions \
  --admin-users "alice,bob" \
  --readonly-users "charlie,david"
```

### 3. CI/CD集成
```yaml
# GitHub Actions示例
name: Claude Model Switcher CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Tests
        run: |
          ./tests/test_runner.sh
          $CLAUDE_INSTALL_DIR/main.sh security-scan
```

## 📈 监控和运维

### 1. 系统监控
```bash
# 实时状态
$CLAUDE_INSTALL_DIR/main.sh status --real-time

# 性能指标
$CLAUDE_INSTALL_DIR/main.sh metrics

# 健康检查
$CLAUDE_INSTALL_DIR/main.sh health-check
```

### 2. 告警配置
```bash
# 设置告警阈值
$CLAUDE_INSTALL_DIR/main.sh setup-alerts \
  --api-timeout 30 \
  --error-rate 5% \
  --memory-usage 80%

# 集成通知服务
$CLAUDE_INSTALL_DIR/main.sh setup-notifications \
  --slack-webhook "https://hooks.slack.com/services/..." \
  --email "admin@company.com"
```

## 🤝 社区和支持

### 1. 获取帮助
- 📖 **文档**：完整的开发文档和使用指南
- 💬 **讨论**：GitHub Discussions 技术交流
- 🐛 **问题**：GitHub Issues 问题反馈
- 📧 **邮件**：claude-switcher@company.com

### 2. 贡献指南
```bash
# 1. Fork项目
git clone https://github.com/your-username/claude-model-switcher.git

# 2. 创建功能分支
git checkout -b feature/amazing-feature

# 3. 编写测试
./tests/test_runner.sh

# 4. 提交代码
git commit -m "Add amazing feature"

# 5. 创建PR
git push origin feature/amazing-feature
```

### 3. 版本发布
- **主版本**：架构重大升级
- **次版本**：新功能增加
- **修订版本**：Bug修复和优化

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

感谢以下开源项目的支持：
- [Claude Code](https://claude.ai/code) - Anthropic官方CLI工具
- [Bash Testing Framework](https://github.com/bats-core/bats-core) - 测试框架灵感
- [ShellCheck](https://www.shellcheck.net/) - Shell脚本质量检查

---

<div align="center">

**Claude Model Switcher v5.0.0**  
让AI模型管理变得简单而强大！ 🚀

[![Stars](https://img.shields.io/github/stars/your-repo/claude-model-switcher?style=social)](https://github.com/your-repo/claude-model-switcher)  
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)  
[![Version](https://img.shields.io/badge/version-5.0.0-green.svg)](CHANGELOG.md)

</div>