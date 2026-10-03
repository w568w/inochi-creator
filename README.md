# Inochi Creator

Inochi Creator is an open-source editor for the
[Inochi2D puppet format](https://github.com/Inochi2D/inochi2d). It lets you rig
layered 2D artwork for games, animation and VTubing. Models are animated by
transforming and deforming their textures in real time, creating movement
and the appearance of depth from 2D illustrations.

![Inochi Creator](https://user-images.githubusercontent.com/7032834/194462402-74c4a3e0-50ca-4b50-8e8d-164d97371f5a.png)
_Ada model by [ku-ini](https://twitter.com/duckmastah)_

For performing with an Inochi2D model, see
[Inochi Session](https://github.com/Inochi2D/inochi-session).

[Downloads](#downloads) | [Building](#building) |
[Documentation and Support](#documentation-and-support) |
[For Package Maintainers](#for-package-maintainers)

## Downloads

### Linux Builds

This fork's Linux x86_64 builds are available through
[GitHub Actions](https://github.com/w568w/inochi-creator/actions/workflows/linux-build.yml).

1. Open a successful run of **Linux build**.
2. Download the `inochi-creator-linux-x86_64` artifact from that run.
3. Extract the downloaded ZIP, then unpack and launch the application:

```sh
tar -xzf inochi-creator-linux-x86_64.tar.gz
./inochi-creator
```

The builds use Ubuntu 24.04 and require the SDL2, FreeType and D-Bus runtime
libraries. For building from source, see [Building](#building).

### Upstream Releases

Official Inochi Creator builds are distributed through
[itch.io](https://lunafoxgirlvt.itch.io/inochi-creator) and
[Steam](https://store.steampowered.com/app/2108550/Inochi_Creator/).
Upstream release notes and downloads are also available on
[GitHub](https://github.com/Inochi2D/inochi-creator/releases).

## Building

The application uses D and C++, so both toolchains are needed. Dub resolves
the D package dependencies during the build.

Clone the repository before following the instructions for your platform:

```sh
git clone https://github.com/w568w/inochi-creator.git
cd inochi-creator
```

### Linux

Install these build dependencies:

- A C++ compiler and development tools, such as GCC or Clang.
- A 64-bit D compiler; LDC is recommended, together with Dub.
- CMake 3.16 or newer.
- SDL2 and FreeType development packages.

Build the release configuration and run it from the output directory:

```sh
dub build --compiler=ldc2 --config=barebones --build=release
cd out
./inochi-creator
```

To build translations, install gettext and run these commands from the
repository root:

```sh
bash gentl.sh
mkdir -p out/i18n
mv out/*.mo out/i18n/
```

AppImage packaging additionally uses appimagetool.

### Windows

Build dependencies:

- Visual Studio 2022 with the **Desktop development with C++** workload.
- A 64-bit D compiler and Dub; LDC is recommended.
- CMake 3.16 or newer.
- SDL2 and FreeType development libraries available to CMake.

From PowerShell in the repository root, load the Visual Studio toolchain,
generate the Windows resources, then build:

```powershell
.\vcvars.ps1
dub build --compiler=ldc2 --config=meta
dub build --compiler=ldc2 --config=win32-full --build=release
```

The executable is written to `out/`. The SDL2 and FreeType runtime DLLs must
be available when launching it.

## Documentation and Support

- [User documentation](https://github.com/Inochi2D/inochi-creator/wiki)
  covers the editor and model-rigging workflow.
- [Issues for this fork](https://github.com/w568w/inochi-creator/issues)
  are the place for bug reports and feature requests about these builds.
- [Dependency updates](MIGRATION.md) explains how to update the vendored
  ImGui sources, regenerate the binding and verify the application.
- [Translation guide](TRANSLATING.md) explains how to contribute a language.
- [Contributors](CONTRIBUTORS.md) lists the people behind the project.

The upstream community is on
[Discord](https://discord.com/invite/abnxwN6r9v). You can support upstream
development on [Patreon](https://patreon.com/clipsey).

## For Package Maintainers

Use the `barebones` configuration for redistributable Linux packages.
The Inochi2D Project's branding assets require permission for redistribution;
requests go to the [upstream project](https://github.com/Inochi2D/inochi-creator/issues).

For downstream packages, set the issue-reporting links in
`source/creator/config.d` to the package's issue tracker so users can report
problems to its maintainer.

The source code is licensed under [BSD-2-Clause](LICENSE).

## Special Thanks

This project is funded through [NGI0 Entrust](https://nlnet.nl/entrust), a fund
established by [NLnet](https://nlnet.nl) with financial support from the
European Commission's [Next Generation Internet](https://ngi.eu) program.
Learn more at the [NLnet project page](https://nlnet.nl/project/Inochi2D).

[<img src="https://nlnet.nl/logo/banner.svg" alt="NLnet foundation logo" width="20%" />](https://nlnet.nl)
