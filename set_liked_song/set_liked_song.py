#!/usr/bin/env python3

import spotipy
import os
from spotipy.cache_handler import CacheFileHandler
from spotipy.oauth2 import SpotifyOAuth
import sys

scope = "user-library-modify"

if (len(sys.argv) >= 2 and sys.argv[1] == "--login"):
    input("log to the destination spotify account, then press enter key")

sp = spotipy.Spotify(auth_manager=SpotifyOAuth(
    scope=scope,
    cache_handler=CacheFileHandler(cache_path=(os.getenv('EXEC_PATH') or ".")
                                   + "/.cache")
    ))

if (len(sys.argv) >= 2 and sys.argv[1] == "--login"):
    print(sp.me()['display_name'], "logged in as the destination account")
    exit()


# get songs ids in stdin
ids = []
for line in sys.stdin:
    ids.append(line.strip())

# set songs for destination account
i = 0
while i < len(ids):
    tmp = ids[i:i+50]
    i = i + len(tmp)
    sp.current_user_saved_tracks_add(tmp)
    print("\rsetted songs : ", i, end="")
print()
