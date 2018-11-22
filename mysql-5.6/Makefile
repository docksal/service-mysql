-include env_make

SHELL = /bin/bash
VERSION ?= mysql-5.6

REPO = docksal/db
NAME = docksal-db-${VERSION}
MYSQL_ROOT_PASSWORD = root
MYSQL_USER = user
MYSQL_PASSWORD = user
MYSQL_DATABASE = default
ENV = -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} -e MYSQL_USER=${MYSQL_USER} -e MYSQL_PASSWORD=${MYSQL_PASSWORD} -e MYSQL_DATABASE=${MYSQL_DATABASE}

.EXPORT_ALL_VARIABLES:

.PHONY: build exec test push shell run start stop logs debug clean release

build:
	fin docker build -t ${REPO}:${VERSION} .

test:
	IMAGE=${REPO}:${VERSION} bats ../tests/test.bats

push:
	fin docker push ${REPO}:${VERSION}

exec:
	@fin docker exec ${NAME} ${CMD}

exec-it:
	@fin docker exec -it ${NAME} ${CMD}

shell:
	@make exec-it -e CMD=sh

run:
	fin docker run --rm --name ${NAME} -it ${PORTS} ${VOLUMES} ${ENV} ${REPO}:${VERSION}

start: clean
	fin docker run -d --name ${NAME} ${PORTS} ${VOLUMES} ${ENV} ${REPO}:${VERSION}

mysql-query:
	# Usage: make mysql-query QUERY='SHOW DATABASES;'
	fin docker exec ${NAME} bash -c "mysql --host=localhost --user=root --password=${MYSQL_ROOT_PASSWORD} -e '${QUERY}'"

stop:
	fin docker stop ${NAME}

logs:
	fin docker logs ${NAME}

logs-follow:
	fin docker logs -f ${NAME}

debug: build start logs-follow

release:
	@../scripts/release.sh

clean:
	fin docker rm -vf ${NAME} || true

default: build
