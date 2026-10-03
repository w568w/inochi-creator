module creator.viewport.common.mesheditor.tools.grid;

import creator.viewport.common.mesheditor.tools.enums;
import creator.viewport.common.mesheditor.tools.base;
import creator.viewport.common.mesheditor.tools.select;
import creator.viewport.common.mesheditor.operations;
import i18n;
import creator.viewport;
import creator.viewport.common;
import creator.viewport.common.mesh;
import creator.core.input;
import creator.core.actionstack;
import creator.actions;
import creator.ext;
import creator.widgets;
import creator;
import inochi2d;
import inochi2d.core.dbg;
import bindbc.opengl;
import i2d.imgui;
import std.stdio;
import std.array;
import std.algorithm.searching: countUntil;
import std.algorithm.mutation;
import std.algorithm.sorting;

class GridTool : NodeSelect {
    GridActionID currentAction;
    int xSegments = 2;
    int ySegments = 2;
    vec2 dragOrigin;
    vec2 dragEnd;
    int dragTargetXIndex = 0;
    int dragTargetYIndex = 0;

    enum GridActionID {
        Add = cast(int)(SelectActionID.End),
        Remove,
        Create,
        TranslateFree,
        TranslateX,
        TranslateY,
        TranslateUp,
        TranslateDown,
        TranslateLeft,
        TranslateRight,
        End
    }

    static float selectRadius = 16f;

    private float[][] gridAxes() {
        vec2 lower = vec2(min(dragOrigin.x, dragEnd.x), min(dragOrigin.y, dragEnd.y));
        vec2 upper = vec2(max(dragOrigin.x, dragEnd.x), max(dragOrigin.y, dragEnd.y));
        float[][] axes = [[], []];
        foreach (i; 0..ySegments + 1)
            axes[0] ~= lower.y + (upper.y - lower.y) * i / ySegments;
        foreach (i; 0..xSegments + 1)
            axes[1] ~= lower.x + (upper.x - lower.x) * i / xSegments;
        return axes;
    }

    bool isOnGrid(IncMesh mesh, int axis, vec2 mousePos, float threshold, out float value) {
        if (mesh.axes.length != 2)
            return false;
        if (mousePos.vector[axis] >= mesh.axes[1-axis][0] - threshold && mousePos.vector[axis] <= mesh.axes[1-axis][$-1] + threshold) {
            foreach (v ;mesh.axes[axis]) {
                if (abs(mousePos.vector[1-axis] - v) < threshold) {
                    value = v;
                    return true;
                }
            }
        }
        return false;
    }
    bool isOnEdge(IncMesh mesh, int axis, vec2 mousePos, float threshold, out float value) {
        if (mesh.axes.length != 2)
            return false;
        if (mousePos.vector[axis] >= mesh.axes[1-axis][0] - threshold && mousePos.vector[axis] <= mesh.axes[1-axis][$-1] + threshold) {
            if (abs(mousePos.vector[1-axis] - mesh.axes[axis][0]) < threshold) {
                value = mesh.axes[axis][0];
                return true;
            } else if (abs(mousePos.vector[1-axis] - mesh.axes[axis][$-1]) < threshold) {
                value = mesh.axes[axis][$-1];
                return true;
            }
        }
        return false;
    }


    override
    void setToolMode(VertexToolMode toolMode, IncMeshEditorOne impl) {
        assert(!impl.deformOnly || toolMode != VertexToolMode.Grid);
        isDragging = false;
        impl.isSelecting = false;
        impl.deselectAll();
    }

