# topsender-bench
In multiple languages, run a regex against a large email log and print
the top five email-sending addresses. Timings are with a real-world
exim\_mainlog, 415 MB in size.

## build
```
$ make
```

## timings, average of three runs

|  Speed | Language     | File                | Runtime     | MaxRSS   |
|--------|--------------|---------------------|-------------|----------|
|     1x | C            | \_pcre.c            | 499 ms      | 15.7 MB  |
| 3.833x | C            | .c                  | 1914 ms     | 15.7 MB  |
|--------|--------------|---------------------|-------------|----------|
| 1.193x | D (ldc)      | \_pcre\_getline.d   | 596 ms      | 20.1 MB  |
| 1.339x | D (dmd)      | \_pcre\_getline.d   | 669 ms      | 15.7 MB  |
| 2.186x | D (ldc)      | \_pcre.d            | 1092 ms     | 44.6 MB  |
| 2.459x | D (dmd)      | \_pcre.d            | 1227 ms     | 55.4 MB  |
| 3.941x | D (ldc)      | .d                  | 1968 ms     | 20.4 MB  |
|  12.2x | D (dmd)      | .d                  | 6 s 95 ms   | 16.4 MB  |
|--------|--------------|---------------------|-------------|----------|
| 2.868x | Nim          | \_getline.nim       | 1432 ms     | 15.7 MB  |
| 4.518x | Nim          | .nim                | 2256 ms     | 15.7 MB  |
| 4.614x | Nim          | \_altsort.nim       | 2624 ms     | 26.1 MB  |
| 5.388x | Nim          | \_npeg\_getline.nim | 2755 ms     | 14.2 MB  |
|  7.55x | Nim          | \_npeg.nim          | 4 s 860 ms  | 21.4 MB  |
| 78.25x | Nim          | \_regex.nim         | 39 s 82 ms  | 25.7 MB  |
|--------|--------------|---------------------|-------------|----------|
| 2.815x | Nim (danger) | \_getline.nim       | 1405 ms     | 15.8 MB  |
| 3.759x | Nim (danger) | .nim                | 1871 ms     | 15.8 MB  |
| 3.862x | Nim (danger) | \_altsort.nim       | 1922 ms     | 26.1 MB  |
| 5.225x | Nim (danger) | \_npeg\_getline.nim | 2601 ms     | 14.3 MB  |
|  6.22x | Nim (danger) | \_npeg.nim          | 3 s 97 ms   | 26.1 MB  |
| 60.84x | Nim (danger) | \_regex.nim         | 30 s 294 ms | 25.9 MB  |
|--------|--------------|---------------------|-------------|----------|
| 1.207x | Mercury      | \_getline.m         | 602.1 ms    | 76.9 MB  |
| 5.502x | Mercury      | .m                  | 2745 ms     | 108.2 MB |
|--------|--------------|---------------------|-------------|----------|
|   2.1x | Perl         | .pl                 | 1032 ms     | 24.1 MB  |
|     3x | Pypy         | \_pypy.py           | 1498 ms     | 92.5 MB  |
| 3.894x | Python 3     | .py                 | 1944 ms     | 23.3 MB  |

## notes
- C's uthash.h is from https://troydhanson.github.io/uthash/
- a previous chart had wildly wrong D timings due to an unnoticed
  difference in the regex (it lacked a leading anchor, causing it to
  thrash wildly on the many, many non-matching lines in the log)
- the D pcre shim stuff completely fails on macOS
- libc regex is much slower on macOS (11x) than it is on Fedora (3.8x)
- regex.nim is using the 'regex' nimble module rather than nim's own PCRE-wrapping 're'
- npeg.nim is using a Parsing Expression Grammar ('npeg' on
  nimble) rather than a regex

