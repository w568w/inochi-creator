/*
    Copyright © 2020-2023, ImGui & Inochi2D Project
    Distributed under the MIT, see ImGui LICENSE file.

    Authors: Luna Nielsen
*/
module creator.backend.gl;
import creator.core.dpi;
import i2d.imgui;
import bindbc.sdl;

alias incGLBackendInit = ImGui_ImplOpenGL3_Init;
alias incGLBackendShutdown = ImGui_ImplOpenGL3_Shutdown;
alias incGLBackendNewFrame = ImGui_ImplOpenGL3_NewFrame;
alias incGLBackendRenderDrawData = ImGui_ImplOpenGL3_RenderDrawData;

void incGLBackendBeginRender() {
    version (UseUIScaling) {
        version (OSX) {
        } else {
            // Keep layout and input in logical pixels; the official renderer
            // uses FramebufferScale to map them back to the drawable.
            float uiScale = incGetUIScale();
            auto io = igGetIO();
            io.DisplaySize.x /= uiScale;
            io.DisplaySize.y /= uiScale;
            io.DisplayFramebufferScale.x *= uiScale;
            io.DisplayFramebufferScale.y *= uiScale;
            int mouseX, mouseY;
            uint buttons = SDL_GetMouseState(&mouseX, &mouseY);
            if (SDL_GetMouseFocus() !is null || buttons != 0)
                ImGuiIO_AddMousePosEvent(io, mouseX / uiScale, mouseY / uiScale);
            else
                ImGuiIO_AddMousePosEvent(io, -float.max, -float.max);
        }
    }
}

bool incGLBackendProcessEvent(const(SDL_Event)* event) {
    version (UseUIScaling) {
        if (event.type == SDL_MOUSEMOTION) {
            SDL_Event scaled = *event;
            scaled.motion.x = cast(int)(event.motion.x / incGetUIScale());
            scaled.motion.y = cast(int)(event.motion.y / incGetUIScale());
            return ImGui_ImplSDL2_ProcessEvent(&scaled);
        }
    }
    return ImGui_ImplSDL2_ProcessEvent(event);
}
