import std/[re, tables, strformat]

var
  emailcounts: CountTable[string]
  matches: array[2, string]
let
  re_sender = re"^(?:\S+ ){3,4}<= ([^ @]+@(\S+))"

for line in "exim_mainlog".lines:
  if line.contains(re_sender, matches):
    emailcounts.inc matches[0]

emailcounts.sort

var i = 0
for k, v in emailcounts:
  echo &"{v:>9} {k}"
  inc i
  if i == 5: break
