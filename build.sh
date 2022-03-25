#!/bin/sh

# Exit if subprocess return non-zero exit code
set -e

# Log function
log () {
    echo -e "\033[0;32m[LOG]\033[0m $1"
}
err () {
    echo -e "\033[0;31m[ERR]\033[0m $1"
}

# This will always be true unless there is
# missing executable that we need to use
install_pass=true

# Check if $1 is installed
check_installed () {
    if ! command -v $1 -h &> /dev/null
    then
        err "$1 is not installed"
        if [ install_pass ]; then
            install_pass=false
        fi
    fi
}

check_installed cargo
check_installed git
check_installed deno # deno is required for running transpiled program

# If all of the above is installed
if [ ! install_pass ]; then
    exit 1
fi
log "Dependencies is installed. Cloning..."

rm -rf ~/.cache/hazure/build/
git clone https://github.com/azur1s/hazure.git ~/.cache/hazure/build/

cd ~/.cache/hazure/build/

# Remove the progress bar
CARGO_TERM_PROGRESS_WHEN=never

if [ $1 = "d" ]; then
    log "Building in debug..."
    cargo build
    rm ~/bin/hazure -f
    mv ~/.cache/hazure/build/target/debug/hazure ~/bin/hazure
else
    log "Building..."
    cargo build --release
    rm ~/bin/hazure -f
    mv ~/.cache/hazure/build/target/release/hazure ~/bin/hazure
fi

unset CARGO_TERM_PROGRESS_WHEN

log "Build done. Cleaning up..."

rm -rf ~/.cache/hazure/build/

log "Done."
hazure -h
