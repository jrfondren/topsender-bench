extern (C) int email_init();
extern (C) void email_free();
extern (C) char* email_sender(const(char)* line, size_t len);

void main() {
    import std.string : fromStringz;
    import std.exception : assumeUnique;
    import std.algorithm : min, sort;
    import std.stdio : writefln, File;

    ulong[string] senders;

    email_init;
    scope (exit)
        email_free;

    foreach (line; File("exim_mainlog").byLine) {
        if (auto m = email_sender(line.ptr, line.length)) {
            auto s = m.fromStringz;
            if (ulong* count = s.assumeUnique in senders) {
                count[0]++;
            } else {
                senders[s.idup] = 1;
            }
        }
    }

    foreach (email; senders.keys.sort!((a, b) => senders[a] > senders[b])[0 .. min($, 5)]) {
        writefln!"%5s %s"(senders[email], email);
    }
}
