#!/usr/bin/bash
session="capital_bike"
virtual_env="conda activate ${session}"

declare -a an_array=( 
    "prefect server start"
    "sleep 3 && cd prefect && python blocks/all_blocks.py" 
    "sleep 30 && cd prefect && source deployments/docker_deploy.sh"
    "sleep 300 && source setup/run_piperider.sh data_modelling init"
)
array_length=${#an_array[@]}

tmux has-session -t $session 2>/dev/null

if [ $? != 0 ]
then
    tmux new-session -d -s $session

    for ((i=0; i<${array_length}; i++));
    do
        window=$i

        if (($window != 0))
        then
            tmux new-window -t $session:$window
        fi
        
        script_to_run=${an_array[$i]}
        tmux send-keys -t $session:$window "$virtual_env; $script_to_run" C-m
        sleep 5
    done
fi