#!/bin/bash
# {{ Add luci-app-vlscmd
(cd friendlywrt && {
    rm -rf package/openwrt-vlmcsd
    rm -rf package/luci-app-vlmcsd
    git clone https://github.com/worm0908/openwrt-vlmcsd.git package/openwrt-vlmcsd
    git clone https://github.com/cokebar/luci-app-vlmcsd.git package/luci-app-vlmcsd
})
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-vlmcsd=y
CONFIG_PACKAGE_vlmcsd=y
EOL
# }}

# {{ Add vmlinux-btf
(cd friendlywrt && {
    rm -rf package/vmlinux-btf
    git clone https://github.com/QiuSimons/vmlinux-btf.git package/vmlinux-btf
})
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_vmlinux-btf=y
EOL
# }}

# Detect whether this is OpenWrt 25+ by probing feeds.conf.default for the
# "video" feed line, which only ships in OpenWrt 25+.
IS_OPENWRT_25=0
if [ -f friendlywrt/feeds.conf.default ] \
   && grep -qE '^[[:space:]]*src-git[[:space:]]+video[[:space:]]+https' friendlywrt/feeds.conf.default; then
    IS_OPENWRT_25=1
fi
echo "add_packages.sh: IS_OPENWRT_25=${IS_OPENWRT_25}"

# {{ Add luci-theme-argon
(cd friendlywrt/package && {
    [ -d luci-theme-argon ] && rm -rf luci-theme-argon
    git clone https://github.com/jerrykuku/luci-theme-argon.git --depth 1 -b master
})
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> configs/rockchip/01-nanopi
sed -i -e 's/function init_theme/function old_init_theme/g' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
APPEND_TEXT="$(mktemp -t appendtext.XXXXXX)"
trap 'rm -f "$APPEND_TEXT"' EXIT
cat > "$APPEND_TEXT" <<EOL
function init_theme() {
    if uci get luci.themes.Argon >/dev/null 2>&1; then
        uci set luci.main.mediaurlbase="/luci-static/argon"
        uci commit luci
    fi
}
EOL
sed -i -e "/boardname=/r $APPEND_TEXT" friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
# }}
