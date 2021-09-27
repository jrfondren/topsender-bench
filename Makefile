T=topsender_
BINS=$Tc $Tpcre_c
BINS+=$Tcr $Tnim $Tregex_nim $Tgo $Trust
BINS+=$Td #$Tpcre_d $Tpcre_getline_d
BINS+=$Tgdc #$Tpcre_gdc $Tpcre_getline_gdc
BINS+=$Tldc #$Tpcre_ldc $Tpcre_getline_ldc
KT=TopsenderKt.class
SCRIPTS=topsender.pl topsender.py topsender_pypy.py

all:: $(BINS) $(KT)

bench:: all
	REF=$$(getr 3 ./topsender_pcre_c 2>&1 | perl -lne 'print $$1 if /^Time.*\((\S+) ms.per/'); for targ in $(BINS) $(SCRIPTS) kt.sh; do >&2 /bin/echo -n "| $$targ "; getr -b $$REF 3 ./$$targ >/dev/null; done

exam:: all
	for targ in $(BINS); do echo $$targ; ./$$targ | perl -pe "s/^/$$targ: /"; done

clean::
	rm -fv *.o
	rm -fv $(BINS)
	rm -fv go/topsender
	rm -rf rust/target
	rm -fv *.class
	rm -rf META-INF

%_c: %.c
	getr 1 gcc -O3 -Wall -o $@ $< -lpcre
%_nim: %.nim
	getr 1 nim c -d:release -o:$@ $<
%_d: %.d pcre_d_shim.o
	getr 1 dmd -O -release -of=$@ $< -L-lpcre -Lpcre_d_shim.o
%_gdc: %.d pcre_d_shim.o
	getr 1 gdc -O3 -flto -frelease -o $@ $< -lpcre pcre_d_shim.o
%_ldc: %.d pcre_d_shim.o
	getr 1 ldc -O3 -release -of=$@ $< -L-lpcre -Lpcre_d_shim.o
pcre_d_shim.o: pcre_d_shim.c
	getr 1 gcc -O3 -Wall -c pcre_d_shim.c
%_cr: %.cr
	getr 1 crystal build --release -o $@ $<
%_go: go/topsender.go
	( cd go; getr 1 go build topsender.go )
	mv go/topsender $@
%_rust: rust/src/main.rs
	( cd rust; getr 1 cargo build --release )
	mv rust/target/release/rust $@
TopsenderKt.class: topsender.kt
	getr 1 kotlinc topsender.kt
