#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "uthash.h"
#include <pcre.h>

struct sender {
	char email[128];
	int count;
	UT_hash_handle hh;
};

int count_sort(struct sender *a, struct sender *b) {
	if (a->count < b->count) return 1;
	if (a->count > b->count) return -1;
	return 0;
}

void topsenders(char *filename) {
	FILE *file;
	char *line = NULL;
	size_t len = 0;
	ssize_t read;
	pcre *emails;
	pcre_extra *study;
	int matches[9];
	int regresult;
	struct sender *senders = NULL;
	struct sender *asender = NULL;
	struct sender *tmp = NULL;
	const char *error;
	int erroffset;
	char *email;
	int upto = 5;

	emails = pcre_compile("^(?:[^ ]+ ){3,4}<= ([^@]+@([^ ]+))", 0, &error, &erroffset, 0);
	if (emails == NULL) {
		fprintf(stderr, "failed to compile email regex at %d : %s\n", erroffset, error);
		exit(1);
	}
	study = pcre_study(emails, PCRE_STUDY_JIT_COMPILE, &error);
	if (study == NULL) {
		fprintf(stderr, "failed to study email regex");
		exit(1);
	}
	if (NULL == (file = fopen(filename, "r"))) {
		fprintf(stderr, "failed to open %s for reading : %s\n", filename, strerror(errno));
		exit(1);
	}
	while (-1 != (read = getline(&line, &len, file))) {
		regresult = pcre_exec(emails, study, line, len, 0, 0, matches, 9);
		if (regresult < -1) {
			fprintf(stderr, "failed to pcre_exec\n");
			exit(1);
		}
		if (regresult > 0) {
			line[matches[3]] = '\0';
			email = &line[matches[2]];
			HASH_FIND_STR(senders, email, asender);
			if (asender == NULL) {
				asender = malloc(sizeof(struct sender));
				strncpy(asender->email, &line[matches[2]], sizeof asender->email);
				asender->count = 0;
				HASH_ADD_STR(senders, email, asender);
			} else {
				asender->count++;
			}
		}
	}
	HASH_SORT(senders, count_sort);
	HASH_ITER(hh, senders, asender, tmp) {
		if (--upto < 0) return;
		printf("%10d %s\n", asender->count, asender->email);
	}
	if (line) free(line);
	pcre_free(emails);
	pcre_free(study);
}

int main (int argc, char **argv) {
	switch (argc) {
	case 1:
		topsenders("exim_mainlog");
		break;
	case 2:
		topsenders(argv[1]);
		break;
	default:
		fprintf(stderr, "usage: %s [path/to/logfile]\n", argv[0]);
		return 1;
	}
	return 0;
}
