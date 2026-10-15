#!/usr/bin/env bash
set -euo pipefail

command -v kwriteconfig6 >/dev/null || { echo "kde-plasma: sin KDE Plasma 6, nada que hacer"; exit 0; }

set_shortcut() {
    if ! gdbus call --session -d org.kde.kglobalaccel -o /kglobalaccel \
            -m org.kde.KGlobalAccel.setForeignShortcutKeys \
            "[\"kwin\",\"$1\",\"KWin\",\"$2\"]" "$3" >/dev/null 2>&1; then
        kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "$1" "$4,$5,$2"
    fi
}
set_shortcut "Window Quick Tile Top" "Situar la ventana en mosaico en la parte superior" '@a(ai) []' "none" "Meta+Up"
set_shortcut "Window Fullscreen" "Ventana en pantalla completa" '@a(ai) []' "none" "none"
set_shortcut "Window Maximize" "Maximizar la ventana" '[([285212691,0,0,0],), ([285212694,0,0,0],)]' $'Meta+Up\tMeta+PgUp' "Meta+PgUp"

kwriteconfig6 --file kdeglobals --group General --key TerminalApplication alacritty
kwriteconfig6 --file kdeglobals --group General --key TerminalService Alacritty.desktop

set_launch() {
    local id="[\"$1\",\"_launch\",\"$2\",\"$2\"]"
    if ! { gdbus call --session -d org.kde.kglobalaccel -o /kglobalaccel \
               -m org.kde.KGlobalAccel.doRegister "$id" >/dev/null 2>&1 &&
           gdbus call --session -d org.kde.kglobalaccel -o /kglobalaccel \
               -m org.kde.KGlobalAccel.setForeignShortcutKeys "$id" "$3" >/dev/null 2>&1; }; then
        kwriteconfig6 --file kglobalshortcutsrc --group services --group "$1" --key _launch "$4"
    fi
}
set_launch org.kde.konsole.desktop Konsole '@a(ai) []' "none"
set_launch Alacritty.desktop Alacritty '[([285212676,0,0,0],), ([201326676,0,0,0],)]' $'Meta+Return\tCtrl+Alt+T'
