# topsender-bench
In multiple languages, run a regex against a large email log and print
the top five email-sending addresses. Timings are with a real-world
exim\_mainlog, 415 MB in size.

## build
```
$ make
```

## timings, average of three runs

| Speed | Language | File          | Runtime     | MaxRSS  | Flags                   |
|-------|----------|---------------|-------------|---------|-------------------------|
|    1x | C        | \_pcre.c      | 1027 ms     | 14.9 MB | -O3                     |
|   11x | C        | .c            | 11 s 984 ms | 14.9 MB | -O3                     |
|  3.2x | Crystal  | .cr           | 3 s 292 ms  | 19.2 MB | crystal build --release |
|-------|----------|---------------|-------------|---------|-------------------------|
|   16x | D        | .d            | 17 s 758 ms | 14.8 MB | dmd -O                  |
|  8.5x | D        | .d            | 9 s 742 ms  | 15.1 MB | ldc2 -O                 |
|-------|----------|---------------|-------------|---------|-------------------------|
|  3.4x | Nim      | \_altsort.nim | 4 s 547 ms  | 14.6 MB | -d:release              |
|  4.9x | Nim      | \_npeg.nim    | 5 s 20 ms   | 10.4 MB | -d:release              |
| 50.2x | Nim      | \_regex.nim   | 52 s 521 ms | 24.6 MB | -d:release              |
|-------|----------|---------------|-------------|---------|-------------------------|
|  2.3x | Perl     | .pl           | 2313 ms     | 18.4 MB |                         |
|  4.9x | Python 3 | .py           | 5 s 1 ms    | 22.9 MB |                         |

## notes
- C's uthash.h is from https://troydhanson.github.io/uthash/
- a previous chart had wildly wrong D timings due to an unnoticed
  difference in the regex (it lacked a leading anchor, causing it to
  thrash wildly on the many, many non-matching lines in the log)
- the D pcre shim stuff completely fails on macOS, so it's absent from
  this chart
- .nim is excluded as it's wildly more expensive than altsort (fixed
  in next release--should then cost the same as altsort)
- regex.nim is using the 'regex' nimble module rather than nim's own PCRE-wrapping 're'
- npeg.nim is using a Parsing Expression Grammar ('npeg' on
  nimble) rather than a regex
