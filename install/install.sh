#!/bin/bash

DIR="$(dirname "${BASH_SOURCE[0]}")"
DESKTOP="${HOME}/.local/share/applications/Prog.desktop"

cat >"${DESKTOP}" <<EODESKTOP
[Desktop Entry]
Encoding=UTF-8
Version=.
Type=Application
Terminal=false
Exec=${DIR}/prog.x86_64
Name=Prog
Icon=${DIR}/icon.png
Categories=Multimedia;
Comment=
Path=
StartupNotify=false
EODESKTOP

chmod a+x "${DESKTOP}"

