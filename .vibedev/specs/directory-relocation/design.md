# 安装目录配置设计文档

## 概述
本设计文档描述如何修改Claude Model Switcher的安装过程，使其直接安装到 `/root/claude-model-switcher` 目录，而不是默认的 `/root/.claude/claude-model-switcher`。

## 架构设计

### 当前架构分析
1. **安装入口**: `install.sh` 脚本
2. **硬编码路径**: 第12行 `INSTALL_TARGET="$HOME/.claude/claude-model-switcher"`
3. **安装流程**: 
   - 检查现有安装
   - 创建目标目录
   - 复制文件
   - 运行模块化安装

### 目标架构
1. **可配置路径**: 支持自定义安装目录
2. **默认路径**: `/root/claude-model-switcher`
3. **向后兼容**: 保持现有安装流程不变

## 组件和接口

### 1. 安装脚本修改 (`install.sh`)

#### 当前代码
```bash
INSTALL_TARGET="$HOME/.claude/claude-model-switcher"
```

#### 修改方案
```bash
# 支持自定义安装目录
DEFAULT_INSTALL_TARGET="/root/claude-model-switcher"
INSTALL_TARGET="${CLAUDE_INSTALL_DIR:-$DEFAULT_INSTALL_TARGET}"
```

#### 接口变更
- 新增环境变量: `CLAUDE_INSTALL_DIR`
- 默认值: `/root/claude-model-switcher`
- 向后兼容: 不影响现有安装

### 2. 配置文件模板 (`config/app.conf`)

#### 当前配置
```bash
SWITCHER_DIR="$HOME/.claude/claude-model-switcher"
```

#### 修改方案
安装过程中动态生成配置文件，基于实际安装目录设置 `SWITCHER_DIR`。

## 数据模型

### 安装参数
```yaml
install_target: 
  type: string
  default: "/root/claude-model-switcher"
  env_var: "CLAUDE_INSTALL_DIR"
  validation: 
    - must_be_absolute_path
    - must_have_write_permission
```

### 配置模板变量
```yaml
template_variables:
  SWITCHER_DIR: 
    source: "actual_install_directory"
    required: true
```

## 错误处理

### 1. 目录权限检查
```bash
# 检查目标目录权限
check_directory_permissions() {
    local target_dir="$1"
    if [ ! -w "$(dirname "$target_dir")" ]; then
        log_error "No write permission for $(dirname "$target_dir")"
        return 1
    fi
    return 0
}
```

### 2. 目录存在性处理
```bash
# 处理已存在的目录
handle_existing_directory() {
    local target_dir="$1"
    if [ -d "$target_dir" ]; then
        if [ "$(ls -A "$target_dir")" ]; then
            log_warning "Directory $target_dir already exists and is not empty"
            # 提示用户选择操作
        fi
    fi
}
```

### 3. 安装回滚机制
```bash
# 安装失败时清理
cleanup_on_failure() {
    local target_dir="$1"
    if [ -d "$target_dir" ] && [ "$CLEANUP_ON_FAILURE" = "true" ]; then
        rm -rf "$target_dir"
    fi
}
```

## 测试策略

### 1. 单元测试
```bash
# 测试安装目录配置
test_install_directory_config() {
    # 测试默认值
    assert_equals "/root/claude-model-switcher" "$DEFAULT_INSTALL_TARGET"
    
    # 测试环境变量覆盖
    export CLAUDE_INSTALL_DIR="/custom/path"
    assert_equals "/custom/path" "$INSTALL_TARGET"
}
```

### 2. 集成测试
```bash
# 测试完整安装流程
test_installation_to_custom_directory() {
    local test_dir="/tmp/test-claude-install"
    
    # 设置自定义目录
    export CLAUDE_INSTALL_DIR="$test_dir"
    
    # 执行安装
    ./install.sh
    
    # 验证安装结果
    assert_file_exists "$test_dir/main.sh"
    assert_file_exists "$test_dir/config/app.conf"
    
    # 验证配置正确性
    local config_switcher_dir
    config_switcher_dir=$(grep "SWITCHER_DIR=" "$test_dir/config/app.conf" | cut -d'"' -f2)
    assert_equals "$test_dir" "$config_switcher_dir"
}
```

### 3. 边界测试
```bash
# 测试边界情况
test_edge_cases() {
    # 测试权限不足
    export CLAUDE_INSTALL_DIR="/root/system/directory"
    assert_failure "./install.sh"
    
    # 测试磁盘空间不足
    # 使用mock模拟磁盘空间不足的情况
}
```

## 实施计划

### 阶段1: 核心修改
1. 修改 `install.sh` 中的 `INSTALL_TARGET` 定义
2. 添加环境变量支持
3. 更新帮助文档

### 阶段2: 配置处理
1. 修改配置模板生成逻辑
2. 确保所有路径引用正确

### 阶段3: 测试验证
1. 编写单元测试
2. 编写集成测试
3. 验证边界情况

## 风险评估

1. **权限问题**: `/root` 目录可能需要特殊权限
2. **现有安装冲突**: 如果 `/root/claude-model-switcher` 已存在
3. **配置兼容性**: 确保所有配置文件正确初始化

## 回滚方案

如果修改导致问题，可以：
1. 恢复原来的硬编码路径
2. 或者提供迁移脚本将现有安装移动到新位置

## 依赖关系

- Bash 4.0+ (用于参数扩展)
- 标准的Unix工具 (mkdir, cp, chmod等)
- 足够的磁盘空间和权限