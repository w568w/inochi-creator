#include "imgui.h"
#include "imgui_internal.h"
#include <cstddef>
#include <cstdio>

#define SIZE(T) std::printf(#T " %zu %zu\n", sizeof(T), alignof(T))
#define FIELD(T, F) std::printf(#T "." #F " %zu\n", offsetof(T, F))

int main() {
    SIZE(ImGuiIO);
    FIELD(ImGuiIO, Fonts);
    FIELD(ImGuiIO, MousePos);
    FIELD(ImGuiIO, InputQueueCharacters);
    SIZE(ImGuiStyle);
    FIELD(ImGuiStyle, FontScaleMain);
    FIELD(ImGuiStyle, Colors);
    SIZE(ImGuiContext);
    FIELD(ImGuiContext, CurrentWindow);
    FIELD(ImGuiContext, LastItemData);
    FIELD(ImGuiContext, ActiveId);
    FIELD(ImGuiContext, DragDropActive);
    FIELD(ImGuiContext, TablesLastTimeActive);
    FIELD(ImGuiContext, InputTextState);
    FIELD(ImGuiContext, SettingsWindows);
    FIELD(ImGuiContext, TempBuffer);
    SIZE(ImGuiWindow);
    FIELD(ImGuiWindow, DC);
    FIELD(ImGuiWindow, DrawList);
    FIELD(ImGuiWindow, WorkRect);
    FIELD(ImGuiDockNode, ChildNodes);
    FIELD(ImGuiWindowSettings, DockId);
    SIZE(ImGuiWindowTempData);
    FIELD(ImGuiWindowTempData, CursorPos);
    FIELD(ImGuiWindowTempData, StateStorage);
    SIZE(ImDrawList);
    FIELD(ImDrawList, VtxBuffer);
    FIELD(ImDrawList, _VtxWritePtr);
    FIELD(ImDrawList, _TextureStack);
    SIZE(ImDrawCmd);
    FIELD(ImDrawCmd, TexRef);
    FIELD(ImDrawCmd, UserCallback);
    SIZE(ImFontConfig);
    FIELD(ImFontConfig, GlyphOffset);
    FIELD(ImFontConfig, FontLoaderFlags);
    SIZE(ImFontBaked);
    SIZE(ImGuiInputTextState);
    SIZE(ImGuiDebugAllocInfo);
    SIZE(ImFont);
    FIELD(ImFont, Sources);
    SIZE(ImGuiViewport);
    SIZE(ImTextureRef);
    SIZE(ImDrawVert);
    SIZE(ImDrawIdx);
    SIZE(ImWchar);
}
