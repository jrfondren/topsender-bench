extern (C) int email_init();
extern (C) void email_free();
extern (C) char* email_sender(const(char)* line, ulong len);
extern (C) void getline_init(const(char)* filename);
extern (C) int getline_get(const(char)** line, ulong* len);
extern (C) void getline_free(const(char)** line);

void main() {
    import std.string : fromStringz;
    import std.exception : assumeUnique;
    import std.algorithm : min, sort;
    import std.stdio : writefln, File;

    ulong[string] senders;
    const(char)* line;
    ulong len;

    email_init;
    getline_init("exim_mainlog");
    scope (exit) {
        email_free;
        getline_free(&line);
    }

    while (-1 != getline_get(&line, &len)) {
        if (auto m = email_sender(line, len)) {
            if (ulong* count = m.fromStringz.assumeUnique in senders) {
                count[0]++;
            } else {
                senders[m.fromStringz.idup] = 1;
            }
        }
    }

    foreach (email; senders.keys.sort!((a, b) => senders[a] > senders[b])[0 .. min($, 5)]) {
        writefln!"%5s %s"(senders[email], email);
    }
}
