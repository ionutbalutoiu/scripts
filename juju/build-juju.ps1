$ErrorActionPreference = "Stop"

if ($args.Length -lt 2) {
    echo "PARAMETERS: <branch/tag> <branch_name/tag_name> [OPTIONAL]<reset>"
    exit 1
} elseif (($args[0] -ne "branch") -and ($args[0] -ne "tag")) {
    echo 'First argument must be: "branch" or "tag".'
    exit 1
}

if ($args[2] -eq "reset") {
    rm $env:GOPATH\pkg -ErrorAction SilentlyContinue -Recurse -Force
    rm $env:GOPATH\src -ErrorAction SilentlyContinue -Recurse -Force
    go get -v github.com/juju/juju/...
}

pushd $env:GOPATH\src\github.com\juju\juju
git checkout master
git pull origin master

switch ($args[0]) {
    "branch" {
        git checkout $args[1]
        git pull origin $args[1]
    }
    "tag" {
        $tagArg = "tags/" + $args[1]
        git checkout $tagArg
    }
}

go get -v launchpad.net/godeps
& (Join-Path $env:GOPATH "\bin\godeps.exe") -f -u dependencies.tsv
go install -v github.com/juju/juju/...
popd

# Copy the binaries to the MAAS & Juju machine
cp $env:GOPATH\bin\juju* Z:\golang\bin\ -ErrorAction SilentlyContinue -Force
