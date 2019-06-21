:- module topsender_getline.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.
:- implementation.
:- import_module hash_table, list, string, pair, int.
:- import_module getline.

:- type results == list(pair(string, int)).

:- pred report(cache, results).
:- mode report(cache_di, out) is det.

:- pred dump(results::in, io::di, io::uo) is det.

main(!IO) :-
    getline.read_count_matches(Log, Regex, Res, HT0, HT, !IO),
    (
        Res = ok,
        report(HT, Tops),
        dump(Tops, !IO)
    ;
        Res = open_failed
    ;
        Res = regex_failed
    ),
    Log = "exim_mainlog",
    Regex = "^(?:[^ ]+ ){3,4}<= ([^@]+@([^ ]+))",
    HT0 = hash_table.init(string_hash, 16, 0.9).

:- func cmp(pair(string, int), pair(string, int)) = comparison_result.
cmp(A, B) = ordering(snd(B) `with_type` int, snd(A) `with_type` int).

report(HT, Results) :-
    sort(cmp, to_assoc_list(HT)) = L,
    Results = take_upto(5, L).

dump([], !IO).
dump([H|T], !IO) :-
    io.format("%10d %s\n", [i(snd(H)), s(fst(H))], !IO),
    dump(T, !IO).
