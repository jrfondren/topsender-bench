import npeg, tables, strformat, sequtils, algorithm

proc getline(lineptr: ptr cstring, n: ptr cint, stream: File): cint {.importc, header: "<stdio.h>".}
proc free(s: cstring) {.importc: "free", header: "<stdlib.h>".}
iterator getlines(filename: string): string {.inline.} =
  var
    getline_line: cstring
    getline_len: cint
    ret: int
    file = open(filename, bufSize=4096 * 2)
  defer:
    close(file)
    free(getline_line)
  while true:
    ret = getline(addr(getline_line), addr(getline_len), file)
    if ret < 0: break
    yield $getline_line

var emailcounts = initCountTable[string]()

let eximparser = peg "sender":
  sender <- +Graph * ' ' * +Graph * ' ' * +Graph * ' ' * MaybeVPS * >Email * ' ':
    emailcounts.inc $1
  MaybeVPS <- "<= " | +Graph * " <= "
  Email <- +NonAt * '@' * +NonAt
  NonAt <- Graph - '@'

for line in "exim_mainlog".getlines:
  discard eximparser.match(line)

emailcounts.sort()

if len(emailcounts) == 0: quit "Didn't find any senders somehow!"
var i = 0
for k, v in emailcounts:
  echo &"{v:>9} {k}"
  inc i
  if i == 5: break





