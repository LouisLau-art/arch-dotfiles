# plasma-org.kde.plasma.desktop-appletsrc 美化说明（不收录整文件）
#
# 原因：该文件含机器相关的 containment / activity id
# （如 [Containments][1] activityId=fcd68bed-…），整文件复制到新机
# 会造成 containment 冲突，故只收录美化相关三处，恢复用 kwriteconfig6
# 逐键写入（命令见 install.sh「Plasma 美化」段）。
#
# 1) 桌面幻灯片壁纸（本机实测值；桌面端 SlideInterval=5，锁屏端 900 见 kscreenlockerrc）
#    [Containments][1] wallpaperplugin=org.kde.slideshow
#    [Containments][1][Wallpaper][org.kde.slideshow][General]
#    SlideInterval=5
#    SlidePaths=/usr/share/wallpapers   （需 plasma-workspace-wallpapers 包提供壁纸）
#
# 2) 锁屏幻灯片壁纸：见本目录 kscreenlockerrc（整文件收录，无机器相关 id，可直接覆盖）
#
# 3) tray 精简（只显示 网络/音量/电池，其余收进溢出区）：
#    [Containments][2][Applets][7][General]
#    shownItems=org.kde.plasma.networkmanagement,org.kde.plasma.volume,org.kde.plasma.battery
#
# 手动恢复（等价于 install.sh 所做）：
#   kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
#     --group Containments --group 1 --key wallpaperplugin org.kde.slideshow
#   kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
#     --group Containments --group 1 --group Wallpaper --group org.kde.slideshow --group General \
#     --key SlidePaths /usr/share/wallpapers
#   kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
#     --group Containments --group 1 --group Wallpaper --group org.kde.slideshow --group General \
#     --key SlideInterval 5
#   kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
#     --group Containments --group 2 --group Applets --group 7 --group General \
#     --key shownItems "org.kde.plasma.networkmanagement,org.kde.plasma.volume,org.kde.plasma.battery"
#   qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
#     "desktops().forEach(d => d.wallpaperPlugin = 'org.kde.slideshow')"  # 即时生效桌面壁纸
#   # 或：重新登录 / plasmashell --replace（Wayland 下建议直接重新登录）
#
# 注意：plasmashellrc 本次无改动（与备份一致），故不收录。
