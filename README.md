# q
A program for queueing various bash script tasks.

## Usage
```
Usage q [COMMAND]...
Queue bash commands for execution.

Commands
  add [COMMAND]       Add bash command to queue.
  clear               Clear all output that is currently in the queue.
  help, -h, --help    Show this help message.
  reset ?[number]     Reset the specified number to [WAITING] or entire queue i
                      no number specified.
  run                 Run the queue until completion.
  status              Show status of queue.

Examples:\n
  q add echo test        Add command 'echo test' to queue.
  q run                  Run all queued commands in order.
  q clear                Clear entire queue.
```
