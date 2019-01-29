#!/usr/bin/env bats

# Debugging
teardown() {
	echo
	echo "Output:"
	echo "================================================================"
	echo "${output}"
	echo "================================================================"
}

# Checks container health status (if available)
# @param $1 container id/name
_healthcheck ()
{
	local health_status
	health_status=$(docker inspect --format='{{json .State.Health.Status}}' "$1" 2>/dev/null)

	# Wait for 5s then exit with 0 if a container does not have a health status property
	# Necessary for backward compatibility with images that do not support health checks
	if [[ $? != 0 ]]; then
	echo "Waiting 10s for container to start..."
	sleep 10
	return 0
	fi

	# If it does, check the status
	echo $health_status | grep '"healthy"' >/dev/null 2>&1
}

# Waits for containers to become healthy
_healthcheck_wait ()
{
	# Wait for cli to become ready by watching its health status
	local container_name="${NAME}"
	local delay=5
	local timeout=30
	local elapsed=0

	until _healthcheck "$container_name"; do
		echo "Waiting for $container_name to become ready..."
		sleep "$delay";

		# Give the container 30s to become ready
		elapsed=$((elapsed + delay))
		if ((elapsed > timeout)); then
			echo "$container_name heathcheck failed"
			exit 1
		fi
	done

	return 0
}

# To work on a specific test:
# run `export SKIP=1` locally, then comment skip in the test you want to debug

@test "MySQL initialization" {
	[[ $SKIP == 1 ]] && skip

	### Setup ###
	make start -e VOLUMES="-v $(pwd)/tests:/var/www"
	_healthcheck_wait

}

@test "Default database present" {
	[[ $SKIP == 1 ]] && skip

	run make mysql-query QUERY='SHOW DATABASES;'
	[[ "$output" =~ "default" ]]
}

@test "Check variables" {
	[[ $SKIP == 1 ]] && skip

	# Grab variables from the container
	# -s used to supress echoing of the actual make command
	mysqlVars=$(make -s mysql-query QUERY='SHOW VARIABLES;')
	# Compare with the expected values
	# This will trigger a diff only when a variable from mysql-variables.txt is missing or modified in $mysqlVars
	run bash -c "echo '$mysqlVars' | diff --changed-group-format='%<' --unchanged-group-format='' mysql-${VERSION}/mysql-variables.txt -"
	[[ "$output" == "" ]]
}

@test "Configuration overrides" {
	[[ $SKIP == 1 ]] && skip

	# Check the custom settings file is in place
	run make exec CMD="cat /etc/mysql/conf.d/99-overrides.cnf"
	[[ "$output" =~ "slow_query_log = ON" ]]
	unset output

	# Grab variables from the container
	# -s used to suppress echoing of the actual make command
	mysqlVars=$(make -s mysql-query QUERY='SHOW VARIABLES;')
	# Compare with the expected values
	# This will trigger a diff only when a variable from mysql-variables.txt is missing or modified in $mysqlVars
	run bash -c "echo '$mysqlVars' | grep 'slow_query_log[[:blank:]]'"
	[[ "$output" =~ "ON" ]]
	unset output
}
