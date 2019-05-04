# topsender-bench
In multiple languages, run a regex against a large email log and print
the top five email-sending addresses. Timings are with a real-world
exim\_mainlog, 415 MB in size.

## build
```
$ make
```

## timings, average of three runs

|  Speed | Language    | File                | Runtime     | MaxRSS  |
|--------|-------------|---------------------|-------------|---------|
|     1x | C           | \_pcre.c            | 608 ms      | 15.8 MB |
|   3.8x | C           | .c                  | 2358 ms     | 15.7 MB |
|--------|-------------|---------------------|-------------|---------|
| 1.186x | D (ldc)     | \_pcre\_getline.d   | 735 ms      | 20.1 MB |
| 1.296x | D (dmd)     | \_pcre\_getline.d   | 803 ms      | 15.9 MB |
| 2.140x | D (ldc)     | \_pcre.d            | 1326 ms     | 45.4 MB |
| 2.515x | D (dmd)     | \_pcre.d            | 1558 ms     | 40.5 MB |
|   3.8x | D (ldc)     | .d                  | 2349 ms     | 20.4 MB |
|  12.3x | D (dmd)     | .d                  | 8 s 574 ms  | 16.3 MB |
|--------|-------------|---------------------|-------------|---------|
|  3.32x | Nim (devel) | \_npeg\_getline.nim | 2018 ms     | 14.2 MB |
|  3.95x | Nim (devel) | .nim                | 2440 ms     | 15.7 MB |
|  4.25x | Nim         | \_altsort.nim       | 2624 ms     | 15.7 MB |
|  4.27x | Nim         | \_npeg.nim          | 2635 ms     | 21.3 MB |
|  60.2x | Nim         | \_regex.nim         | 37 s 152 ms | 25.7 MB |
|--------|-------------|---------------------|-------------|---------|
|   2.1x | Perl        | .pl                 | 1297 ms     | 24.1 MB |
|  3.29x | Pypy        | \_pypy.py           | 2002 ms     | 87.4 MB |
|  3.88x | Python 3    | .py                 | 2358 ms     | 23.4 MB |

## notes
- C's uthash.h is from https://troydhanson.github.io/uthash/
- a previous chart had wildly wrong D timings due to an unnoticed
  difference in the regex (it lacked a leading anchor, causing it to
  thrash wildly on the many, many non-matching lines in the log)
- the D pcre shim stuff completely fails on macOS, so it's absent from
  this chart
- libc regex is much slower on macOS (11x) than it is on Fedora (3.8x)
- regex.nim is using the 'regex' nimble module rather than nim's own PCRE-wrapping 're'
- npeg.nim is using a Parsing Expression Grammar ('npeg' on
  nimble) rather than a regex

