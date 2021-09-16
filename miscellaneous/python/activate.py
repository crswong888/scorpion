# Stripts the name of the current directory and uses it to activate a corresponding virtual
# environment stored in %userprofile%\.venv\<directory name>-env

import os
import subprocess

envdir = os.path.join(os.path.expanduser('~'), '.venv')
envname = '{}-env'.format(os.path.basename(os.getcwd()))

try:
    subprocess.call(os.path.join(envdir, envname, 'Scripts', 'activate.bat'))
    print("Activated virtual environment:", envname)
except FileNotFoundError:
    msg = "No environment named '{}' located in {}.".format(envname, envdir)
    raise FileNotFoundError(msg) from None
