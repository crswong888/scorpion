import os
import subprocess

import activate

# Create the environment if one by the same name doesn't already exist
home = os.path.expanduser('~')
path = os.path.join(home, '.venv', '{}-env'.format(os.path.basename(os.getcwd())))
if not os.path.exists(path):
    print('Creating a virtual environment at', path)
    subprocess.call('python -m venv ' + path)

# Activate the environment and immediately update pip
activate.activate_venv(['python -m pip install -U --index-url https://pypi.org/simple pip'])