    override bool onDragStart(vec2 mousePos, IncMeshEditorOne impl) {
        auto implDrawable = cast(IncMeshEditorOneDrawable)(impl);
        assert(implDrawable !is null);
        auto mesh = implDrawable.getMesh();

        auto vtxAtMouse = impl.getVerticesByIndex([impl.vtxAtMouse])[0];
        if (vtxAtMouse) {
            if (mesh.axes.length != 2) {
                currentAction = GridActionID.End;
                return false;
            }

            currentAction = mesh.axes.length == 2 ? GridActionID.TranslateFree : GridActionID.End;
            vtxAtMouse = impl.getVerticesByIndex([impl.vtxAtMouse])[0];
            dragOrigin = vtxAtMouse.position;

            float threshold = selectRadius/incViewportZoom;
            float xValue, yValue;
            bool foundY = isOnEdge(mesh, 0, dragOrigin, threshold, yValue);
            bool foundX = isOnEdge(mesh, 1, dragOrigin, threshold, xValue);

            if (foundY) {
                dragOrigin.y = yValue;
                if (!foundX) {
                    currentAction = GridActionID.TranslateX;
                } else {
                    dragTargetXIndex = cast(int)mesh.axes[1].countUntil(vtxAtMouse.position.x);
                    if (dragTargetXIndex < 0)
                        currentAction = GridActionID.End;
                }
            }

            if (foundX) {
                dragOrigin.x = xValue;
                if (!foundY) {
                    currentAction = GridActionID.TranslateY;
                } else {
                    dragTargetYIndex = cast(int)mesh.axes[0].countUntil(vtxAtMouse.position.y);
                    if (dragTargetYIndex < 0)
                        currentAction = GridActionID.End;
                }
            }
            if (!foundX) {
                dragTargetXIndex = cast(int)mesh.axes[1].countUntil(vtxAtMouse.position.x);
                if (dragTargetXIndex < 0)
                    currentAction = GridActionID.End;
            }
            if (!foundY) {
                dragTargetYIndex = cast(int)mesh.axes[0].countUntil(vtxAtMouse.position.y);
                if (dragTargetYIndex < 0)
                    currentAction = GridActionID.End;
            }

            return true;
        } else if (mesh.axes.length < 2 || mesh.vertices.length == 0) {
            currentAction = GridActionID.Create;
            dragOrigin = mousePos;
            return true;
        }
        return false;
    }

    override bool onDragEnd(vec2 mousePos, IncMeshEditorOne impl) {
        if (currentAction == GridActionID.TranslateX || currentAction == GridActionID.TranslateY || currentAction == GridActionID.TranslateFree) {
            currentAction = GridActionID.End;
            return true;
        } else if (currentAction == GridActionID.Create) {
            dragEnd = mousePos;
            auto implDrawable = cast(IncMeshEditorOneDrawable)(impl);
            assert(implDrawable !is null);

            auto mesh = implDrawable.getMesh();
            MeshData meshData;
            
            meshData.gridAxes = gridAxes();
            meshData.regenerateGrid();
            mesh.copyFromMeshData(meshData);
            impl.refreshMesh();
            currentAction = GridActionID.End;
            return true;
        }
        return false;
    }

    override bool onDragUpdate(vec2 mousePos, IncMeshEditorOne impl) {
        auto implDrawable = cast(IncMeshEditorOneDrawable)(impl);
        assert(implDrawable !is null);
        auto mesh = implDrawable.getMesh();
        dragEnd = impl.mousePos;

        if (currentAction == GridActionID.TranslateX) {
            mesh.axes[1][dragTargetXIndex] = mousePos.x;
            mesh.axes[1].sort();
            dragTargetXIndex = cast(int)mesh.axes[1].countUntil(mousePos.x);
            MeshData meshData;
            meshData.gridAxes = mesh.axes[];
            meshData.regenerateGrid();
            mesh.copyFromMeshData(meshData);
            impl.refreshMesh();
            return true;
        } else if (currentAction == GridActionID.TranslateY) {
            mesh.axes[0][dragTargetYIndex] = mousePos.y;
            mesh.axes[0].sort();
            dragTargetYIndex = cast(int)mesh.axes[0].countUntil(mousePos.y);
            MeshData meshData;
            meshData.gridAxes = mesh.axes[];
            meshData.regenerateGrid();
            mesh.copyFromMeshData(meshData);
            impl.refreshMesh();
            return true;
        } else if (currentAction == GridActionID.TranslateFree) {
            mesh.axes[0][dragTargetYIndex] = mousePos.y;
            mesh.axes[0].sort();
            dragTargetYIndex = cast(int)mesh.axes[0].countUntil(mousePos.y);

            mesh.axes[1][dragTargetXIndex] = mousePos.x;
            mesh.axes[1].sort();
            dragTargetXIndex = cast(int)mesh.axes[1].countUntil(mousePos.x);
            MeshData meshData;
            meshData.gridAxes = mesh.axes[];
            meshData.regenerateGrid();
            mesh.copyFromMeshData(meshData);
            impl.refreshMesh();
            return true;
        } else if (currentAction == GridActionID.Create) {
            return true;
        }

        return false;
    }

