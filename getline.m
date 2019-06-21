:- module getline.
:- interface.
:- import_module io, hash_table, int.

:- type cache == hash_table(string, int).
:- mode cache_di == hash_table_di.
:- mode cache_uo == hash_table_uo.

:- type result
    --->    ok
    ;       open_failed
    ;       regex_failed.

    % Open file by name (first argument) and read it line by line, testing
    % each like by a regex (second argument), while populating the provided
    % hash table with counts of the regex's matches.
    %
    % The regex needs to have a single capturing group.
    %
:- pred read_count_matches(string, string, getline.result, cache, cache, io, io).
:- mode read_count_matches(in, in, out, cache_di, cache_uo, di, uo) is det.

:- implementation.

:- func inc(string::in, cache::cache_di) = (cache::cache_uo) is det.
inc(S, HT0) = HT :-
    (
        hash_table.search(HT0, S, Count)
    ->
        hash_table.det_update(S, Count + 1, HT0, HT)
    ;
        hash_table.det_insert(S, 1, HT0, HT)
    ).

:- pragma foreign_decl("C", "#include <pcre.h>").
:- pragma foreign_export_enum("C", getline.result/0, [prefix("GLR_"), uppercase]).
:- pragma foreign_export("C", inc(in, cache_di) = cache_uo, "IncHT").

:- pragma foreign_proc("C",
    read_count_matches(Filename::in, RegexStr::in, Res::out, HT0::cache_di, HT::cache_uo, IO0::di, IO::uo),
    [promise_pure],
"
    FILE *file;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    pcre *regex;
    pcre_extra *study;
    int matches[4];
    int regresult;
    const char *error;
    int erroffset;

    regex = pcre_compile(RegexStr, 0, &error, &erroffset, 0);
    if (regex == NULL) {
        Res = GLR_REGEX_FAILED;
    } else {
        study = pcre_study(regex, PCRE_STUDY_JIT_COMPILE, &error);
        if (study == NULL) {
            Res = GLR_REGEX_FAILED;
        } else {
            if (NULL == (file = fopen(Filename, ""r""))) {
                Res = GLR_OPEN_FAILED;
            } else {
                while (-1 != (read = getline(&line, &len, file))) {
                    regresult = pcre_exec(regex, study, line, len, 0, 0, matches, sizeof matches);
                    if (regresult < -1) break;
                    if (regresult > 0) {
                        line[matches[3]] = '\\0';
                        MR_String Match;
                        MR_allocate_aligned_string_msg(Match, matches[3] - matches[2], MR_ALLOC_ID);
                        strcpy(Match, &line[matches[2]]);
                        HT0 = IncHT(Match, HT0);
                    }
                }
                Res = GLR_OK;
                if (line) free(line);
            }
            pcre_free(study);
        }
        pcre_free(regex);
    }
    HT = HT0;
    IO = IO0;
").
