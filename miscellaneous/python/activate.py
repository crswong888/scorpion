# WARNING: This script is problematic in that it continues to run in the background. I'm honestly
#          confident that there is no way around this in Python.
#
# Then again, it inadvertently creates a simple alias for deactivating the venv, i.e., 'exit'. This
# isn't the best, but it's alot easier than calling the path of the activate script.

import os
import psutil
import subprocess

def activate(executable, extension, abort):
    """
    Strips the name of the current directory and uses it to activate a corresponding virtual
    environment stored in %USERPROFILE%\.venv\<directory name>-env
    """
    script = os.path.join(os.path.expanduser('~'),
                          '.venv',
                          '{}-env'.format(os.path.basename(os.getcwd())),
                          'Scripts',
                          'activate' + extension)
    subprocess.call(' '.join([executable, script, abort]))

# Determine type of shell to know which activation script needs to be called
shell = psutil.Process(os.getppid()).name()
if shell == 'cmd.exe':
    activate(shell + ' /k', '.bat', '|| exit')
elif shell == 'powershell.exe':
    # Ensure that running signed scripts is enabled in the current current PowerShell session
    ep = subprocess.check_output([shell, 'Get-ExecutionPolicy']).decode('utf-8').strip()
    subprocess.call([shell, 'Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -force'])

    # Run script and reset execution policy
    activate(shell + ' -NoExit', '.ps1', '; if (-not $?) { exit }')
    subprocess.call([shell, 'Set-ExecutionPolicy -Scope CurrentUser', ep, '-force'])
else:
    raise NotImplementedError # I haven't tried this any other shells
