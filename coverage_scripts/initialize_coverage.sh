#!/bin/bash

# This script prepares for running commands from the coverage package

if [[ `pwd` != *"DOVE" ]]
then
    echo "The initialize_coverage.sh script MUST be run from the DOVE directory. Please try again."
    exit
fi
RAVEN_DIR=`python -c 'from src._utils import get_raven_loc; print(get_raven_loc())'`
# If RAVEN directory has been added to PYTHONPATH, this confuses get_raven_loc
if [[ "$RAVEN_DIR" == *"ravenframework" ]]  # get_raven_loc might return ravenframework, not raven
then
    RAVEN_DIR=`(cd $RAVEN_DIR/..; pwd)`  # Take parent directory, which is raven directory, instead
fi

source $RAVEN_DIR/scripts/establish_conda_env.sh --quiet --load

RAVEN_LIBS_PATH=`conda env list | awk -v rln="$RAVEN_LIBS_NAME" '$0 ~ rln {print $NF}'`
BUILD_DIR=${BUILD_DIR:=$RAVEN_LIBS_PATH/build}
INSTALL_DIR=${INSTALL_DIR:=$RAVEN_LIBS_PATH}
PYTHON_CMD=${PYTHON_CMD:=python}
mkdir -p $BUILD_DIR
mkdir -p $INSTALL_DIR
DOWNLOADER='curl -C - -L -O '

ORIGPYTHONPATH="$PYTHONPATH"

update_python_path ()
{
    if ls -d $INSTALL_DIR/lib/python*
    then
        NEWPYTHONPATH="`ls -d $INSTALL_DIR/lib/python*/site-packages/`"
        if [[ "$ORIGPYTHONPATH" != "" && $NEWPYTHONPATH != "" ]]
        then
            NEWPYTHONPATH="$NEWPYTHONPATH:"
        fi
        export PYTHONPATH="$NEWPYTHONPATH$ORIGPYTHONPATH"
    fi
}

update_python_path
export PATH=$INSTALL_DIR/bin:$PATH

if which coverage
then
    echo coverage already available, skipping building it.
else
    if curl http://www.energy.gov > /dev/null
    then
       echo Successfully got data from the internet
    else
       echo Could not connect to internet
    fi

    cd $BUILD_DIR
    #SHA256=56e448f051a201c5ebbaa86a5efd0ca90d327204d8b059ab25ad0f35fbfd79f1
    $DOWNLOADER https://files.pythonhosted.org/packages/ef/05/31553dc038667012853d0a248b57987d8d70b2d67ea885605f87bcb1baba/coverage-7.5.4.tar.gz
    tar -xvzf coverage-7.5.4.tar.gz
    cd coverage-7.5.4
    (unset CC CXX; $PYTHON_CMD setup.py install --prefix=$INSTALL_DIR)
fi

update_python_path
