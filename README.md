## DB generation

> In UNIX, Linux

```
cd ./db/db_gen
```

- For Linux

```
cargo r --release
```

- For Windows x64

```
rustup target add x86_64-pc-windows-gnu
cargo r --target x86_64-pc-windows-gnu --release
```

- For Windows x32

```
rustup target add i686-pc-windows-gnu
cargo r --target i686-pc-windows-gnu --release
```

> In Windows pwsh

```
cd ".\db\db_gen\"
cargo r --release
```

## Distribution of tasks

> Task % 5 = student_id

Student_id - Student

- 0 - Oleg
- 1 - Alexey
- 2 - Eugene
- 3 - Matvey
- 4 - Daniil
