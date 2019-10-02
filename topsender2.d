import std.stdio, std.string, std.regex, std.array, std.algorithm;

extern (C) long getline(char** line, ulong* capacity, FILE* stream);

class Getline {
    private FILE* file;
    private char* line;
    private size_t capacity;
    import core.stdc.stdio : fopen, fclose;
    import core.stdc.stdlib : free;

    this(string path) {
        file = fopen(path.toStringz, "r".toStringz);
        line = null;
    }

    ~this() {
        close();
    }

    void close() {
        if (file) {
            fclose(file);
            file = null;
        }
        if (line) {
            free(line);
            line = null;
        }
    }

    bool empty() {
        return file == null;
    }

    string front() {
        long ret = getline(&line, &capacity, file);
        if (ret < 0) {
            close();
            return null;
        }
        else {
            return line[0 .. ret];
        }
    }

    void popFront() {
    }
}

T min(T)(T a, T b) {
    if (a < b)
        return a;
    return b;
}

struct Pcre {
}

struct PcreExtra {
}

extern (C) Pcre* pcre_compile(const(char)* pattern, int options,
        const(char)** errptr, int* erroffset, const(char)* tableptr);
extern (C) PcreExtra* pcre_study(const(Pcre)* code, int options, const(char)** errptr);
extern (C) int pcre_exec(const(Pcre)* code, const(PcreExtra)* extra,
        const(char)* subject, int length, int startoffset, int options, int* ovector, int ovecsize);

class Regex {
    private Pcre* emails;
    private PcreExtra* study;

    this(string pattern) {
        import std.string : toStringz;

        enum PCRE_STUDY_JIT_COMPILE = 1;
        const(char)* error;
        int erroffset;

        assert(emails = pcre_compile(pattern.toStringz, 0, &error, &erroffset, 0));
        assert(study = pcre_study(emails, PCRE_STUDY_JIT_COMPILE, &error));
    }

    ~this() {
        import std.stdc.stdlib : free;

        free(emails);
        free(study);
    }

    string opCall(string str) {
        int[9] matches;

        if (pcre_exec(emails, study, str.toStringz, str.length, 0, 0,
                matches.ptr, matches.length) > 0) {
            return str[matches[2] .. matches[3] - 1];
        }
        else {
            return null;
        }
    }
}

void main() {
    ulong[string] emailcounts;
    auto re = new Regex(`^(?:\S+ ){3,4}<= ([^@]+@(\S+))`);

    foreach (line; new Getline("exim_mainlog")) {
        if (line in emailcounts) {
            ++emailcounts[line];
        }
        else {
            ++emailcounts[line.idup];
        }
    }

    foreach (sender, count; emailcounts.keys.sort!((a,
            b) => emailcounts[a] > emailcounts[b]).take(5)) {
        writefln("%5s %s", emailcounts[senders[i]], senders[i]);
    }
}
