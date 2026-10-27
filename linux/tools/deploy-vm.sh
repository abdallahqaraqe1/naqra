#!/bin/bash
# Builds the Linux app for ARM64 and runs it in the test machine's desktop session (ssh host naqra-linux).
set -euo pipefail
cd "$(dirname "$0")/.."
tools/fetch-models.sh
~/.dotnet/dotnet publish src/Naqra.Linux/Naqra.Linux.csproj -r linux-arm64 -c Release --self-contained true -o build/app-arm64 -v quiet -nologo | grep -E "error" || true
rsync -az --delete build/app-arm64/ naqra-linux:naqra/app/
ssh naqra-linux '. ~/naqra/env.sh; export XAUTHORITY=$(ls /run/user/1000/.mutter-Xwaylandauth.* 2>/dev/null | head -1); pkill -x naqra || true; sleep 0.5; (setsid ~/naqra/app/naqra > ~/naqra/app.log 2>&1 < /dev/null &); sleep 5; tail -15 ~/naqra/app.log; pgrep -x naqra >/dev/null && echo running'
