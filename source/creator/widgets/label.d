module creator.widgets.label;
import i2d.imgui;
import creator.widgets.dummy;
import creator.core.font;
import inochi2d.core.nodes : Node;

/**
    Render text
*/
void incText(string text) {
    igTextUnformatted(text.ptr, text.ptr+text.length);
}

/**
    Render text colored
*/
void incTextColored(ImVec4 color, string text) {
    igPushStyleColor(ImGuiCol.Text, color);
        igTextUnformatted(text.ptr, text.ptr+text.length);
    igPopStyleColor();
}

/**
    Render disabled text
*/
void incTextDisabled(string text) {
    igPushStyleColor(ImGuiCol.Text, igGetStyle().Colors[ImGuiCol.TextDisabled]);
        igTextUnformatted(text.ptr, text.ptr+text.length);
    igPopStyleColor();
}

/**
    Renders text with a slight dropshadow
*/
void incTextShadowed(string text) {
    
    ImVec2 origin;
    origin = igGetCursorPos();
    
    // Shadow
    igSetCursorPos(ImVec2(origin.x+1, origin.y+1));
    incTextColored(ImVec4(0.25, 0.25, 0.25, 0.5), text);

    // Version String
    igSetCursorPos(origin);
    incText(text);
}

/**
    Renders text with a slight border
*/
void incTextBordered(string text, ImVec4 borderColor = ImVec4(0, 0, 0, 1)) {
    
    ImVec2 origin;
    origin = igGetCursorPos();
    
    // Shadow
    igSetCursorPos(ImVec2(origin.x+1, origin.y));
    incTextColored(borderColor, text);
    igSetCursorPos(ImVec2(origin.x-1, origin.y));
    incTextColored(borderColor, text);
    igSetCursorPos(ImVec2(origin.x, origin.y+1));
    incTextColored(borderColor, text);
    igSetCursorPos(ImVec2(origin.x, origin.y-1));
    incTextColored(borderColor, text);

    // Version String
    igSetCursorPos(origin);
    incText(text);
}
/**
    Darkens an area and puts a label over it
*/
void incTextLabel(string text) {
    auto dlist = igGetWindowDrawList();
    auto style = igGetStyle();
    ImVec2 origin;
    ImVec2 textSize;

    origin = igGetCursorScreenPos();
    textSize = incMeasureString(text);
    float xPadding = style.FramePadding.x;
    float yPadding = style.FramePadding.y;

    ImVec2 tl = ImVec2(
        origin.x, 
        origin.y-yPadding
    );
    
    ImVec2 br = ImVec2(
        origin.x+textSize.x+(xPadding*2), 
        origin.y+textSize.y+yPadding
    );
    
    ImVec2 tls = ImVec2(
        tl.x-1,
        tl.y-1
    );
    
    ImVec2 brs = ImVec2(
        br.x+1,
        br.y+1
    );
    
    // Draw outline
    ImDrawList_AddRectFilled(dlist, tls, brs, igGetColorU32(ImGuiCol.Text, 0.15), 4);

    // Draw button
    ImDrawList_AddRectFilled(dlist, tl, br, igGetColorU32(ImGuiCol.WindowBg), 4);

    // Draw text
    ImDrawList_AddText(dlist, 
        ImVec2(
            origin.x+xPadding,
            origin.y,
        ),
        igGetColorU32(ImGuiCol.Text),
        text.ptr,
        text.ptr+text.length
    );
}

/**
    Render wrapped
*/
void incTextWrapped(string text) {
    igPushTextWrapPos(0f);
        igTextUnformatted(text.ptr, text.ptr+text.length);
    igPopTextWrapPos();
}

bool incTextLinkWithIcon(string icon, string text) {
    incText(icon);
    igSameLine(0, 4);
    return incTextLink(text);
}

bool incTextLink(string text) {
    import std.string : toStringz;
    igPushID(text.ptr, text.ptr+text.length);
    scope(exit) igPopID();
    auto storage = igGetStateStorage();
    auto visitedId = igGetID("LinkClicked");
    bool visited = ImGuiStorage_GetBool(storage, visitedId);
    igPushStyleColor(ImGuiCol.TextLink, visited ?
        ImVec4(0.132, 0.335, 0.523, 1) : ImVec4(0.186, 0.457, 0.708, 1));
    scope(exit) igPopStyleColor();
    bool clicked = igTextLink(text.toStringz);
    if (clicked) ImGuiStorage_SetBool(storage, visitedId, true);
    return clicked;
}

/**
    Show Node Icon Label
*/
void incNodeIconButton(ref Node node, string typeString) {
    if (node.enabled) incText(typeString);
    else incTextDisabled(typeString);
    if (igIsItemClicked())
        node.enabled = !node.enabled;
}

void incNodeIconButton(ref Node node) {
    import creator.utils;
    incNodeIconButton(node, incTypeIdToIcon(node.typeId()));
}
