#! /bin/sh
#
# $Id$
#
# A script for running the POCO testsuites.
#
# usage: runtests [component [test] ]
#
# If the environment variable EXCLUDE_TESTS is set, containing
# a space-separated list of project names (as found in the
# components file), these tests will be skipped.
#
# Cygwin specific setup.
# ----------------------
# On Cygwin, Unix IPC are provided by a separate process daemon 
# named cygserver, which should be started once before running any
# test from Foundation.
# 1/ Open a separate Cygwin terminal with Administrator privilege
# 2/ run the command: cygserver-configure
# 3/ Start the cygserver: nohup /usr/sbin/cygserver &
# 4/ close the separate terminal
# 5/ run the Foundation tests: build/script/runtests.sh Foundation
#

if [ "$POCO_BASE" = "" ] ; then
	POCO_BASE=`pwd`
fi

TESTRUNNER=./testrunner

if [ "$1" = "" ] ; then
   components=`cat $POCO_BASE/components`
else
   components=$1
fi

if [ "$2" = "" ] ; then
    TESTRUNNERARGS=-all
else
    TESTRUNNERARGS=$2
fi


if [ "$OSNAME" = "" ] ; then
	OSNAME=`uname`
        case $OSNAME in
        CYGWIN*)
                OSNAME=CYGWIN 
                TESTRUNNER=$TESTRUNNER.exe
                ;;
        MINGW*)
                OSNAME=MinGW ;;
        esac
fi
if [ "$OSARCH" = "" ] ; then
	OSARCH=`uname -m | tr ' /' _-`
fi
BINDIR="bin/$OSNAME/$OSARCH/"

runs=0
failures=0
failedTests=""
status=0

for comp in $components ;
do
	excluded=0
	for excl in $EXCLUDE_TESTS ;
	do
		if [ "$excl" = "$comp" ] ; then
			excluded=1
		fi
	done
	if [ $excluded -eq 0 ] ; then
		if [ -d "$POCO_BASE/$comp/testsuite/$BINDIR" ] ; then
			if [ -x "$POCO_BASE/$comp/testsuite/$BINDIR/$TESTRUNNER" ] ; then
				echo ""
				echo ""
				echo "****************************************" 
				echo "*** $comp"                                
				echo "****************************************" 
				echo ""

				runs=`expr $runs + 1`
				sh -c "cd $POCO_BASE/$comp/testsuite/$BINDIR && $TESTRUNNER $TESTRUNNERARGS"
				if [ $? -ne 0 ] ; then
					failures=`expr $failures + 1`
					failedTests="$failedTests $comp"
					status=1
				fi
			fi
		fi
	fi
done

echo ""
echo ""
echo "$runs runs, $failures failed."
echo ""
for test in $failedTests ;
do
	echo "Failed: $test"
done
echo ""

exit $status
