#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
getversion(){
ver=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/$1/releases/latest) | grep -o -E "[0-9].+")
[ $ver ] && echo $ver || git ls-remote --tags git://github.com/$1 | cut -d/ -f3- | sort -t. -nk1,2 -k3 | awk '/^[^{]*$/{version=$1}END{print version}' | grep -o -E "[0-9].+"
}

if [-f "./package/lean/default-settings/files/zzz-default-settings.bak"]; then
    cp ./package/lean/default-settings/files/zzz-default-settings.bak ./package/lean/default-settings/files/zzz-default-settings
else
    cp ./package/lean/default-settings/files/zzz-default-settings ./package/lean/default-settings/files/zzz-default-settings.bak
fi

sed -i "s/DISTRIB_DESCRIPTION='OpenWrt '/DISTRIB_DESCRIPTION='OpenWrt Mod by Kanny'/g" ./package/lean/default-settings/files/zzz-default-settings
#sed -i "s/hostname='OpenWrt'/hostname='KOpenWrt'/g" ./package/base-files/files/bin/config_generate
sed -i '/REVISION:=/{s/.*/REVISION:= $(shell date +'%F')/g}' ./include/version.mk
sed -i "s/%D %V, %C.*/%D %V, %C Mod By Kanny/g" ./package/base-files/files/etc/banner

# 替换 luci-theme-argon
# rm -rf ./package/lean/luci-theme-argon
# git clone https://github.com/jerrykuku/luci-theme-argon -b 18.06 ./package/lean/luci-theme-argon
rm -rf ./feeds/luci/themes/luci-theme-argon
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon -b 18.06 ./feeds/luci/themes/luci-theme-argon
rm -rf ./feeds/luci/themes/luci-theme-argon/.git
rm -rf ./feeds/luci/themes/luci-theme-argon/Screenshots
rm -f ./feeds/luci/themes/luci-theme-argon/.gitattributes
rm -f ./feeds/luci/themes/luci-theme-argon/.gitignore
rm -f ./feeds/luci/themes/luci-theme-argon/*.md


# 修改默认主题为 luci-theme-argon
sed -i '/uci set luci.main.mediaurlbase/d' ./package/lean/default-settings/files/zzz-default-settings
sed -i '/uci set luci.main.lang=zh_cn/a\uci set luci.main.mediaurlbase=\/luci-static\/argon\/' ./package/lean/default-settings/files/zzz-default-settings
sed -i "s/option mediaurlbase.*/option mediaurlbase '\/luci-static\/argon'/g" ./feeds/luci/modules/luci-base/root/etc/config/luci

# 修改测试
sed -i "s/dns 'openwrt.org'/dns 'www.jobcn.com'/g" ./feeds/luci/modules/luci-base/root/etc/config/luci
sed -i "s/ping 'openwrt.org'/ping '119.29.29.29'/g" ./feeds/luci/modules/luci-base/root/etc/config/luci
sed -i "s/route 'openwrt.org'/route '119.29.29.29'/g" ./feeds/luci/modules/luci-base/root/etc/config/luci

# 替换 Syncthing 并更新版本
# rm -rf ./feeds/packages/utils/syncthing
# svn co https://github.com/alloneinfo/openwrt_feeds/trunk/syncthing ./feeds/packages/utils/syncthing
# sed -i '/PKG_HASH:=/{s/.*/PKG_HASH:=skip/g}' ./feeds/packages/utils/syncthing/Makefile
# sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$(getversion syncthing/syncthing)/g" ./feeds/packages/utils/syncthing/Makefile