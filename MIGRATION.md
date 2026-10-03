# Dependency Maintenance

## Source Versions

Creator is based on upstream `v0_8` commit
`dba60811cff224f8cc9ce367b1d9291bfa5f7640`.

| Directory | Upstream | Commit |
| --- | --- | --- |
| `vendor/i2d-imgui` | https://github.com/Inochi2D/i2d-imgui | `4ce11eb7ffd77f206cffc692922a4c264644810f` |
| `vendor/i2d-imgui/deps/cimgui` | https://github.com/cimgui/cimgui | `bf9b984ef74470996fc6c9a6963d9e988e310101` |
| `vendor/i2d-imgui/deps/cimgui/imgui` | https://github.com/ocornut/imgui | `b48d1afbe8ee8b238e2961dc363a949dd7304e23` |

## Updating Dependencies

Choose matching cimgui and Dear ImGui revisions. From the repository root,
update each subtree in order, resolving conflicts before the next pull:

```sh
git subtree pull --prefix=vendor/i2d-imgui https://github.com/Inochi2D/i2d-imgui BINDING_COMMIT --squash
git subtree pull --prefix=vendor/i2d-imgui/deps/cimgui https://github.com/cimgui/cimgui CIMGUI_COMMIT --squash
git subtree pull --prefix=vendor/i2d-imgui/deps/cimgui/imgui https://github.com/ocornut/imgui IMGUI_COMMIT --squash
```

Upstream i2d-imgui and cimgui track their child dependencies as submodules.
A changed submodule pointer can cause a file/directory conflict during a
subtree update. For such a conflict in the i2d-imgui merge, preserve the
current cimgui tree and remove the conflicting gitlink:

```sh
git restore --source=HEAD --staged --worktree -- vendor/i2d-imgui/deps/cimgui
git rm -f -- 'vendor/i2d-imgui/deps/cimgui~*'
git rm --ignore-unmatch -- vendor/i2d-imgui/.gitmodules
```

Resolve the remaining conflicts and commit the merge. For a cimgui update,
use `vendor/i2d-imgui/deps/cimgui/imgui` as the child path and
`vendor/i2d-imgui/deps/cimgui/.gitmodules` as the metadata path.
Then update the child subtree to its chosen revision.

## Checks

Regenerate the D binding and update the version table. Run from the repository
root:

```sh
(
    cd vendor/i2d-imgui
    ldc2 -run generator/generator.d
    bash tests/abi.sh
    git diff -- source/i2d/imgui/bind/imgui.d
)
dub build --compiler=ldc2 --config=barebones --build=unittest --dest=build/unittest
build/unittest/out/inochi-creator --DRT-testmode=test-or-main
```
