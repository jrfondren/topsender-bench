T=topsender_
BINS=$Tc $Tpcre_c
#BINS=$Tcr
BINS+=$Tnim $Taltsort_nim $Tnpeg_nim $Tregex_nim $Tnpeg_getline_nim $Tgetline_nim
BINS+=$Tdmd $Tpcre_dmd $Tpcre_getline_dmd
BINS+=$Tldc $Tpcre_ldc $Tpcre_getline_ldc
BINS+=$Tm

all:: $(BINS)

bench:: all
	REF=$$(getr 3 ./topsender_pcre_c 2>&1 | perl -lne 'print $$1 if /^Time.*\((\S+) ms.per/'); for targ in $(BINS); do >&2 /bin/echo -n "| $$targ "; getr -b $$REF 3 ./$$targ >/dev/null; done

clean::
	rm -fv *.o
	rm -fv $(BINS)

%_m: %.m pcre_d_shim.o
	mmc -O6 --make $(patsubst %.m,%,$<) --link-object pcre_d_shim.o -lpcre
	mv $(patsubst %.m,%,$<) $@

%_c: %.c
	gcc -O3 -Wall -o $@ $< -lpcre
%_nim: %.nim
	nim c -d:danger -o:$@ $<
%_dmd: %.d pcre_d_shim.o
	dmd -O $(DFLAGS) -of=$@ $< pcre_d_shim.o -L-lpcre
%_ldc: %.d pcre_d_shim.o
	ldc2 -O $(DFLAGS) -of=$@ $< pcre_d_shim.o -L-lpcre
pcre_d_shim.o: pcre_d_shim.c
	gcc -O3 -Wall -c pcre_d_shim.c
#%_cr: %.cr
#	crystal build --release -o $@ $<