    bool updateMeshEdit(ImGuiIO* io, IncMeshEditorOne impl, out bool changed) {
        auto implDrawable = cast(IncMeshEditorOneDrawable)(impl);
        assert(implDrawable !is null);
        auto mesh = implDrawable.getMesh();

        if (isDragging && incInputIsMouseReleased(ImGuiMouseButton.Left)) {
            onDragEnd(impl.mousePos, impl);
            isDragging = false;
        }

        if (igIsMouseClicked(ImGuiMouseButton.Left)) impl.maybeSelectOne = ulong(-1);

        incStatusTooltip(_("Drag to define grid mesh"), _("Left Mouse"));
        incStatusTooltip(_("Add/remove key points to axes"), _("Left Mouse"));
        incStatusTooltip(_("Change key point position in the axis"), _("Left Mouse"));

        if (!isDragging && incInputIsMouseReleased(ImGuiMouseButton.Left) && impl.maybeSelectOne != ulong(-1)) {
            impl.selectOne(impl.maybeSelectOne);
        }

        // Left double click action
        if (igIsMouseDoubleClicked(ImGuiMouseButton.Left)) {
            auto vtxAtMouse = impl.getVerticesByIndex([impl.vtxAtMouse])[0];
            if (vtxAtMouse !is null) {
                // Remove axis point from gridAxes
                float x = vtxAtMouse.position.x;
                float y = vtxAtMouse.position.y;
                if (mesh.axes.length == 2) {
                    auto ycount = mesh.axes[0].countUntil(y);
                    auto xcount = mesh.axes[1].countUntil(x);
                    if ((xcount == 0 || xcount == mesh.axes[1].length - 1) &&
                        (ycount == 0 || ycount == mesh.axes[0].length - 1)) {
                    } else if (xcount == 0 || xcount == mesh.axes[1].length - 1) {
                        // Removes only y axis
                        mesh.axes[0] = mesh.axes[0].remove(ycount);
                    } else if (ycount == 0 || ycount == mesh.axes[0].length - 1) {
                        // Removes only x axis
                        mesh.axes[1] = mesh.axes[1].remove(xcount);
                    } else {
                        mesh.axes[0] = mesh.axes[0].remove(ycount);
                        mesh.axes[1] = mesh.axes[1].remove(xcount);
                    }
                    MeshData meshData;
                    meshData.gridAxes = mesh.axes[];
                    meshData.regenerateGrid();
                    mesh.copyFromMeshData(meshData);
                    impl.refreshMesh();
                    impl.vtxAtMouse = ulong(-1);
                }

            } else {
                // Add axis point to grid Axes
                if (mesh.axes.length == 2) {
                    float x, y;
                    float threshold = selectRadius/incViewportZoom;
                    auto mousePos = impl.mousePos;
                    float yValue, xValue;
                    bool foundY = isOnGrid(mesh, 0, mousePos, threshold, yValue);
                    bool foundX = isOnGrid(mesh, 1, mousePos, threshold, xValue);

                    if (!foundY) {
                        y = mousePos.y;
                        for (int i = 0; i < mesh.axes[0].length; i ++)
                            if (y < mesh.axes[0][i]) {
                                mesh.axes[0].insertInPlace(i, y);
                                break;
                            }
                    }
                    if (!foundX) {
                        x = mousePos.x;
                        for (int i = 0; i < mesh.axes[1].length; i ++)
                            if (x < mesh.axes[1][i]) {
                                mesh.axes[1].insertInPlace(i, x);
                                break;
                            }
                    }
                    MeshData meshData;
                    meshData.gridAxes = mesh.axes[];
                    meshData.regenerateGrid();
                    mesh.copyFromMeshData(meshData);
                    impl.refreshMesh();
                }
            }

        }

        // Dragging
        if (!isDragging && incDragStartedInViewport(ImGuiMouseButton.Left) && igIsMouseDown(ImGuiMouseButton.Left) && incInputIsDragRequested(ImGuiMouseButton.Left)) {
            onDragStart(impl.mousePos, impl);
            isDragging = true;
        }
        if (isDragging)
            onDragUpdate(impl.mousePos, impl);

        return true;
    }

    override bool update(ImGuiIO* io, IncMeshEditorOne impl, int action, out bool changed) {
        super.update(io, impl, action, changed);

        if (!impl.deformOnly)
            updateMeshEdit(io, impl, changed);
        return changed;
    }

    override void draw (Camera camera, IncMeshEditorOne impl) {
        if (currentAction == GridActionID.Create) {
            vec3[] lines;
            vec4 color = vec4(0.2, 0.9, 0.9, 1);

            auto axes = gridAxes();
            foreach (y; axes[0])
                lines ~= [vec3(axes[1][0], y, 0), vec3(axes[1][$-1], y, 0)];
            foreach (x; axes[1])
                lines ~= [vec3(x, axes[0][0], 0), vec3(x, axes[0][$-1], 0)];
            inDbgSetBuffer(lines);
            inDbgDrawLines(color, mat4.identity());

        } else if (currentAction == GridActionID.TranslateX || currentAction == GridActionID.TranslateY || currentAction == GridActionID.TranslateFree) {

        } else {

        }
    }
}

class GridToolInfo : ToolInfoBase!GridTool {
    private int xSegments = 2;
    private int ySegments = 2;

