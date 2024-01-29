#!/usr/bin/env python3

import os
import sys
import base64
from pykeepass import PyKeePass

if 'KPPWD' in os.environ:
  pass
else:
    sys.exit(1)

kp_dbx = '/home/builder/KPDB.kbdx'
kp_key = '/home/builder/KPDB.key'
kp_psw = os.environ['KPPWD']

# Checking if KeePass database and key file exist
if os.path.isfile(kp_dbx) and os.path.isfile(kp_key):
  pass
else:
  print("\nKeePass database or keyfile not found are they defined correctly in .makerc-vars file?")
  sys.exit(1)

try:
  kp = PyKeePass(kp_dbx, kp_psw, kp_key)
except:
  base64_message = 'ICAgICAgICBfXyAgXwogICAgLi0uJyAgYDsgYC0uXyAgX18gIF8KICAgKF8sICAgICAgICAgLi06JyAgYDsgYC0uXwogLCdvIiggICAgICAgIChfLCAgICAgICAgICAgKQooX18sLScgICAgICAsJ28iKCAgICAgICAgICAgICk+CiAgICggICAgICAgKF9fLC0nICAgICAgICAgICAgKQogICAgYC0nLl8uLS0uXyggICAgICAgICAgICAgKQogICAgICAgfHx8ICB8fHxgLScuXy4tLS5fLi0nCiAgICAgICAgICAgICAgICAgIHx8fCAgfHx8ICA='
  base64_bytes = base64_message.encode('ascii')
  message_bytes = base64.b64decode(base64_bytes)
  message = message_bytes.decode('ascii')
  print("\n------------------------------------------------------------------------------")
  print("You're almost there but your KeePass password seems to be incorrect, try again?")
  print("-------------------------------------------------------------------------------")
  print(message)
  sys.exit(1)

print("\n-------------------------------------------------------------------")
print("The KeePass database is now unlocked and will stay open for 8 hours.")
print("After that you will need to unlock it again with: ctp-unlock-secrets")
print("--------------------------------------------------------------------")
