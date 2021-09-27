#! /usr/bin/env rdmd
void main() {
    import std.regex : regex, matchFirst, ctRegex;
    import std.exception : assumeUnique;
    import std.algorithm : min, sort;
    import std.stdio : writefln, File;

	ulong[string] senders;

	foreach (line; File("exim_mainlog").byLine) {
        if (auto m = line.matchFirst(ctRegex!(`^(?:\S+ ){3,4}<= ([^ @]+@(\S+))`))) {
            if (ulong* count = m[1].assumeUnique in senders) {
                count[0]++;
            } else {
                senders[m[1].idup] = 1;
            }
        }
	}
	
	foreach (email; senders.keys.sort!((a, b) => senders[a] > senders[b])[0 .. min($, 5)]) {
		writefln!"%5s %s"(senders[email], email);
	}
}
