# Dear ImGui 1.92.9b Fork

This fork includes the matching D binding, cimgui wrapper and Dear ImGui
sources. A normal clone or GitHub source archive is sufficient; there are
no dependency submodules and no global Dub package overrides to register.
The remaining D dependencies are resolved by Dub.

## Source Versions and Licenses

Creator is based on upstream `v0_8` commit
`dba60811cff224f8cc9ce367b1d9291bfa5f7640`.

| Directory | Upstream | Imported commit | License file |
| --- | --- | --- | --- |
| `vendor/i2d-imgui` | https://github.com/Inochi2D/i2d-imgui | `4ce11eb7ffd77f206cffc692922a4c264644810f` | `vendor/i2d-imgui/LICENSE` |
| `vendor/i2d-imgui/deps/cimgui` | https://github.com/cimgui/cimgui | `bf9b984ef74470996fc6c9a6963d9e988e310101` | `vendor/i2d-imgui/deps/cimgui/LICENSE` |
| `vendor/i2d-imgui/deps/cimgui/imgui` | https://github.com/ocornut/imgui | `b48d1afbe8ee8b238e2961dc363a949dd7304e23` | `vendor/i2d-imgui/deps/cimgui/imgui/LICENSE.txt` |

The three `git subtree --squash` imports retain upstream snapshot provenance
without adding their full histories. Their import commits remove the upstream
`.gitmodules` files and gitlinks so the nested sources can be ordinary files.
All upstream license files are retained.

Local dependency changes are confined to the binding's build, generator,
generated declarations and ABI tests, plus two FreeType lines in cimgui's
`CMakeLists.txt`. The Dear ImGui subtree has no local source changes.

## Linux Build

Prerequisites: LDC, Dub, CMake 3.16 or newer, a C++ compiler, and SDL2/FreeType
development files. AppImage tooling is only needed for packaging.

From the repository root:

```sh
dub build --compiler=ldc2 --config=barebones --build=release
cd out
./inochi-creator
```

If an existing checkout has a Dub selection for a registry or sibling copy of
`i2d-imgui`, run `dub upgrade i2d-imgui` before building. The selected package
must be the local `vendor/i2d-imgui` directory.

To isolate runtime settings, use the application's existing configuration
override with an absolute path to a test directory:

```sh
INOCHI_CONFIG_PATH=/absolute/path/to/test-config ./inochi-creator
```

## Checks

Compare 45 C++/D layout values and reproduce the generated binding:

```sh
cd vendor/i2d-imgui
bash tests/abi.sh
ldc2 -run generator/generator.d
git diff --exit-code -- source/i2d/imgui/bind/imgui.d
```

The generator uses the JSON metadata already included in the pinned cimgui
snapshot. Warnings for unused Vulkan and SDL3 backends are expected; this
fork builds SDL2/OpenGL3.

From the repository root, build and run the grid module's unit tests:

```sh
dub build --compiler=ldc2 --config=barebones --build=unittest --dest=build/unittest
build/unittest/out/inochi-creator --DRT-testmode=test-or-main
```

Ordinary `dub test` generates a second main function that conflicts with
`source/app.d`. These commands use the application's existing entry point
and the D runtime's test mode without changing it.

The Linux PR workflow performs these checks and a barebones release build.
The Linux build workflow runs on pushes to `v0_8` and manual dispatches. It
uploads `inochi-creator-linux-x86_64`, containing a tar.gz package and SHA-256
checksum. Packages are built on Ubuntu 24.04 with SDL2 and FreeType runtime
dependencies.
It has not been executed on GitHub during local preparation. The inherited
release, store and packaging workflows require a separate review before
enabling them for fork releases.

## Application Changes

- Native code and generated declarations use the same 1.92.9b docking version.
  The official SDL2/OpenGL3 backends replace the old D renderer port and handle
  dynamic font textures. There are no cross-version symbol aliases.
- Application calls use current texture references, font sizing, child flags,
  input, overlap and docking APIs. A small adapter preserves logical UI scale.
- Nodes uses `NoPadWithHalfSpacing` to prevent its full-row selectable's
  padding from feeding back into automatic column widths.
- The welcome page draws its 16-pixel soft shadow and 10-pixel rounded
  background through the current draw list's public API. Inner shadow opacity
  is 0.25; no draw buffers or private vertex/index cursors are spliced.
