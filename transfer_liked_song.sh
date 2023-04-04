#!/usr/bin/env bash

envVarsToCheck=("SPOTIPY_REDIRECT_URI_PORT" "SPOTIPY_CLIENT_SECRET" "SPOTIPY_CLIENT_ID")
C_RED="\e[31m"
C_YELLOW="\e[33m"
C_RESET="\e[0m"

function exitError()
{
	echo -e "${C_RED}ERROR - $1${C_RESET}" >&2
	exit "$2"
}

function warn()
{
	echo -e "${C_YELLOW}WARNING - $1${C_RESET}" >&2
}

if [ "$1" == "clean" ]; then
	rm -f ./get_liked_song/.cache ./set_liked_song/.cache
	echo "Removed spotipy's .cache"
	exit
fi

if [ ! -f "./.env" ]; then
	exitError "./.env does not exist !" 3
fi

# shellcheck source=./.env.example
source ./.env

GET_SONG_EXEC_PATH="./get_liked_song"
SET_SONG_EXEC_PATH="./set_liked_song"

for varName in "${envVarsToCheck[@]}"; do
	if [ -z ${!varName+x} ]; then
		exitError "$varName must be defined and not empty in .env" 1
	fi
done

if [ "$SPOTIPY_REDIRECT_URI_PORT" -lt 1 ]; then
	exitError "Valid port range is [1:65335], ${SPOTIPY_REDIRECT_URI_PORT} is lower than 1" 2
elif [ "$SPOTIPY_REDIRECT_URI_PORT" -gt 65335 ]; then
	exitError "Valid port range is [1:65335], ${SPOTIPY_REDIRECT_URI_PORT} is greater than 65335" 2
elif [ "$SPOTIPY_REDIRECT_URI_PORT" -lt 1024 ] && [ "$DISABLE_WARNING" != "true" ]; then
	warn "Port in range [1:1024] may already be in use"
fi

export SPOTIPY_REDIRECT_URI="http://localhost:${SPOTIPY_REDIRECT_URI_PORT}" SPOTIPY_CLIENT_ID SPOTIPY_CLIENT_SECRET

"$0" "clean"

env EXEC_PATH="$GET_SONG_EXEC_PATH" "${GET_SONG_EXEC_PATH}/print_liked_song.py" --login
env EXEC_PATH="$SET_SONG_EXEC_PATH" "${SET_SONG_EXEC_PATH}/set_liked_song.py" --login
env EXEC_PATH="$GET_SONG_EXEC_PATH" "${GET_SONG_EXEC_PATH}/print_liked_song.py" | env EXEC_PATH="$SET_SONG_EXEC_PATH" "${SET_SONG_EXEC_PATH}/set_liked_song.py"
