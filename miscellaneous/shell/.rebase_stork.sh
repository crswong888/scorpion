#!/bin/bash

# list files which are severly modified and should be ignored when rebasing
ignore="README.md"
# could also to a total overwrite parameter?

# ensure app name argument is provided
if [[ $# == 0 || $# > 1 ]]; then
  echo "Error: Please specify the (case-sensitive) name of the MOOSE application."
  exit 1
fi

# parse app name arg and ensure a directory given by '/tmp/appname' doesn't already exist
appname=$1
appdir=$PWD
storkdir="/tmp/${appname}"
if [ -d $storkdir ]; then
  echo "Error: The directory '$storkdir' already exists. Please remove it."
  exit 1
fi

# create a clean directory for storing temporary files
tmp="/tmp/${appname}App_tmp"
if [ -d $tmp ]; then
  rm -rf $tmp
fi
mkdir $tmp

# attempt to find local MOOSE repository - if 'MOOSE_DIR' not set, check parent directory
if [ -z $MOOSE_DIR ] || [ ! -d $MOOSE_DIR ]; then
  if [ -d ../moose ]; then
    moosedir=../moose
  else
    echo -n "Error: Could not find the local MOOSE repository. "
    echo "Please set the 'MOOSE_DIR' environment variable to the correct path."
    exit 1
  fi
else
  moosedir=$MOOSE_DIR
fi

# --------------------------------------------------------------------------------------------------

# Function for copying lines which don't match a `diff` at $sha from file in $srcdir to $dstdir
function copydiff {
  # '/tmp/dstfile' will temporarily store file updates before merging - be sure one isn't lingering
  if [ -f "/tmp/dstfile" ]; then
    rm /tmp/dstfile
  fi

  # define convenience variables (these are the required positional arguments for this func)
  diff=$1 # diff argument must be the entire string - pass it in "$1" format
  gitdiff=$2 # same as diff - pass it in "$2" format
  srcfile=$3
  dstfile=$4

  # copy only those lines which don't match the retro diff
  ifs=$IFS # store default internal field separator so we can switch back and forth
  i=$((1)) # initialize file line indexing
  skipped=$((0)) # initialize value to adjust $srcfile indices in $diff to reflect those in $gitdiff
  while [ $i -le $(wc -l < $srcfile) ]
  do
    difftype="None"
    for d in $diff
    do
      # read lower and upper diff line indices (x,x[a|c|d]x,x) from each file into an array
      IFS="acd" # split string by a, c, or d
      read -r -a lines <<< $d
      IFS="," # split strings by commas
      read -r -a srclines <<< ${lines[0]}
      read -r -a dstlines <<< ${lines[1]}
      IFS=$ifs # restore default IFS

      # store lower and upper line diff indices for $srcfile
      srclower=$((${srclines[0]} + $skipped))
      srcupper=$((${srclines[1]} + $skipped))
      if [ $srcupper -eq 0 ]; then
        srcupper=$srclower
      fi

      # lower and upper diff indices for $dstfile
      dstlower=${dstlines[0]}
      dstupper=${dstlines[1]}
      if [ -z $dstupper ]; then
        dstupper=$dstlower
      fi

      # determine if current line matches a diff index - get the type of diff if it is
      if [ $i -ge $srclower ] && [ $i -le $srcupper ]; then
        difftype=$(echo $d | sed 's/[^acd]*//g') # pipe char to sed - (a)dd, (c)hange, (d)elete
        break
      fi
    done

    # copy lines from $srcfile to '/tmp/dstfile' based on the type of `diff` determined
    touch /tmp/dstfile
    if [ $difftype = "None" ]; then
      # if there is no diff at $sha, then any line in local version of $srcfile is merged
      sed -n "$i"p $srcfile >> /tmp/dstfile

      # obtain diff data between local version of $srcfile and the one at the specified head
      gitdifftype="None"
      for d in $gitdiff
      do
        IFS="acd"
        read -r -a lines <<< $d
        IFS=","
        read -r -a newlines <<< ${lines[0]}
        read -r -a oldlines <<< ${lines[1]}
        IFS=$ifs

        newlower=${newlines[0]}
        newupper=${newlines[1]}
        if [ -z $newupper ]; then
          newupper=$newlower
        fi

        oldlower=${oldlines[0]}
        oldupper=${oldlines[1]}
        if [ -z $oldupper ]; then
          oldupper=$oldlower
        fi

        if [ $i -ge $newlower ] && [ $i -le $newupper ]; then
          gitdifftype=$(echo $d | sed 's/[^acd]*//g')
          break
        fi
      done

      # If a line was created or deleted in $srcfile - diff indices at $sha need to be adjusted
      if [ $gitdifftype = "d" ]; then
        skipped=$(($skipped + 1))
      elif [ $gitdifftype = "a" ]; then
        skipped=$(($skipped - ($oldupper - $oldlower + 1)))
      fi
    elif [ $difftype = "a" ]; then
      sed -n "$i"p $srcfile >> /tmp/dstfile
      for range in $(seq $dstlower $dstupper)
      do
        sed -n "$(($(wc -l < /tmp/dstfile) + 1))"p $dstfile >> /tmp/dstfile
      done
    elif [ $difftype = "c" ] && [ $i -eq $srcupper ]; then
      for range in $(seq $dstlower $dstupper)
      do
        sed -n "$(($(wc -l < /tmp/dstfile) + 1))"p $dstfile >> /tmp/dstfile
      done
    fi

    # update current line index
    i=$(($i + 1))
  done

  # overwrite $dstfile with the temporary merger file if any actual changes were made
  if [ -n "$(diff /tmp/dstfile $dstfile)" ]; then
    mv /tmp/dstfile $dstfile
    echo "Merged changes from '$srcfile' into '$dstfile'"
    return 0 # indicate that a file has actually changed
  fi

  return 1 # indicate that no changes were made
}

# --------------------------------------------------------------------------------------------------

# generate a brand new MOOSE app from stork - do this inside $tmp since we know it's not a git repo
echo -n "Initializing $appname stork application... "
cd /tmp && $moosedir/scripts/stork.sh $appname &> /dev/null
echo "Done."

# move files in $ignore to temporary location (so that major app modifications are preserved)
for file in $ignore
do
  mv $storkdir/$file $tmp
done

# DEVEL
sha="HEAD"

cd $storkdir

# create a temporary orphan branch and clear the directory - preserve the .git, of course
if [ -n "$(git show-ref refs/heads/temp)" ]; then
  git branch -D temp
fi
git checkout --orphan temp
git add --all # gets rid of deleted tracked files

# shopt -s extglob
# rm -rfv !(.git|.|..) &> /dev/null

git log
git status

for srcfile in $(git ls-files $srcdir)
do
  echo $srcfile
done


####################################################################################################
echo
ls -a $storkdir
rm -rf $storkdir

echo
ls -a $tmp
rm -rf $tmp
