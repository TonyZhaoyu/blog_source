---
title: CLI interactions
date: 2018-09-12 14:09:59
categories:
- [Coding, Practices, CLI interactions]
---

This article provides a very simple implementation of CLI interaction. The code basically shows how to leverage 'string' functions of libc. Notice the implementation of handler functions (e.g., cmd_start_scan) are omitted. The following code could be running in a thread.

```c
/*****************************************************************************
@brief: Inspired by https://github.com/brenns10/lsh.git
*****************************************************************************/

#include <sys/wait.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define LSH_TOK_BUFSIZE (64)
#define LSH_RL_BUFSIZE  (1024)
#define LSH_TOK_DELIM   " \t\r\n\a"

typedef uint8_t (* cli_cmd_handler)(uint8_t len, char *param[]);
typedef struct _Cli_Cmd {
  char            * cmd;
  char            * help;
  char            * padding;
  cli_cmd_handler handler;
  uint8_t         hidden;
} Cli_Cmd;

/*
 `cmd_start` and `cmd_exit` could be implemented in other c files.
 */
static Cli_Cmd cmdsMap[] = {
  {
    "start",   "@brief: start the program.", "\t",
     cmd_start , 0
  },
  {
    "exit",      "@brief: exit the program.", "\t",
     cmd_exit,   0
  },
  { NULL, NULL, NULL, 0}
};

/**
 * @brief: After split, the arguments contains the command name.
 *         The method is to get rid of the command name and return
 *         a list of string pointers to the arguments.
 *         Please free the return list.
 */
static char **get_true_arguments(uint8_t argc, char **argv)
{
  uint8_t idx;
  char **args = malloc(argc * sizeof(char*));

  if(!args) {
    fprintf(stderr, "cli: allocation error\n");
  }

  for(idx = 0; idx < argc; idx++) {
    args[idx] = argv[idx + 1];
  }

  return args;
}

static uint8_t cli_help()
{
  uint8_t idx;

  for(idx = 0;; idx++) {
    if(cmdsMap[idx].cmd  == NULL ||
       cmdsMap[idx].help == NULL) {
      return 0;
    } else if (!cmdsMap[idx].hidden) {
      printf("%s %s- %s\r\n", cmdsMap[idx].cmd,
                              cmdsMap[idx].padding,
                              cmdsMap[idx].help);
    }
  }

  return 0;
}

static void cli_execute(uint8_t argc, char **argv)
{
  char **args;
  int  idx;

  if(argv[0] == NULL) {
    return;
  }

  if(strcmp(argv[0], "?") == 0) {
    cli_help();
    return;
  }

  for(idx = 0;; idx++) {
    if(cmdsMap[idx].cmd &&
       cmdsMap[idx].handler &&
       strcmp(argv[0], cmdsMap[idx].cmd) == 0) {
      args = get_true_arguments(argc, argv);
      cmdsMap[idx].handler(argc, args);
      free(args);
      return;
    } else if(!cmdsMap[idx].cmd ||
              !cmdsMap[idx].handler) {
      break;
    }
  }

  printf("[console]: %s unknown command\r\n", argv[0]);
}

/**
 * @brief: Read a line of input from stdin.
 * @param[Out]: pointer to a string.
 * @return: The line from stdin.
 */
static char *cli_read_line(void)
{
  int  bufsize = LSH_RL_BUFSIZE;
  int  position = 0;
  int  c;
  char *buffer;

  buffer = (char *)malloc(sizeof(char) * bufsize);

  if(!buffer) {
    fprintf(stderr, "[console]: allocation error\n");
  }

  while (1) {
    // Read a character
    c = getchar();

    if(c == EOF) {
      exit(EXIT_SUCCESS);
    } else if(c == '\n') {
      buffer[position] = '\0';
      return buffer;
    } else {
      buffer[position] = c;
    }
    position++;

    // If we have exceeded the buffer, reallocate.
    if(position >= bufsize) {
      bufsize += LSH_RL_BUFSIZE;
      buffer = realloc(buffer, bufsize);
      if (!buffer) {
        fprintf(stderr, "[console]: allocation error\n");
      }
    }
  }
}

/**
 * @brief: Split a line into tokens (very naively).
 * @param[In]: line - pointer to a string.
 * @param[Out]: argc - pointer to argument count.
 * @param[Out]: argv - NULL terminated array of tokens.
 */
static char **cli_split_line(char *line, uint8_t *argc)
{
  uint8_t position = 0;
  int bufsize = LSH_TOK_BUFSIZE;
  char **tokens = malloc(bufsize * sizeof(char*));
  char *token, **tokens_backup;

  if(!tokens) {
    fprintf(stderr, "[console]: allocation error\n");
  }

  token = strtok(line, LSH_TOK_DELIM);
  while(token != NULL) {
    tokens[position] = token;
    position++;

    if(position >= bufsize) {
      bufsize += LSH_TOK_BUFSIZE;
      tokens_backup = tokens;
      tokens = realloc(tokens, bufsize * sizeof(char*));
      if(!tokens) {
		    free(tokens_backup);
        fprintf(stderr, "[console]: allocation error\n");
      }
    }

    token = strtok(NULL, LSH_TOK_DELIM);
  }
  tokens[position] = NULL;
  *argc = (position - 1 >= 0) ? (position - 1) : 0;
  return tokens;
}

void console_initialize(void)
{
  return;
}

void console_task_func(void *param)
{
  uint8_t argc;
  char    *line;
  char    **argv;

  for(;;) {
    printf("$ ");
    line = cli_read_line();
    argv = cli_split_line(line, &argc);
    cli_execute(argc, argv);
    free(line);
    free(argv);

    usleep(50000); // 50ms
  }
}

```
