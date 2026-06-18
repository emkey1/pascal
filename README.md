# pascal

The **Pascal** front end for the **PSCAL** VM. It parses Pascal source into the
shared PSCAL AST, which the shared bytecode compiler lowers and the PSCAL VM
runs.

Pascal carries no VM or code generator of its own — it builds against
[`pscal-core`](https://github.com/emkey1/pscal-core), pulled in automatically via
CMake `FetchContent`.

## Build

```sh
cmake -S . -B build      # fetches and builds pscal-core, then pascal
cmake --build build -j
./build/pascal program.pas
```
