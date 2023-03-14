## DB generation

> UNIX, Linux

```
cd ./db/db_gen
```

- Linux

```
cargo r --release
```

- Windows x64

```
rustup target add x86_64-pc-windows-gnu
cargo r --target x86_64-pc-windows-gnu --release
```

- Windows x32

```
rustup target add i686-pc-windows-gnu
cargo r --target i686-pc-windows-gnu --release
```
