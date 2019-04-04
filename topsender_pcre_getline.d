import std.stdio, std.string, std.regex, std.array, std.algorithm;

extern (C) int email_init();
extern (C) void email_free();
extern (C) char *email_sender(immutable char *line, ulong len);
extern (C) void getline_init(immutable(char) *filename);
extern (C) int getline_get(immutable(char) **line, ulong *len);
extern (C) void getline_free(immutable(char) **line);

T min(T)(T a, T b) {
	if (a < b) return a;
	return b;
}

void main() {
	ulong[string] emailcounts;
	immutable(char) *line;
	ulong len;

	email_init();
	getline_init(std.string.toStringz("exim_mainlog"));

	while (-1 != getline_get(&line, &len)) {
		auto m = email_sender(line, len);
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
	getline_free(&line);
}
