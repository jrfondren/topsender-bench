# topsender-bench
In multiple languages, run a regex against a large email log and print
the top five email-sending addresses. Timings are with a real-world
exim\_mainlog, 415 MB in size, in which many lines do *not* match the regex.

## build
```
$ make
$ make bench
```

## timings, average of three runs

|  Speed | Language     | File                | Runtime     | MaxRSS   |  Comptime     | CompRSS  |
|--------|--------------|---------------------|-------------|----------|---------------|----------|
| 1x     | C            | \_pcre.c            | 611.1 ms    | 13.7 MB  | 164 ms        | 35.0 MB  |
| 4.0x   | C            | .c                  | 2408 ms     | 15.7 MB  | 164 ms        | 34.6 MB  |
|--------|--------------|---------------------|-------------|----------|---------------|----------|
| 1.3x   | D (dmd)      | \_pcre\_getline.d   | 771.3 ms    | 12.7 MB  | 934 ms        | 161 MB   |
| 1.4x   | D (dmd)      | \_pcre.d            | 832.8 ms    | 3.6 MB   | 975 ms        | 166 MB   |
| 9.8x   | D (dmd)      | .d (std.regex)      | 6966 ms     | 13.3 MB  | 2630 ms       | 598 MB   |
|--------|--------------|---------------------|-------------|----------|---------------|----------|
| 1.2x   | D (gdc)      | \_pcre\_getline.d   | 738.6 ms    | 13.3 MB  | 2240 ms       | 185 MB   |
| 1.3x   | D (gdc)      | \_pcre.d            | 816.3 ms    | 3.8 MB   | 2270 ms       | 192 MB   |
| 53x    | D (gdc)      | .d (std.regex)      | 32 s 204 ms | 22.6 MB  | 5620 ms       | 559 MB   |
|--------|--------------|---------------------|-------------|----------|---------------|----------|
| 1.2x   | D (ldc)      | \_pcre\_getline.d   | 715.8 ms    | 15.5 MB  | 3340 ms       | 248 MB   |
| 1.2x   | D (ldc)      | \_pcre.d            | 741.8 ms    | 6.6 MB   | 3440 ms       | 254 MB   |
| 2.8x   | D (ldc)      | .d (std.regex)      | 1728 ms     | 15.6 MB  | 8250 ms       | 719 MB   |
|--------|--------------|---------------------|-------------|----------|---------------|----------|
| 3.4x   | Nim          | .nim                | 2065 ms     | 11.4 MB  | 676 ms        | 53.7 MB  |
| 40x    | Nim          | \_regex.nim         | 22 s 190 ms | 11.2 MB  | 1070 ms       | 127 MB   |
| 3.6x   | Crystal      | .cr                 | 2217 ms     | 14.7 MB  | 7.63 s        | 210 MB   |
|--------|--------------|---------------------|-------------|----------|---------------|----------|
| 5.5x   | Rust         | .rs                 | 3375 ms     | 10.5 MB  | 12.5 (66.6) s | 361 MB   |
| 7.5x   | go           | .go                 | 5611 ms     | 55.5 MB  | 264 ms        | 48.9 MB  |
|--------|--------------|---------------------|-------------|----------|---------------|----------|
| 1.9x   | Perl         | .pl                 | 1059 ms     | 22.4 MB  |               |          |
| 3.1x   | Pypy         | \_pypy.py           | 1726 ms     | 92.3 MB  |               |          |
| 3.4x   | Python 3     | .py                 | 1902 ms     | 21.5 MB  |               |          |

## notes
- C's uthash.h is from https://troydhanson.github.io/uthash/
- regex.nim is using the 'regex' nimble module rather than nim's own PCRE-wrapping 're'
