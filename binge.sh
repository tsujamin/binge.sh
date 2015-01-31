#! /bin/bash
# -s directory: set default
# -d use default
# http://xkcd.com/1319/

if [ "$1" == "-h" ]; then
	echo "binge [-d] [-s directory]"
	exit
elif [ "$1" == "-s" ]; then
	echo $2 > ~/.current_binge
	cd $2
fi

if [ "$1" == "-d" ] && [ -e ~/.current_binge ]; then
	cd $(cat ~/.current_binge)
fi

if [ -e .current_episode ]; then
	found_episode=false
else
	echo -n "init? (y/n) "
	read op
	while true; do
		if [ $op = "y" ]; then
			found_episode=true
			break
		elif [ $op = "n" ]; then
			exit
		fi
	done
fi

if [ -e .last_timestamp ]; then
	echo "Last episode stopped at $(cat .last_timestamp)"
	rm .last_timestamp
fi

for ep_count in $(seq 1 $(ls | wc -l)); do
	ep=`ls | head -n $ep_count | tail -n 1`

	if ! $found_episode; then
		current_episode=`cat .current_episode`
		if [ "$current_episode" = "$ep" ]; then
			found_episode=true
		else
			continue
		fi
	fi
		
	echo $ep > .current_episode
	
	while true; do
		echo -n "watch \"$ep\"? (y/n/+) "
		
		read op
		
		if [ $op = "y" ]; then
			open "$ep"
			
			while true; do
				echo -n "finished? (y/n) "
				read op
				if [ $op = "y" ]; then
					continue 3
				elif [ $op = "n" ]; then
					echo -n "current time? "
					read ep_time
					echo $ep_time > .last_timestamp
					exit 0
				fi
			done
		else
			if [ $op = "+" ]; then
				continue 2
			elif [ $op = "n" ]; then
				exit 0
			fi
		fi
	done
done

echo "finished"
rm .current_episode
