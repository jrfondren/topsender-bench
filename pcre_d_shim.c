#include <pcre.h>
#include <stdio.h>

static pcre *emails;
static pcre_extra *study;
static FILE *file;

void getline_init (char *filename) {
	file = fopen(filename, "r");
}
int getline_get (char **line, size_t *len) {
	return getline(line, len, file);
}
void getline_free (char **line) {
	free(*line);
	*line = NULL;
	fclose(file);
}

int email_init (void) {
        const char *error;
        int erroffset;

	emails = pcre_compile("^(?:\\S+ ){3,4}<= ([^@]+@(\\S+))", 0, &error, &erroffset, 0);
	if (emails == NULL) {
                fprintf(stderr, "failed to compile email regex at %d : %s\n", erroffset, error);
                exit(1);
        }
	study = pcre_study(emails, PCRE_STUDY_JIT_COMPILE, &error);
	if (study == NULL) {
                fprintf(stderr, "failed to study email regex");
                exit(1);
        }
	return 1;
}

void email_free (void) {
	pcre_free(emails);
	pcre_free(study);
}

char *email_sender (char *line, size_t len) {
        int matches[4];
        int regresult;

	regresult = pcre_exec(emails, study, line, len, 0, 0, matches, sizeof matches);
	if (regresult < -1) {
		fprintf(stderr, "failed to pcre_exec\n");
		exit(1);
	}
	if (regresult > 0) {
		line[matches[3]] = '\0';
		return &line[matches[2]];
	}
	return NULL;
}