    override Tool newTool() {
        auto tool = new GridTool;
        tool.xSegments = xSegments;
        tool.ySegments = ySegments;
        return tool;
    }

    override
    void setupToolMode(IncMeshEditorOne e, VertexToolMode mode) {
        e.setToolMode(mode);
        e.setPath(null);
        e.deforming = false;
        e.refreshMesh();
    }

    override
    bool viewportTools(bool deformOnly, VertexToolMode toolMode, IncMeshEditorOne[Node] editors) {
        if (!deformOnly)
            return super.viewportTools(deformOnly, toolMode, editors);
        return false;
    }

    override
    bool displayToolOptions(bool deformOnly, VertexToolMode toolMode, IncMeshEditorOne[Node] editors) {
        if (deformOnly) return false;
        import std.string : toStringz;

        igBeginGroup();
        igPushItemWidth(128);
        igInputInt(_("X Segments").toStringz, &xSegments, 1, 1);
        igInputInt(_("Y Segments").toStringz, &ySegments, 1, 1);
        igPopItemWidth();
        igEndGroup();
        xSegments = clamp(xSegments, 1, 20);
        ySegments = clamp(ySegments, 1, 20);
        foreach (e; editors) {
            if (auto tool = cast(GridTool)e.getTool()) {
                tool.xSegments = xSegments;
                tool.ySegments = ySegments;
            }
        }
        return false;
    }

    override VertexToolMode mode() { return VertexToolMode.Grid; };
    override string icon() { return "";}
    override string description() { return _("Grid Vertex Tool");}
}

unittest {
    auto tool = new GridTool;
    assert(tool.xSegments == 2 && tool.ySegments == 2);
    foreach (segments; [vec2i(2, 2), vec2i(3, 3), vec2i(3, 5), vec2i(1, 1), vec2i(20, 20)]) {
        tool.xSegments = segments.x;
        tool.ySegments = segments.y;
        foreach (reverse; [false, true]) {
            tool.dragOrigin = reverse ? vec2(167, 113) : vec2(47, 33);
            tool.dragEnd = reverse ? vec2(47, 33) : vec2(167, 113);
            MeshData mesh;
            mesh.gridAxes = tool.gridAxes();
            assert(mesh.gridAxes[0].length == segments.y + 1);
            assert(mesh.gridAxes[1].length == segments.x + 1);
            foreach (axis; 0..2) {
                auto values = mesh.gridAxes[axis];
                float spacing = (values[$-1] - values[0]) / (values.length - 1);
                foreach (i; 1..values.length)
                    assert(abs(values[i] - values[i-1] - spacing) < 0.0001f);
            }
            assert(mesh.gridAxes[0][0] == 33 && mesh.gridAxes[0][$-1] == 113);
            assert(mesh.gridAxes[1][0] == 47 && mesh.gridAxes[1][$-1] == 167);
            assert(mesh.regenerateGrid());
            assert(mesh.vertices.length == (segments.x + 1) * (segments.y + 1));
            assert(mesh.indices.length == segments.x * segments.y * 6);
        }
    }

    auto info = new GridToolInfo;
    info.xSegments = 3;
    info.ySegments = 5;
    auto inherited = cast(GridTool)info.newTool();
    assert(inherited.xSegments == 3 && inherited.ySegments == 5);

    auto first = new IncMeshEditorOneNode(false);
    auto second = new IncMeshEditorOneNode(false);
    first.setToolMode(VertexToolMode.Grid);
    second.setToolMode(VertexToolMode.Grid);
    IncMeshEditorOne[Node] editors = [new Node(1001): first, new Node(1002): second];
    auto ctx = igCreateContext();
    scope(exit) igDestroyContext(ctx);
    auto io = igGetIO();
    io.IniFilename = null;
    io.DisplaySize = ImVec2(800, 600);
    io.DeltaTime = 1.0f / 60;
    io.BackendFlags |= ImGuiBackendFlags.RendererHasTextures;
    igNewFrame();
    igBegin("Grid options");
    info.displayToolOptions(false, VertexToolMode.Grid, editors);
    igEnd();
    igEndFrame();
    foreach (e; editors) {
        auto selectedTool = cast(GridTool)e.getTool();
        assert(selectedTool.xSegments == 3 && selectedTool.ySegments == 5);
    }
    info.xSegments = -10;
    info.ySegments = 100;
    igNewFrame();
    igBegin("Grid options");
    info.displayToolOptions(false, VertexToolMode.Grid, editors);
    igEnd();
    igEndFrame();
    foreach (e; editors) {
        auto selectedTool = cast(GridTool)e.getTool();
        assert(selectedTool.xSegments == 1 && selectedTool.ySegments == 20);
    }
}
