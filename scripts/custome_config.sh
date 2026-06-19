#!/bin/bash

sed -i -e '/CONFIG_MAKE_TOOLCHAIN=y/d' configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_IB=y/# CONFIG_IB is not set/g' configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_SDK=y/# CONFIG_SDK is not set/g' configs/rockchip/01-nanopi

# Only zh_Hans
echo "CONFIG_LUCI_LANG_zh_Hans=y" > configs/rockchip/02-luci_lang

# Disable app
sed -i \
-e 's/^CONFIG_PACKAGE_luci-app-adblock=y/# CONFIG_PACKAGE_luci-app-adblock is not set/' \
-e 's/^CONFIG_PACKAGE_adblock=y/# CONFIG_PACKAGE_adblock is not set/' \
-e 's/^CONFIG_PACKAGE_luci-app-aria2=y/# CONFIG_PACKAGE_luci-app-aria2 is not set/' \
-e 's/^CONFIG_PACKAGE_aria2=y/# CONFIG_PACKAGE_aria2 is not set/' \
-e 's/^CONFIG_PACKAGE_aria2-openssl=y/# CONFIG_PACKAGE_aria2-openssl is not set/' \
-e 's/^CONFIG_PACKAGE_luci-app-commands=y/# CONFIG_PACKAGE_luci-app-commands is not set/' \
-e 's/^CONFIG_PACKAGE_luci-app-ddns=y/# CONFIG_PACKAGE_luci-app-ddns is not set/' \
-e 's/^CONFIG_PACKAGE_ddns-scripts=y/# CONFIG_PACKAGE_ddns-scripts is not set/' \
-e 's/^CONFIG_PACKAGE_ddns-scripts-services=y/# CONFIG_PACKAGE_ddns-scripts-services is not set/' \
-e 's/^CONFIG_PACKAGE_luci-app-hd-idle=y/# CONFIG_PACKAGE_luci-app-hd-idle is not set/' \
-e 's/^CONFIG_PACKAGE_hd-idle=y/# CONFIG_PACKAGE_hd-idle is not set/' \
-e 's/^CONFIG_PACKAGE_luci-app-minidlna=y/# CONFIG_PACKAGE_luci-app-minidlna is not set/' \
-e 's/^CONFIG_PACKAGE_minidlna=y/# CONFIG_PACKAGE_minidlna is not set/' \
-e 's/^CONFIG_PACKAGE_luci-app-smartdns=y/# CONFIG_PACKAGE_luci-app-smartdns is not set/' \
-e 's/^CONFIG_PACKAGE_smartdns=y/# CONFIG_PACKAGE_smartdns is not set/' \
-e 's/^CONFIG_PACKAGE_luci-app-ttyd=y/# CONFIG_PACKAGE_luci-app-ttyd is not set/' \
-e 's/^CONFIG_PACKAGE_ttyd=y/# CONFIG_PACKAGE_ttyd is not set/' \
-e 's/^CONFIG_PACKAGE_luci-theme-material=y/# CONFIG_PACKAGE_luci-theme-material is not set/' \
-e 's/^CONFIG_PACKAGE_luci-theme-openwrt-2020=y/# CONFIG_PACKAGE_luci-theme-openwrt-2020 is not set/' \
configs/rockchip/01-nanopi
