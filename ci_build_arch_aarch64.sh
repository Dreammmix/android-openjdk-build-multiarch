#!/bin/bash

# ====================== 新增：接收版本参数 + 定义源码URL ======================
# 1. 接收从workflow传递的JDK 8版本号（如8u402），无参数则默认用8u392
TARGET_JDK8_VERSION=$1
if [ -z "$TARGET_JDK8_VERSION" ]; then
  TARGET_JDK8_VERSION="8u372"  # 默认版本，防止无参数时编译失败
fi

# 2. 定义对应版本的OpenJDK 8源码下载URL（需根据实际源码仓库调整链接格式）
# 注意：链接需匹配OpenJDK 8u源码的标签格式（此处以github openjdk/jdk8u为例）
JDK8_SOURCE_URL="https://github.com/openjdk/jdk8u/archive/refs/tags/jdk${TARGET_JDK8_VERSION}-b08.tar.gz"

# 3. 下载源码（若已存在则跳过，避免重复下载）
if [ ! -f "jdk8-src.tar.gz" ]; then
  echo "正在下载 OpenJDK 8 ${TARGET_JDK8_VERSION} 源码..."
  wget -O jdk8-src.tar.gz "$JDK8_SOURCE_URL" || { echo "源码下载失败！"; exit 1; }
fi

# 4. 解压源码（若已解压则跳过）
if [ ! -d "jdk8u-jdk${TARGET_JDK8_VERSION}-b08" ]; then
  echo "正在解压源码..."
  tar -zxf jdk8-src.tar.gz || { echo "源码解压失败！"; exit 1; }
fi

# 5. 进入源码目录（后续编译需在此目录执行）
cd jdk8u-jdk${TARGET_JDK8_VERSION}-b08 || { echo "进入源码目录失败！"; exit 1; }
# ==============================================================================

# ====================== 原有脚本逻辑（保持不变） ======================
if [[ "$BUILD_IOS" == "1" ]]; then
  export TARGET=aarch64-apple-darwin18.2
else
  export TARGET=aarch64-linux-android
fi
export TARGET_JDK=aarch64
export NDK_PREBUILT_ARCH=/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/aarch64-linux-android/bin/strip

# 调用全局编译脚本（此时已在指定版本的源码目录中，编译的就是目标版本）
bash ../ci_build_global.sh  # 注意：需加../，因为已进入源码子目录
