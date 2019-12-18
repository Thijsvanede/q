#!/bin/bash

# Define usage string
usage="Usage q [COMMAND]...
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
  q clear                Clear entire queue."

# Get path to script
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# In case of no parameters show usage
if [ $# == 0 ]; then
    echo "$usage"
    exit 0
fi

case "$1" in

    # Add command to queue
    "add")
        # Get current directory
        dir=$(pwd)
        # Get #lines in file
        count=0
        if test -f $SCRIPTPATH.q.status; then
            count=$(cat $SCRIPTPATH.q.status | wc -l)
        fi
        # Add new command to queue
        echo -e "$count\t[WAITING]\t${@:2}\t$dir" >> $SCRIPTPATH.q.status
        ;;

    # Clear queue TODO
    "clear")
        read  -n 1 -p "WARNING: clearing queue is only safe if q is not running. Continue? [y/N] " input
        echo ""
        if [[ $input == "y" ]]; then
            # Remove queued files
            rm $SCRIPTPATH.q.status
        fi
        ;;

    # Run queue TODO
    "run")
        # Only run if there are items in the queue
        if test -f $SCRIPTPATH.q.status; then
            # Only perform local changes
            (
                # Read each status per line
                set -f; IFS=$'\n'
                qstatus=$(cat $SCRIPTPATH.q.status)

                # Loop over all commands
                for line in $qstatus; do

                    # Split line
                    (
                        IFS=$'\t'
                        line=($line)
                        count=${line[0]}
                        status=${line[1]}
                        cmd=${line[2]}
                        dir=${line[-1]}

                    # Check for waiting processes
                    if [[ $status == "[WAITING]" ]]; then
                        # Set status to RUNNING
                        sed -i "s/$count\t\[WAITING\]\t/$count\t\[RUNNING]\t/" $SCRIPTPATH.q.status

                        # Show progress
                        echo "[RUNNING] '$cmd'..."
                        # Execute command
                        (cd $dir; eval $cmd)

                        # Set status to FINISHED
                        if [[ $? -eq 0 ]]; then
                            sed -i "s/$count\t\[RUNNING\]\t/$count\t\[FINISHED]\t/" $SCRIPTPATH.q.status
                        else
                            sed -i "s/$count\t\[RUNNING\]\t/$count\t\[ERROR]\t/" $SCRIPTPATH.q.status
                        fi
                    fi

                    )
                done

                # Cleanup
                set +f; unset IFS
            )
        fi
        echo "Finished running queue"
        ;;

    # Restart queue
    "reset")
        # Reset all items to WAITING
        if test -f $SCRIPTPATH.q.status; then
            sed -i -r "s/$2\t\[.+\]/$2\t[WAITING]/" $SCRIPTPATH.q.status
        fi
        ;;

    # Show status of queue
    "status")
        echo -e "Queue:\tStatus\t\tCommand\t\tDirectory"
        if test -f $SCRIPTPATH.q.status; then
            # Show status
            cat $SCRIPTPATH.q.status
        else
            echo "[EMPTY]"
        fi
        ;;

    # Show help page
    *)
        echo "$usage"
        ;;
esac
