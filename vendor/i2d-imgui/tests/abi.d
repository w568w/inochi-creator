import i2d.imgui;
import std.stdio;

void layout(T, string[] fields = [])() {
    writefln("%s %s %s", T.stringof, T.sizeof, T.alignof);
    static foreach (field; fields)
        writefln("%s.%s %s", T.stringof, field, __traits(getMember, T, field).offsetof);
}

void main() {
    layout!(ImGuiIO, ["Fonts", "MousePos", "InputQueueCharacters"])();
    layout!(ImGuiStyle, ["FontScaleMain", "Colors"])();
    layout!(ImGuiContext, ["CurrentWindow","LastItemData","ActiveId","DragDropActive","TablesLastTimeActive","InputTextState","SettingsWindows","TempBuffer"])();
    layout!(ImGuiWindow, ["DC", "DrawList", "WorkRect"])();
    writefln("ImGuiDockNode.ChildNodes %s", ImGuiDockNode.ChildNodes.offsetof);
    writefln("ImGuiWindowSettings.DockId %s", ImGuiWindowSettings.DockId.offsetof);
    layout!(ImGuiWindowTempData, ["CursorPos", "StateStorage"])();
    layout!(ImDrawList, ["VtxBuffer", "_VtxWritePtr", "_TextureStack"])();
    layout!(ImDrawCmd, ["TexRef", "UserCallback"])();
    layout!(ImFontConfig, ["GlyphOffset", "FontLoaderFlags"])();
    layout!ImFontBaked();
    layout!ImGuiInputTextState();
    layout!ImGuiDebugAllocInfo();
    layout!(ImFont, ["Sources"])();
    layout!ImGuiViewport();
    layout!ImTextureRef();
    layout!ImDrawVert();
    writefln("ImDrawIdx %s %s", ImDrawIdx.sizeof, ImDrawIdx.alignof);
    writefln("ImWchar %s %s", ImWchar.sizeof, ImWchar.alignof);
}
