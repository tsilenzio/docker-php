#!/bin/bash

OPTS=`getopt -n "$0" -o : --long build,release -- "$@"`

if [[ $? != 0 ]]; then
        echo "Failed parsing options." >&2
        exit 1
fi

eval set -- "$OPTS"

build=false
release=false

while true; do
        case "$1" in
                --build ) build=true; shift ;;
                --release ) release=true; shift ;;
                -- ) shift; break ;;
                * ) break ;;
        esac
done


declare -A aliases
aliases=(
	[5.6]='5 latest'
	[7.0]='7'
)

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )

echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'
echo '# modified-by: Taylor Silenzio <me@tsilenz.io> (@tsilenzio)'

for version in "${versions[@]}"; do
	fullVersion="$(grep -m1 'ENV PHP_VERSION ' "$version/Dockerfile" | cut -d' ' -f3)"
	versionAliases=( $fullVersion $version ${aliases[$version]} )

	## CLI
	for va in "${versionAliases[@]}"; do
		if [ "$va" = 'latest' ]; then
			va='cli'
		else
			va="$va-cli"
		fi

		if [ "$build" = true ]; then
			docker build -t tsilenzio/php:$va $version/$variant
		fi

		if [ "$release" = true ]; then
			docker push tsilenzio/php:$va
		fi
	done

	## FPM
	for variant in fpm; do
		for va in "${versionAliases[@]}"; do
			if [ "$va" = 'latest' ]; then
				va="$variant"
			else
				va="$va-$variant"
			fi

			if [ "$build" = true ]; then
				docker build -t tsilenzio/php:$va $version/$variant
			fi

			if [ "$release" = true ]; then
				docker push tsilenzio/php:$va
			fi
		done
	done
done
