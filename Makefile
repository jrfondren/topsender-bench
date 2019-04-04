BINS=$(patsubst %.d,%,$(wildcard *.d))

pcre_d_shim.o: pcre_d_shim.c
	gcc -O3 -Wall -c pcre_d_shim.c

clean::
	rm -fv *.o
	rm -fv $(BINS)

ocaml::
	ocamlfind ocamlopt -linkpkg -package re -O3 -o topsender topsender.ml

d:: topsender_pcre topsender_pcre_getline
	dmd -O topsender.d

topsender_pcre: topsender_pcre.d pcre_d_shim.o
	dmd -O $@.d pcre_d_shim.o -L-lpcre

topsender_pcre_getline: topsender_pcre_getline.d pcre_d_shim.o
	dmd -O $@.d pcre_d_shim.o -L-lpcre
