# topsender-bench
In multiple languages, run a regex against a large email log and print
the top five email-sending addresses. Timings are with a real-world
exim\_mainlog, 415 MB in size.

## build
```
$ make
```

## timings, average of three runs

| Speed | Language | File              | Runtime    | MaxRSS   | Flags                                                 |
|----------------------------------------------------------------------------------------------------------------------|
|    1x | C        | \_pcre.c          | 626 ms     | 15.7 MB  | -O3                                                   |
|  3.8x | C        | .c                | 2362 ms    | 15.6 MB  | -O3                                                   |
|  3.3x | Crystal  | .cr               | 2090 ms    | 26.2 MB  | crystal build --release                               |
|----------------------------------------------------------------------------------------------------------------------|
|  140x | D        | .d                | 1 min 28 s | 16.7 MB  | dmd -O                                                |
|   63x | D        | .d                | 39.5 s     | 16.7 MB  | dmd -inline                                           |
|   50x | D        | .d                | 31.6 s     | 16.6 MB  | dmd -inline -release -O -mcpu=native -boundscheck=off |
|  2.5x | D        | \_pcre.d          | 1590 ms    | 97.6 MB  | dmd -O                                                |
|  1.3x | D        | \_pcre\_getline.d | 830 ms     | 16.4 MB  | dmd -O                                                |
|  1.2x | D        | \_pcre\_getline.d | 780 ms     | 16.4 MB  | dmd -inline -release -O -mcpu=native -boundscheck=off |
|----------------------------------------------------------------------------------------------------------------------|
|   35x | D        | .d                | 21.8 s     | 20.2 MB  | ldc2 -O3                                              |
|  2.2x | D        | \_pcre.d          | 1392 ms    | 101.3 MB | ldc2 -O3                                              |
|  1.3x | D        | \_pcre\_getline.d | 798 ms     | 20.1 MB  | ldc2 -O3                                              |
|----------------------------------------------------------------------------------------------------------------------|
|  2.1x | Perl     | .pl               | 1290 ms    | 24.2 MB  |                                                       |
|  3.8x | Python 3 | .py               | 2350 ms    | 23.7 MB  |                                                       |

## notes
- caveat: I'm currently on chapter 1 of _The D Programming Language_
- C's uthash.h is from https://troydhanson.github.io/uthash/
