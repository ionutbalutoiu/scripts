set -e

if [ $# -lt 2 ]; then
    echo "USAGE: $0 <branch/tag> <branch_name/tag_name> [OPTIONAL]<reset>"
    exit 1
elif [ "$1" != "branch" ] && [ "$1" != "tag" ]; then
    echo 'First argument must be: "branch" or "tag".'
    exit 1
fi

if [ "$3" = "reset" ]; then
    rm -rf $GOPATH/pkg
    rm -rf $GOPATH/src
    go get -v github.com/juju/juju/...
fi

pushd $GOPATH/src/github.com/juju/juju
git checkout master
git pull origin master

if [ "$1" = "branch" ]; then
    git checkout "$2"
    git pull origin "$2"
elif [ "$1" = "tag" ]; then
    git checkout tags/"$2"
fi

go get launchpad.net/godeps
godeps -f -u dependencies.tsv
go install -v github.com/juju/juju/...
popd
