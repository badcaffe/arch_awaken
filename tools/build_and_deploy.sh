#!/bin/bash

# 足弓觉醒应用构建和部署脚本
# 用于构建APK并部署到Android设备

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否在项目根目录
check_project_root() {
    if [ ! -f "pubspec.yaml" ]; then
        log_error "请在项目根目录运行此脚本"
        exit 1
    fi
}

# 检查Flutter环境
check_flutter() {
    log_info "检查Flutter环境..."
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter未安装或未添加到PATH"
        exit 1
    fi

    flutter --version
    log_success "Flutter环境检查完成"
}

# 检查Android设备
check_device() {
    log_info "检查Android设备..."

    # 检查ADB是否可用
    if ! command -v adb &> /dev/null; then
        log_error "ADB未找到，请确保Android SDK已正确安装"
        exit 1
    fi

    # 检查设备连接
    device_count=$(adb devices | grep -c "device$" || true)
    if [ "$device_count" -eq 0 ]; then
        log_error "未找到连接的Android设备"
        log_info "请确保："
        log_info "1. Android设备已通过USB连接"
        log_info "2. 已开启USB调试模式"
        log_info "3. 已授权此计算机的调试权限"
        exit 1
    fi

    log_success "找到 $device_count 个Android设备"
}

# 清理项目
clean_project() {
    log_info "清理项目..."
    flutter clean
    log_success "项目清理完成"
}

# 获取依赖
get_dependencies() {
    log_info "获取项目依赖..."
    flutter pub get
    log_success "依赖获取完成"
}

# 构建APK
build_apk() {
    local build_type=${1:-"release"}

    log_info "开始构建APK ($build_type 模式)..."

    if [ "$build_type" = "debug" ]; then
        flutter build apk --debug
    else
        flutter build apk --release
    fi

    log_success "APK构建完成"
}

# 查找APK文件
find_apk() {
    local build_type=${1:-"release"}

    if [ "$build_type" = "debug" ]; then
        apk_path="build/app/outputs/flutter-apk/app-debug.apk"
    else
        apk_path="build/app/outputs/flutter-apk/app-release.apk"
    fi

    if [ ! -f "$apk_path" ]; then
        log_error "找不到APK文件: $apk_path"
        exit 1
    fi

    echo "$apk_path"
}

# 部署到设备
deploy_apk() {
    local apk_path=$1
    local package_name="com.example.arch_awaken"

    log_info "部署APK到设备..."

    # 获取连接的设备列表
    devices=($(adb devices | grep "device$" | awk '{print $1}'))

    if [ ${#devices[@]} -eq 1 ]; then
        # 单个设备，直接安装
        log_info "安装到设备: ${devices[0]}"
        adb -s "${devices[0]}" install -r "$apk_path"
        log_success "APK安装成功"
    else
        # 多个设备，让用户选择
        log_info "发现多���设备，请选择目标设备:"
        for i in "${!devices[@]}"; do
            device_model=$(adb -s "${devices[$i]}" shell getprop ro.product.model 2>/dev/null || echo "Unknown")
            echo "$((i+1)). ${devices[$i]} ($device_model)"
        done

        read -p "请输入设备编号 (1-${#devices[@]}): " choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#devices[@]} ]; then
            selected_device="${devices[$((choice-1))]}"
            log_info "安装到设备: $selected_device"
            adb -s "$selected_device" install -r "$apk_path"
            log_success "APK安装成功"
        else
            log_error "无效的选择"
            exit 1
        fi
    fi
}

# 启动应用
launch_app() {
    local package_name="com.example.arch_awaken"

    log_info "启动应用..."

    # 获取主Activity
    main_activity=$(adb shell dumpsys package "$package_name" | grep -A 5 "Activity Resolver Table" | grep -m1 "$package_name" | awk '{print $2}' || echo "")

    if [ -n "$main_activity" ]; then
        adb shell monkey -p "$package_name" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
        log_success "应用启动成功"
    else
        log_warning "无法自动启动应用，请手动在设备上打开"
    fi
}

# 显示使用帮助
show_help() {
    echo "足弓觉醒应用构建和部署脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -d, --debug         构建debug版本APK"
    echo "  -r, --release       构建release版本APK (默认)"
    echo "  -c, --clean         构建前清理项目"
    echo "  --no-deploy         仅构建，不部署到设备"
    echo "  --no-launch         部署后不启动应用"
    echo ""
    echo "示例:"
    echo "  $0                  # 构建release版本并部署"
    echo "  $0 -d               # 构建debug版本并部署"
    echo "  $0 -c               # 清理后构建release版本并部署"
    echo "  $0 --no-deploy      # 仅构建，不部署"
}

# 主函数
main() {
    local build_type="release"
    local should_clean=false
    local should_deploy=true
    local should_launch=true

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--debug)
                build_type="debug"
                shift
                ;;
            -r|--release)
                build_type="release"
                shift
                ;;
            -c|--clean)
                should_clean=true
                shift
                ;;
            --no-deploy)
                should_deploy=false
                shift
                ;;
            --no-launch)
                should_launch=false
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done

    log_info "开始足弓觉醒应用构建和部署流程..."

    # 检查环境
    check_project_root
    check_flutter

    if [ "$should_deploy" = true ]; then
        check_device
    fi

    # 清理项目（如果需要）
    if [ "$should_clean" = true ]; then
        clean_project
    fi

    # 获取依赖
    get_dependencies

    # 构建APK
    build_apk "$build_type"

    # 查找APK文件
    apk_path=$(find_apk "$build_type")
    log_info "APK文件位置: $apk_path"

    # 部署到设备（如果需要）
    if [ "$should_deploy" = true ]; then
        deploy_apk "$apk_path"

        # 启动应用（如果需要）
        if [ "$should_launch" = true ]; then
            launch_app
        fi
    else
        log_success "构建完成！APK文件: $apk_path"
    fi

    log_success "所有操作完成！"
}

# 运行主函数
main "$@"