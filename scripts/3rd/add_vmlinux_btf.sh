#!/bin/bash
set -eu

top_path=$(pwd)

# 1. 准备交叉编译工具链
export PATH=/opt/FriendlyARM/toolchain/11.3-aarch64/bin/:$PATH

# 2. 获取当前编译的内核版本
pushd kernel
kernel_ver=$(make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 kernelrelease)
popd

# 3. 确定内核模块安装目录（用于存放生成的 BTF 文件）
modules_dir=$(readlink -f ./out/output_*_kmodules/lib/modules/${kernel_ver})
[ -d ${modules_dir} ] || {
    echo "Kernel modules directory not found. Please build kernel first."
    exit 1
}

# 4. 克隆 vmlinux-btf 源码（使用你之前确认的仓库）
git clone https://github.com/QiuSimons/vmlinux-btf.git -b master

# 5. 进入源码目录，准备构建
pushd vmlinux-btf

# 6. 创建构建目录并准备“影子内核”
mkdir -p build
pushd build

# 7. 关键步骤：使用当前正在编译的 kernel 源码，而不是下载新的
#    创建软链接指向 Actions-FriendlyWrt 工作目录下的 kernel 源码
ln -sf ${top_path}/kernel shadow-kernel

# 8. 复制当前内核的 .config 作为影子内核的基础配置
cp ${top_path}/kernel/.config shadow-kernel/.config

# 9. 使用内核配置工具，启用 BTF 所需的所有选项
#    参考 vmlinux-btf 的 Makefile 中的配置列表
shadow-kernel/scripts/config \
    --file shadow-kernel/.config \
    --disable WERROR \
    --enable CGROUPS \
    --enable CGROUP_BPF \
    --enable SOCK_CGROUP_DATA \
    --enable KALLSYMS \
    --enable PERF_EVENTS \
    --enable TRACEPOINTS \
    --enable KPROBES \
    --enable UPROBES \
    --enable BPF \
    --enable BPF_SYSCALL \
    --enable BPF_JIT \
    --enable BPF_JIT_DEFAULT_ON \
    --enable INET \
    --enable NET_INGRESS \
    --enable NET_EGRESS \
    --enable BPF_STREAM_PARSER \
    --enable XDP_SOCKETS \
    --enable NET_SCHED \
    --enable NET_SCH_INGRESS \
    --enable NET_CLS \
    --enable NET_CLS_ACT \
    --enable KPROBE_EVENTS \
    --enable UPROBE_EVENTS \
    --enable BPF_EVENTS \
    --enable DEBUG_KERNEL \
    --enable DEBUG_INFO \
    --disable DEBUG_INFO_NONE \
    --enable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT \
    --disable DEBUG_INFO_REDUCED \
    --disable DEBUG_INFO_SPLIT \
    --enable DEBUG_INFO_BTF \
    --set-str EXTRA_FIRMWARE "" \
    --set-str INITRAMFS_SOURCE ""

# 10. 生成新的配置文件
make -C shadow-kernel olddefconfig

# 11. 编译影子内核的 vmlinux（仅编译，不构建模块）
#    注意：这里使用 -j$(nproc) 加速编译
make -C shadow-kernel -j$(nproc) vmlinux

# 12. 使用 pahole 从编译好的 vmlinux 中提取 BTF 信息
#    确保 pahole 已安装（在 GitHub Actions 环境中通常已预装）
pahole --btf_encode_detached=vmlinux-btf shadow-kernel/vmlinux

# 13. 将生成的 BTF 文件安装到内核模块目录，以便后续被打包进 rootfs
mkdir -p ${modules_dir}/../debug/boot
cp vmlinux-btf ${modules_dir}/../debug/boot/vmlinux

# 14. 创建软链接，匹配内核版本
ln -sf vmlinux ${modules_dir}/../debug/boot/vmlinux-${kernel_ver}

popd # build
popd # vmlinux-btf

# 15. 通知打包脚本包含这些文件
echo "FRIENDLYWRT_FILES+=(debug)" >> .current_config.mk
