#!/usr/bin/env bash

if [[ "${TRAVIS_PULL_REQUEST}" == "false" ]]; then
	# develop => edge-${VERSION}
	[[ "${TRAVIS_BRANCH}" == "develop" ]] && TAG="edge-${VERSION}"
	# master => ${VERSION}
	[[ "${TRAVIS_BRANCH}" == "master" ]] && TAG="${VERSION}"
	# tags/v1.2.0 => 1.2-${VERSION}
	[[ "${TRAVIS_TAG}" != "" ]] && TAG="${TRAVIS_TAG:1:3}-${VERSION}"

	if [[ "$TAG" != "" ]]; then
		docker login -u "${DOCKER_USER}" -p "${DOCKER_PASS}"
		# Push edge, stable and release tags
		docker tag ${REPO}:${VERSION} ${REPO}:${TAG}
		docker push ${REPO}:${TAG}

		# Push "latest" tag
		if [[ "${TRAVIS_BRANCH}" == "master" ]] && [[ "${VERSION}" == "${LATEST_VERSION}" ]]; then
			docker tag ${REPO}:${VERSION} ${REPO}:latest
			docker push ${REPO}:latest
		fi
	fi;
fi;
