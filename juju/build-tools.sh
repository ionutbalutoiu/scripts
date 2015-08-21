#!/bin/bash

set -e

JUJU_SRC="$GOPATH/src/github.com/juju/juju"
BIN_DIR="$GOPATH/bin"
WIN_BIN_DIR="$BIN_DIR/windows_amd64"
JUJU_HOME="$HOME/.juju"
JUJU_TOOLS="$JUJU_HOME/tools"
JUJU_RELEASES="$JUJU_TOOLS/releases"
STREAMS_DIR="$JUJU_TOOLS/streams"
WWW_TOOLS="/var/www/html/tools"

if [ ! -d "$JUJU_SRC" ]
then
    echo "Failed to find $JUJU_SRC"
    exit 1
fi

HandleError() {
    DIRS=$(dirs)
    CODE=$?
    if [ $? -ne 0 ]
    then
        echo $1
        if [ "$DIRS" != '~' ]
        then
            popd
        fi
    fi
    exit $CODE
}

BuildJuju() {
    pushd $JUJU_SRC
    #godeps -f -u dependencies.tsv || HandleError "Failed to update dependencies"
    go install ./... || HandleError "Failed to build tools"
    GOOS=windows go install ./... || HandleError "Failed to build tools for windows"
    popd
}

CreateTgz() {
    JUJU_VERSION=$(juju version) || HandleError "Failed to get juju version"
    IFS='-' read -a V <<< $JUJU_VERSION
    IFS=""

    if [ ${#V[@]} -eq 3 ]
    then
        echo "WARNING: Using production branch"
        VERSION_STR="${V[0]}-%s-${V[2]}"
    elif [ ${#V[@]} -eq 4 ]
    then
        VERSION_STR="${V[0]}-${V[1]}-%s-${V[3]}"
    else
        echo ${#V[@]}
        echo "Invalid version"
        exit 2
    fi

    if [ ! -d "$JUJU_RELEASES" ]
    then
        mkdir -p "$JUJU_RELEASES" || HandleError "Failed to create juju releases folder"
    fi
    rm -rf $JUJU_RELEASES/* || HandleError "Failed to clean tools directory"
    pushd "$JUJU_RELEASES"
    for i in trusty centos7
    do
        V_STRING=$(printf "$VERSION_STR" $i)
        tar -czf "juju-$V_STRING.tgz" -C "$BIN_DIR" jujud 
    done

    for i in win2012r2 win2012hvr2
    do
        V_STRING=$(printf "$VERSION_STR" $i)
        tar -czf "juju-$V_STRING.tgz" -C "$WIN_BIN_DIR" jujud.exe
    done
}

GenerateStreams() {
    if [ -d "$STREAMS_DIR" ]
    then
        rm -rf "$STREAMS_DIR"
    fi

    juju-metadata generate-tools

    if [ -e $WWW_TOOLS ] && [ ! -L $WWW_TOOLS ]
    then
        echo "$WWW_TOOLS exists but is not a symlink...skipping"
        return
    fi

    if [ -e $TGT ]
    then
        sudo rm -f $WWW_TOOLS
    fi
    
    sudo ln -s $JUJU_TOOLS $(dirname $WWW_TOOLS)
    chmod 755 -R $JUJU_TOOLS

}

BuildJuju
CreateTgz
GenerateStreams
