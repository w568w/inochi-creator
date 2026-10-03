#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p tests/out
c++ -DIMGUI_USE_WCHAR32 -DIMGUI_DISABLE_OBSOLETE_FUNCTIONS -DIMGUI_ENABLE_FREETYPE \
    -Ideps/cimgui/imgui tests/abi.cpp -o tests/out/abi-cpp
ldc2 -Isource tests/abi.d -of=tests/out/abi-d
tests/out/abi-cpp > tests/out/cpp.layout
tests/out/abi-d > tests/out/d.layout
diff -u tests/out/cpp.layout tests/out/d.layout
echo 'D/C++ ABI layouts match.'
