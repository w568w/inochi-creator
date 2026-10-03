# Updating ImGui Dependencies

An ImGui update involves the C++ library, the cimgui wrapper and its generated
metadata, and the D declarations consumed by Creator. The steps below update
those sources together, regenerate the D binding and check the application.

[Prepare](#1-prepare-an-update-branch) |
[Select Versions](#2-select-the-upstream-revisions) |
[Update Sources](#3-update-i2d-imgui) |
[Generate](#6-regenerate-the-d-binding) |
[Verify](#7-build-and-check-the-application)

## 1. Prepare an Update Branch

Install the [Linux build dependencies](README.md#linux). Run the following
commands from the Creator repository root. Start with a clean working tree:

```sh
git status --short
git switch -c codex/update-imgui
```

Complete or set aside any pending changes before updating the dependencies.

## 2. Select the Upstream Revisions

Choose an i2d-imgui commit from
[upstream](https://github.com/Inochi2D/i2d-imgui), and a cimgui commit from its
[docking branch](https://github.com/cimgui/cimgui/tree/docking_inter) for the
ImGui release you want to use. Review that release's API changes in the
[Dear ImGui changelog](https://github.com/ocornut/imgui/blob/docking/docs/CHANGELOG.txt).

Replace the two commit placeholders below with those full commit hashes:

```sh
binding_rev=I2D_IMGUI_COMMIT
cimgui_rev=CIMGUI_COMMIT
git fetch https://github.com/Inochi2D/i2d-imgui.git "$binding_rev"
git fetch https://github.com/cimgui/cimgui.git "$cimgui_rev"
imgui_rev=$(git rev-parse "$cimgui_rev:imgui")
printf '%s\n' "$imgui_rev"
```

The `imgui` gitlink in cimgui identifies the matching Dear ImGui revision.
Keep these shell variables for the following steps, and use that revision
when updating the ImGui subtree.

## 3. Update i2d-imgui

```sh
git subtree pull --prefix=vendor/i2d-imgui https://github.com/Inochi2D/i2d-imgui "$binding_rev" --squash
```

If the merge stops, inspect `git status`. An upstream submodule-pointer
change can conflict with the vendored `deps/cimgui` directory. For that
file/directory conflict, keep the current cimgui tree and remove the
conflicting gitlink:

```sh
git restore --source=HEAD --staged --worktree -- vendor/i2d-imgui/deps/cimgui
git rm -f -- 'vendor/i2d-imgui/deps/cimgui~*'
git rm --ignore-unmatch -- vendor/i2d-imgui/.gitmodules
```

Resolve any remaining build or generator conflicts, stage the resolved files
with `git add`, and complete the merge with `git commit --no-edit`.
Finish this merge before moving to the next step.

## 4. Update cimgui

```sh
git subtree pull --prefix=vendor/i2d-imgui/deps/cimgui https://github.com/cimgui/cimgui "$cimgui_rev" --squash
```

For a conflict between the upstream `imgui` gitlink and the vendored ImGui
directory, preserve the current ImGui tree:

```sh
git restore --source=HEAD --staged --worktree -- vendor/i2d-imgui/deps/cimgui/imgui
git rm -f -- 'vendor/i2d-imgui/deps/cimgui/imgui~*'
git rm --ignore-unmatch -- vendor/i2d-imgui/deps/cimgui/.gitmodules
```

Resolve the remaining conflicts, stage the resolved files and finish the
merge with `git commit --no-edit`.

## 5. Update Dear ImGui

Import the revision selected from cimgui in step 2:

```sh
git subtree pull --prefix=vendor/i2d-imgui/deps/cimgui/imgui https://github.com/ocornut/imgui.git "$imgui_rev" --squash
```

At this point, cimgui's C wrapper and JSON metadata correspond to the
Dear ImGui source that Creator will compile.

## 6. Regenerate the D Binding

The D generator reads cimgui's JSON files in `generator/output`:

```sh
(
    cd vendor/i2d-imgui
    ldc2 -run generator/generator.d
    git diff -- source/i2d/imgui/bind/imgui.d
)
```

Review the changed declarations against the new API. Generator changes
belong in `vendor/i2d-imgui/generator/generator.d`; regenerate the binding
after editing that file. Adapt affected Creator calls in `source/creator`.

## 7. Build and Check the Application

First compare the native and D layouts:

```sh
(
    cd vendor/i2d-imgui
    bash tests/abi.sh
)
```

The check should end with `D/C++ ABI layouts match.` A mismatch identifies
a size, alignment or field offset to fix in the generator before rebuilding.

Build and run the unit tests, then build the release executable:

```sh
dub build --compiler=ldc2 --config=barebones --build=unittest --dest=build/unittest
build/unittest/out/inochi-creator --DRT-testmode=test-or-main
dub build --compiler=ldc2 --config=barebones --build=release --force
```

Run the new executable with a separate configuration directory:

```sh
(
    cd out
    INOCHI_CONFIG_PATH="$(mktemp -d)" ./inochi-creator
)
```

Open a model copy and check the welcome page, Nodes scrolling, docking,
font rendering and mesh tools at 100% and 200% UI scale. Apply and cancel
a mesh edit, then save, close and reopen the model to check the complete
editing workflow.

## 8. Record and Submit the Update

Update the revision table below to match the imported commits. Review the
generated declarations, API adaptations and build changes before committing:

```sh
git diff --check
git status --short
git add vendor/i2d-imgui source/creator MIGRATION.md
git commit -m "build: update ImGui to VERSION"
git push -u origin HEAD
```

Replace `VERSION` in the commit message with the target ImGui version, then
open a pull request for the update branch.

## Imported Upstream Revisions

| Component | Directory | Upstream commit |
| --- | --- | --- |
| i2d-imgui | `vendor/i2d-imgui` | `4ce11eb7ffd77f206cffc692922a4c264644810f` |
| cimgui | `vendor/i2d-imgui/deps/cimgui` | `bf9b984ef74470996fc6c9a6963d9e988e310101` |
| Dear ImGui | `vendor/i2d-imgui/deps/cimgui/imgui` | `b48d1afbe8ee8b238e2961dc363a949dd7304e23` |
