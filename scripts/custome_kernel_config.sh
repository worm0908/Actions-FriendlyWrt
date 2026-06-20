#!/bin/bash

# =============================================
# dae (https://github.com/daeuniverse/dae) 内核配置
# 参考: https://github.com/daeuniverse/dae/blob/main/docs/zh/README.md
# =============================================

# 定义 dae 必需的配置项
CONFIGS=(
    # 基础 eBPF 支持
    "CONFIG_BPF=y"
    "CONFIG_BPF_SYSCALL=y"
    "CONFIG_BPF_JIT=y"
    "CONFIG_BPF_JIT_ALWAYS_ON=y"
    "CONFIG_CGROUPS=y"
    
    # eBPF 高级功能 (dae 0.9.x/1.0+ 依赖)
    "CONFIG_KPROBES=y"
    "CONFIG_BPF_STREAM_PARSER=y"
    "CONFIG_BPF_EVENTS=y"
    
    # 网络包处理 (Traffic Control)
    "CONFIG_NET_INGRESS=y"
    "CONFIG_NET_EGRESS=y"
    "CONFIG_NET_SCH_INGRESS=y"
    "CONFIG_NET_CLS_BPF=y"
    "CONFIG_NET_CLS_ACT=y"
    
    # BTF 支持 (CO-RE 加载 eBPF 程序必需)
    "CONFIG_DEBUG_INFO=y"
    "CONFIG_DEBUG_INFO_BTF=y"
    "# CONFIG_DEBUG_INFO_REDUCED is not set"   # 必须显式禁用

    # 原有的额外配置
    "CONFIG_NET_ACT_CT=y"
    "CONFIG_NET_ACT_CTINFO=y"
)

# 获取当前内核配置文件路径
source .current_config.mk
KCFG="kernel/arch/arm64/configs/$(awk '{print $1}' <<< "$TARGET_KERNEL_CONFIG")"

echo "正在为 dae 支持修改内核配置: $KCFG"

# 遍历并应用所有配置
for CFG in "${CONFIGS[@]}"; do
    KEY="${CFG%%=*}"
    
    # 处理特殊格式: "# CONFIG_XXX is not set"
    if [[ "$CFG" == "# "*" is not set" ]]; then
        REAL_KEY=$(echo "$CFG" | awk '{print $2}')
        if grep -q "^${REAL_KEY}=" "${KCFG}"; then
            sed -i "s@^${REAL_KEY}=.*@# ${REAL_KEY} is not set@g" "${KCFG}"
        elif ! grep -q "^# ${REAL_KEY} is not set" "${KCFG}"; then
            echo "$CFG" >> "${KCFG}"
        fi
    else
        # 普通 KEY=VALUE
        if grep -q "^#\?${KEY}=" "${KCFG}"; then
            sed -i "s@^#\?${KEY}=.*@${CFG}@g" "${KCFG}"
        else
            echo "$CFG" >> "${KCFG}"
        fi
    fi
done

echo "内核配置修改完成。"
