# Inochi Creator

Inochi Creator is an editor for rigging and animating layered 2D models in the
[Inochi2D format](https://github.com/Inochi2D/inochi2d).

![Inochi Creator](https://user-images.githubusercontent.com/7032834/194462402-74c4a3e0-50ca-4b50-8e8d-164d97371f5a.png)
_Ada model by [ku-ini](https://twitter.com/duckmastah)_

## Downloads

[Linux x86_64 builds](https://github.com/w568w/inochi-creator/actions/workflows/linux-build.yml)

Upstream releases: [GitHub](https://github.com/Inochi2D/inochi-creator/releases),
[itch.io](https://lunafoxgirlvt.itch.io/inochi-creator),
[Steam](https://store.steampowered.com/app/2108550/Inochi_Creator/).

## Building on Linux

Requirements: LDC, Dub, CMake 3.16+, a C++ compiler, and SDL2/FreeType
development packages.

```sh
dub build --compiler=ldc2 --config=barebones --build=release
cd out
./inochi-creator
```

## Development

[Dependency maintenance](MIGRATION.md) |
[Translation guide](TRANSLATING.md) |
[Contributors](CONTRIBUTORS.md)

## Project Links

[Upstream](https://github.com/Inochi2D/inochi-creator) |
[Documentation](https://github.com/Inochi2D/inochi-creator/wiki) |
[Discord](https://discord.com/invite/abnxwN6r9v) |
[Patreon](https://patreon.com/clipsey)

## License

Source code: [BSD-2-Clause](LICENSE). Redistribution of branding assets requires
permission from the [Inochi2D Project](https://github.com/Inochi2D/inochi-creator/issues).

## Special Thanks

This project is funded through [NGI0 Entrust](https://nlnet.nl/entrust), a fund established by [NLnet](https://nlnet.nl) with financial support from the European Commission's [Next Generation Internet](https://ngi.eu) program. Learn more at the [NLnet project page](https://nlnet.nl/project/Inochi2D).

[<img src="https://nlnet.nl/logo/banner.svg" alt="NLnet foundation logo" width="20%" />](https://nlnet.nl)
