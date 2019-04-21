import re, tables, strformat, sequtils, algorithm

var emailcounts = initCountTable[string]()
let re_sender = re"^(?:\S+ ){3,4}<= ([^@]+@(\S+))"

for line in "exim_mainlog".lines:
  if line =~ re_sender:
    emailcounts.inc matches[0]

var senders: seq[string]
for k in emailcounts.keys: senders.add k
proc countcmp(a, b: string): int = system.cmp(emailcounts[b], emailcounts[a])
let topsenders = senders.sorted(countcmp)

var i = 0
let width = repr(emailcounts[topsenders[0]]).len
for s in topsenders:
  echo &"{emailcounts[s]:>9} {s}"
  inc i
  if i == 5: break
