#!/usr/bin/env python3

import spotipy
import os
import sys
from spotipy.cache_handler import CacheFileHandler
from spotipy.oauth2 import SpotifyOAuth

scope = "user-library-read"

if (len(sys.argv) >= 2 and sys.argv[1] == "--login"):
    input("log to the source spotify account, then press enter key")

sp = spotipy.Spotify(auth_manager=SpotifyOAuth(
    scope=scope,
    cache_handler=CacheFileHandler(cache_path=(os.getenv('EXEC_PATH') or ".")
                                   + "/.cache")
    ))

if (len(sys.argv) >= 2 and sys.argv[1] == "--login"):
    print(sp.me()['display_name'], "logged in as the source account")
    exit()

# get songs ids from source account
res = []
tmp = sp.current_user_saved_tracks(50, 0)['items']
while (len(tmp)):
    for i in tmp:
        res.append(i['track']['id'])
    tmp = sp.current_user_saved_tracks(50, len(res))['items']
    os.write(2, bytes('\rgetted songs : ' + str(len(res)), 'utf-8'))
os.write(2, bytes("\n", 'utf-8'))

for i in res:
    print(i)
