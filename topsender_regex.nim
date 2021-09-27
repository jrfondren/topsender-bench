import std/[tables, strformat]
import regex

var
  emailcounts: CountTable[string]
  matches: RegexMatch
let re_sender = re"^(?:\S+ ){3,4}<= ([^ @]+@(\S+))"

for line in "exim_mainlog".lines:
  if line.find(re_sender, matches):
    emailcounts.inc line[matches.group(0)[0]]

emailcounts.sort

var i = 0
for k, v in emailcounts:
  echo &"{v:>9} {k}"
  inc i
  if i == 5: break
