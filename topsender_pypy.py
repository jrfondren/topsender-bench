#! /usr/bin/env pypy
import re

senders = {}

def populate_senders(emails):
    reg = re.compile(r"^(?:\S+ ){3,4}<= ([^@]+@(\S+))")
    with open("exim_mainlog") as f:
        for line in f:
            m = reg.match(line)
            if m:
                email = m.group(1)
                if email in emails:
                    emails[email] += 1
                else:
                    emails[email] = 1


populate_senders(senders)

i = 0
for key, value in sorted(senders.items(), key=lambda x: x[1], reverse=True):
    i += 1
    if i > 5: break
    print("{} {}".format(value, key))
