module creator.widgets.shadow;
import i2d.imgui;
import std.math : ceil;

/**
    Draws a soft shadow behind a window whose background is drawn afterwards.
*/
void incRenderWindowShadow(ImVec2 pos, ImVec2 size, float falloff = 16, float startShade = 0.25) {
    auto drawList = igGetWindowDrawList();
    float rounding = igGetStyle().WindowRounding;
    int steps = cast(int)ceil(falloff);
    ImDrawList_PushClipRectFullScreen(drawList);
    scope(exit) ImDrawList_PopClipRect(drawList);

    // Compensate for alpha accumulation so the inner edge reaches startShade.
    foreach (i; 0..steps) {
        float spread = falloff * (1 - cast(float)i / steps);
        float alpha = (startShade / steps) / (1 - startShade * i / steps);
        ImDrawList_AddRectFilled(drawList,
            ImVec2(pos.x - spread, pos.y - spread),
            ImVec2(pos.x + size.x + spread, pos.y + size.y + spread),
            igGetColorU32(ImVec4(0, 0, 0, alpha)), rounding + spread);
    }
}
