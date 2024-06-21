#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MAX_LINE_LENGTH 100
#define MAX_WORDS 1000

char adjectives[MAX_WORDS][MAX_LINE_LENGTH];
char creatures [MAX_WORDS][MAX_LINE_LENGTH];
int adjectives_count = 0;
int creatures_count = 0;

void get_lines(const char *file_path, char words[MAX_WORDS][MAX_LINE_LENGTH], int *count) {
    FILE *file = fopen(file_path, "r");
    if (file == NULL) {
        printf("File '%s' not found.\n", file_path);
        return;
    }
    while (fgets(words[*count], MAX_LINE_LENGTH, file) != NULL) {
        words[*count][strcspn(words[*count], "\n")] = '\0';
        (*count)++;
    }
    fclose(file);
}
char* generate_name() {
    static char name[MAX_LINE_LENGTH];
    int ad_index = rand() % adjectives_count;
    int cr_index = rand() % creatures_count;
    int sequence = rand() % 90001 + 10000;

    snprintf(name, sizeof(name), "%s_%s-%05d", adjectives[ad_index], creatures[cr_index], sequence);
    return name;
}

int get_number_of_names() {
    int num;
    while (1) {
        printf("Enter the amount of names to generate: ");
        if (scanf("%d", &num) != 1 || num < 1) {
            printf("Invalid input. Please enter a number greater than zero \n");
            while (getchar() != '\n');
        } else {
            return num;
        }
    }
}

int main() {
    srand(time(NULL));

    get_lines("adjectives", adjectives, &adjectives_count);
    get_lines("creatures", creatures, &creatures_count);
    
    if (adjectives_count == 0 || creatures_count == 0) {
        printf("Both 'adjectives' and 'creatures' files must be non-empty.\n");
        return 1;
    }

    int num_names = get_number_of_names();
    char file_name[] = "fnamefile";
    FILE *file = fopen(file_name, "a");
    if (file == NULL) {
        printf("Could not open file '%s' for writing.\n", file_name);
        return 1;
    }
    for(int i = 0; i < num_names; i++) {
        char *name = generate_name();
        fprintf(file, "%s\n", name);
    }
    
    fclose(file);
    printf("Generated names have been saved to %s\n", file_name);

    return 0;
}

