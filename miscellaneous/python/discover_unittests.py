import os
import re
import unittest

RE = re.compile(r'\w* \((?P<case>.*)\)')
CASES = set()

def print_suite(suite):
    """https://stackoverflow.com/questions/24478727/how-to-list-available-tests-with-python"""

    if hasattr(suite, '__iter__'):
        for test in suite:
            print_suite(test)
    else:
        print(suite)
        CASES.add(RE.search(str(suite)).group('case'))

LOADER = unittest.defaultTestLoader.discover(os.getcwd())
print()
print_suite(LOADER)
print('-------------------------------------------------------------------------------------------')
print("Discovered {} test methods from the following test cases:\n".format(LOADER.countTestCases()))
for case in sorted(CASES):
    print(case)
print()
