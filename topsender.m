:- module topsender.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.
:- implementation.
:- import_module exception, hash_table, list, string, pair, int.

:- type results == list(pair(string, int)).
:- type cache == hash_table(string, int).
:- mode cache_di == hash_table_di.
:- mode cache_uo == hash_table_uo.

:- pred open_input(string, input_stream, io, io).
:- mode open_input(in, out, di, uo) is det.

:- pred process(input_stream, cache, cache, io, io).
:- mode process(in, cache_di, cache_uo, di, uo) is det.

:- pred report(cache, results).
:- mode report(cache_di, out) is det.

:- pred dump(results::in, io::di, io::uo) is det.

:- pred inc(string, cache, cache).
:- mode inc(in, cache_di, cache_uo) is det.

:- pred email_init(io::di, io::uo) is det.
:- pred email_free(io::di, io::uo) is det.
:- pred email_sender(string::in, string::out) is semidet.

main(!IO) :-
    email_init(!IO),
    open_input("exim_mainlog", Stream, !IO),
    HT0 = hash_table.init_default(string_hash),
    process(Stream, HT0, HT1, !IO),
    email_free(!IO),
    report(HT1, Tops),
    dump(Tops, !IO).

open_input(Filename, Stream, !IO) :-
    io.open_input(Filename, Res, !IO),
    (Res = ok(Stream); Res = error(E), throw(E)).

process(Stream, !HT, !IO) :-
    io.read_line_as_string(Stream, Res, !IO),
    (
        Res = ok(Line),
        (
            email_sender(Line, Sender)
        ->
            inc(Sender, !HT)
        ;
            true
        ),
        process(Stream, !HT, !IO)
    ;
        Res = eof
    ;
        Res = error(E),
        throw(E)
    ).

:- func cmp(pair(string, int), pair(string, int)) = comparison_result.
cmp(A, B) = ordering(snd(B) `with_type` int, snd(A) `with_type` int).

report(HT, Results) :-
    sort(cmp, to_assoc_list(HT)) = L,
    Results = take_upto(5, L).

dump([], !IO).
dump([H|T], !IO) :-
    io.format("%10d %s\n", [i(snd(H)), s(fst(H))], !IO),
    dump(T, !IO).

inc(S, !HT) :-
    (
        hash_table.search(!.HT, S, Count)
    ->
        hash_table.det_update(S, Count + 1, !HT)
    ;
        hash_table.det_insert(S, 1, !HT)
    ).

:- pragma foreign_decl("C", "#include ""pcre_d_shim.h""").

:- pragma foreign_proc("C",
    email_free(IO0::di, IO::uo),
    [will_not_call_mercury, promise_pure],
"
    email_free();
    IO = IO0;
").

:- pragma foreign_proc("C",
    email_init(IO0::di, IO::uo),
    [will_not_call_mercury, promise_pure],
"
    email_init();
    IO = IO0;
").

:- pragma foreign_proc("C",
    email_sender(Str::in, Sender::out),
    [will_not_call_mercury, promise_pure],
"
    char *sender0 = email_sender(Str, strlen(Str));
    if (sender0 == NULL) {
        SUCCESS_INDICATOR = MR_FALSE;
    } else {
        MR_allocate_aligned_string_msg(Sender, strlen(sender0), MR_ALLOC_ID);
        strcpy(Sender, sender0);
        SUCCESS_INDICATOR = MR_TRUE;
    }
").
