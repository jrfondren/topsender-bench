void getline_init (char *filename);
int getline_get (char **line, size_t *len);
void getline_free (char **line);
int email_init (void);
void email_free (void);
char *email_sender (char *line, size_t len);
