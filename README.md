# pascal

The **Pascal** front end for the **PSCAL** VM. It parses Pascal source into the
shared PSCAL AST, which the shared bytecode compiler lowers and the PSCAL VM
runs.

Pascal carries no VM or code generator of its own. It builds against
[`pscal-core`](https://github.com/emkey1/pscal-core), pulled in automatically via
CMake `FetchContent`, so building this repo on its own fetches and builds the
shared core.

## Build

```sh
cmake -S . -B build      # fetches and builds pscal-core, then pascal
cmake --build build -j
./build/pascal program.pas
```

Pascal source files in the corpus and examples are stored without a `.pas`
suffix; the compiler runs them either way.

## Install

```sh
cmake --install build --prefix /usr/local
```

This puts the `pascal` binary in `<prefix>/bin`, the example programs in
`<prefix>/share/pascal/examples`, and the language docs in
`<prefix>/share/doc/pascal`. The fetched dependency (pscal-core) declares no
install rules, so only Pascal's own artifacts are installed.

## Test

The conformance corpus and the compiler regression suite live in
[`tests/`](tests/) and run under CTest:

```sh
ctest --test-dir build --output-on-failure
```

The suite is self-contained: the `.pas` corpus (`tests/Pascal`), the compiler
cases (`tests/compiler/pascal`), the shared harness and CLI fixtures
(`tests/tools`), the runtime units (`tests/lib`), and the sample data
(`tests/data`) are all vendored beside the runner.

You can also run it directly against any binary by pointing `PASCAL_BIN` at it
(this is how the umbrella build exercises the same corpus):

```sh
PASCAL_BIN=./build/pascal tests/run.sh
```

A minimal core build ships SDL, SQLite, networking, and graphics rendering off.
The runner detects those capabilities at startup and skips the fixtures that
need them (the SDL and screen-size demos, the SQLite smoke test, and the socket
test), so a default clone reports those as skipped rather than failed. Set
`RUN_SDL=1` or `RUN_NET_TESTS=1` to opt those back in when the underlying
support is present.

## Examples

Runnable programs live in [`examples/`](examples/), split into a `base/` set of
console and language programs and an `sdl/` set of graphics demos:

```sh
./build/pascal examples/base/hello
```

## Docs

In-depth language documentation is in [`docs/`](docs/):

- [`pascal_overview.md`](docs/pascal_overview.md): a tour of the language and toolchain
- [`pascal_language_reference.md`](docs/pascal_language_reference.md): the full language reference
- [`pascal_closures_for_dummies.md`](docs/pascal_closures_for_dummies.md): a guide to closures in Pascal
