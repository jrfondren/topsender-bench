import npeg, tables, strformat, sequtils, algorithm

var emailcounts = initCountTable[string]()

var emailsender: string

# 'Fraph' can be replaced with 'Graph' on next release of npeg
let eximparser = peg "sender":
  sender <- +Fraph * ' ' * +Fraph * ' ' * +Fraph * ' ' * MaybeVPS * >Email * ' ':
    emailsender = $1
  MaybeVPS <- "<= " | +Fraph * " <= "
  Email <- +NonAt * '@' * +NonAt
  NonAt <- {'\x21'..'\x39', '\x41'..'\x7e'}
  Fraph <- {'\x21'..'\x7e'}

for line in "exim_mainlog".lines:
  if eximparser.match(line).ok:
    emailcounts.inc emailsender

var senders: seq[string]
for k in emailcounts.keys: senders.add k
proc countcmp(a, b: string): int = system.cmp(emailcounts[b], emailcounts[a])
let topsenders = senders.sorted(countcmp)

if len(emailcounts) == 0: quit "Didn't find any senders somehow!"
var i = 0
let width = repr(emailcounts[topsenders[0]]).len
for s in topsenders:
  echo &"{emailcounts[s]:>9} {s}"
  inc i
  if i == 5: break
