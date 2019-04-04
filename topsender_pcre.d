import std.stdio, std.string, std.regex, std.array, std.algorithm;

extern (C) int email_init();
extern (C) void email_free();
extern (C) char *email_sender(immutable char *line, ulong len);

T min(T)(T a, T b) {
	if (a < b) return a;
	return b;
}

void main() {
	ulong[string] emailcounts;

	email_init();

	foreach (line; File("exim_mainlog").byLine()) {
		auto m = email_sender(std.string.toStringz(line), line.length);
		if (m != null) {
			++emailcounts[std.string.fromStringz(m).idup];
		}
	}
	
	string[] senders = emailcounts.keys;
	sort!((a, b) { return emailcounts[a] > emailcounts[b]; })(senders);
	foreach (i; 0 .. min(senders.length, 5)) {
		writefln("%5s %s", emailcounts[senders[i]], senders[i]);
	}

	email_free();
}