- Legacy dockspace `0x8B93E3BD` is copied to the current dockspace using
  DockBuilder. Before migration the INI is backed up as
  `imgui.ini.pre-imgui-1.92`; an existing backup is kept. Missing or damaged
  layouts get defaults, while valid current layouts are retained.
- Viewport overlay anchors keep tool options and Apply/Cancel inside the
  parent viewport.
- Grid Vertex Tool has integer `X Segments` and `Y Segments`, default 2,
  range 1-20. Each axis has `segments + 1` equally spaced points. Preview and
  creation share the same axes; settings last for the current process and
  synchronize selected editors. Existing meshes are not rebuilt.
- Five equivalent explicit class-cast branches avoid an LDC 1.43.0 internal
  compiler error. They are isolated in a separate commit.

## Validation Boundary

Linux release builds, ABI comparison and generator reproducibility pass.
The prepared fork also builds from a `git archive` extraction with no `.git`
directory or sibling binding checkout. Both the checkout and archive pass ABI
and generator checks. GUI smoke tests cover the welcome page at 100% and a
model copy at 200%, including legacy INI migration and normal application exit.
Grid tests cover 2x2, 3x3, 3x5, 1x1 and 20x20, offset/non-square rectangles,
reverse dragging, equal spacing, option inheritance, clamping and synchronization.

Earlier GUI tests used isolated configurations and model copies at 100% and
200% UI scaling. Nodes widths and horizontal scroll ranges were unchanged
between frames 120 and 720, including a long-name fixture. Selection,
multi-selection, reparenting, welcome reopen, grid preview/apply/cancel/undo,
legacy layout migration and manual undocking/redocking were checked. Runtime
source files in this fork are byte-identical to that tested checkout.

Windows and macOS builds remain unverified. Registry dependencies emit existing
deprecation warnings; the engine's source archive can also emit a non-fatal
`gitver` warning. MeshGroup Auto Meshing Bake from upstream issue #510 is
outside this change and remains unresolved.

Replacing a texture with a 2x image does not resize an existing mesh. Generating
a new mesh uses the new texture's pixel dimensions, so its local vertices are
twice as large; Scale=0.5 restores the earlier visual size. UV coordinates are
normalized, while vertices are not. This fork does not alter that behavior or
automatically change model scale.

## Updating the Subtrees

Update on a clean working tree and review matching cimgui/ImGui revisions as
a set. Use reviewed commit IDs, rather than floating branches:

```sh
git subtree pull --prefix=vendor/i2d-imgui https://github.com/Inochi2D/i2d-imgui BINDING_COMMIT --squash
git subtree pull --prefix=vendor/i2d-imgui/deps/cimgui https://github.com/cimgui/cimgui CIMGUI_COMMIT --squash
git subtree pull --prefix=vendor/i2d-imgui/deps/cimgui/imgui https://github.com/ocornut/imgui IMGUI_COMMIT --squash
```

These are nested subtrees: a parent upstream still has a submodule pointer
where this fork has a directory. If that pointer changes, Git can report a
file/directory conflict and create a gitlink named `cimgui~<merge-id>` or
`imgui~<merge-id>`. Preserve the currently pinned child subtree and remove
only that conflict's gitlink before completing the parent merge.

For the binding merge, after inspecting `git status`:

```sh
git restore --source=HEAD --staged --worktree -- vendor/i2d-imgui/deps/cimgui
git rm -f -- 'vendor/i2d-imgui/deps/cimgui~*'
git rm --ignore-unmatch -- vendor/i2d-imgui/.gitmodules
# Resolve any build/generator conflicts, review the staged diff, then:
git commit
```

For the cimgui merge, substitute `vendor/i2d-imgui/deps/cimgui/imgui` for the
child path, `vendor/i2d-imgui/deps/cimgui/imgui~*` for the conflict gitlink,
and `vendor/i2d-imgui/deps/cimgui/.gitmodules` for the metadata file.
These conflict steps apply only when the corresponding conflict exists.
Then update the child subtree explicitly to its reviewed version. The parent
pointer does not update the child's source automatically.

This procedure was exercised locally with simulated upstream submodule-pointer
updates for both parent repositories; the child source trees were preserved.
Do not run recursive submodule initialization in this fork.

After updating, regenerate cimgui metadata if the new upstream snapshot does
not already provide matching outputs, regenerate the D binding, update the
version table above, and repeat the ABI, unit, release and GUI checks.
