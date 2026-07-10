#!/bin/bash

sed -i -e '/CONFIG_MAKE_TOOLCHAIN=y/d' configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_IB=y/# CONFIG_IB is not set/g' configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_SDK=y/# CONFIG_SDK is not set/g' configs/rockchip/01-nanopi

# Remove app
# aria2
sed -i -e 's/CONFIG_PACKAGE_aria2=y/# CONFIG_PACKAGE_aria2 is not set/g' configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_PACKAGE_aria2-openssl=y/# CONFIG_PACKAGE_aria2-openssl is not set/g' configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_PACKAGE_luci-app-aria2=y/# CONFIG_PACKAGE_luci-app-aria2 is not set/g' configs/rockchip/01-nanopi
# ddns
sed -i -e 's/CONFIG_PACKAGE_ddns-scripts=y/# CONFIG_PACKAGE_ddns-scripts is not set/g' configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_PACKAGE_ddns-scripts-services=y/# CONFIG_PACKAGE_ddns-scripts-services is not set/g' configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_PACKAGE_luci-app-ddns=y/# CONFIG_PACKAGE_luci-app-ddns is not set/g' configs/rockchip/01-nanopi
# minidlna
sed -i -e 's/CONFIG_PACKAGE_luci-app-minidlna=y/# CONFIG_PACKAGE_luci-app-minidlna is not set/g' configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_PACKAGE_minidlna=y/# CONFIG_PACKAGE_minidlna is not set/g' configs/rockchip/01-nanopi
# i18n
echo 'CONFIG_LUCI_LANG_zh_Hans=y' > configs/rockchip/02-luci_lang

# Add passwall
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/luci-app-passwall

if ! grep -q 'passwall_packages' friendlywrt/feeds.conf.default; then
  cat >> feeds.conf.default << EOF
src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main
src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main
EOF
  if ! grep -q 'chinadns-ng' configs/rockchip/03-custom; then
    cat >> configs/rockchip/03-custom << EOF
CONFIG_PACKAGE_chinadns-ng=m
CONFIG_PACKAGE_dns2socks=m
CONFIG_PACKAGE_tcping=m
CONFIG_PACKAGE_geoview=m
CONFIG_PACKAGE_simple-obfs-client=m
CONFIG_PACKAGE_luci-app-passwall=m
CONFIG_PACKAGE_luci-i18n-passwall-zh-cn=m
EOF
  fi
fi
