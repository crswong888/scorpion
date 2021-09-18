# WARNING: This script is problematic in that it continues to run in the background. I'm honestly
#          confident that there is no way around this in Python.
#
# Then again, it inadvertently creates a simple alias for deactivating the venv, i.e., 'exit'. This
# isn't the best, but it's a lot easier than calling the path of the activate script.

import os
import psutil
import subprocess

def activate_venv(args=None):
    """
    Strips the name of the current directory and uses it to activate a corresponding virtual
    environment stored in %USERPROFILE%\.venv\<directory name>-env in the current shell.
    """
    script = os.path.join(os.path.expanduser('~'),
                          '.venv',
                          '{}-env'.format(os.path.basename(os.getcwd())),
                          'Scripts',
                          'activate')

    if args is None:
        args = list()
    else:
        if not isinstance(args, list) or \
        (isinstance(args, list) and not all([isinstance(a, str) for a in args])):
           raise Exception("Error: 'args' must be a list of all strings.")

    # Determine the type of shell to know which activation script needs to be called
    shell = psutil.Process(os.getppid()).name()
    if shell == 'cmd.exe':
        args = ''.join([' && {}'.format(a) for a in args]) + '" || exit'
        subprocess.call(shell + ' /k "' + script + '.bat' + args)
    elif shell == 'powershell.exe':
        args = ''.join(['; if ($?) {{ {} }}'.format(a) for a in args]) + '; if (-not $?) { exit }'
        subprocess.call(' '.join([shell, '-NoExit -ExecutionPolicy RemoteSigned',
                                  script + '.ps1']) + args)
    else:
        raise NotImplementedError # I haven't tested this in any other shells

if __name__ == '__main__':
    activate_venv()
