#! /usr/bin/env rdmd
import std.stdio, std.string, std.regex, std.array, std.algorithm;

T min(T)(T a, T b) {
	if (a < b) return a;
	return b;
}

void main() {
	ulong[string] emailcounts;
	auto re = ctRegex!(r"^(?:\S+ ){3,4}<= ([^@]+@(\S+))");

	foreach (line; File("exim_mainlog").byLine()) {
		auto m = line.match(re);
		if (m) {
			++emailcounts[m.front[1].idup];
		}
	}
	
	string[] senders = emailcounts.keys;
	sort!((a, b) { return emailcounts[a] > emailcounts[b]; })(senders);
	foreach (i; 0 .. min(senders.length, 5)) {
		writefln("%5s %s", emailcounts[senders[i]], senders[i]);
	}
}
