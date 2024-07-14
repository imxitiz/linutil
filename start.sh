#!/bin/sh

RC='\033[0m'
RED='\033[0;31m'

linutil="https://github.com/ChrisTitusTech/linutil/releases/latest/download/linutil"

check() {
    local exit_code=$1
    local message=$2

    if [ $exit_code -ne 0 ]; then
        echo "${RED}ERROR: $message${RC}"
        exit 1
    fi
}

TMPFILE=$(mktemp)
check $? "Creating the temporary file"

curl -fsL $linutil -o $TMPFILE
check $? "Downloading linutil"

chmod +x $TMPFILE
check $? "Making linutil executable"

if ! fc-list | grep -iq "Meslo.*Nerd"; then
    echo "Font not installed"

    TEMPFONT=$(mktemp)
    check $? "Creating the temporary font file"

    curl -fsL "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Meslo/M/Regular/MesloLGMNerdFont-Regular.ttf" -o $TEMPFONT
    check $? "Downloading the font"

    # copy the font to the fonts directory
    mkdir -p ~/.local/share/fonts
    check $? "Creating the fonts directory"

    cp $TEMPFONT ~/.local/share/fonts/MesloLGMNerdFont-Regular.ttf
    check $? "Copying the font to the fonts directory"

    fc-cache -f -v
    check $? "Refreshing the font cache"
fi

"$TMPFILE"
check $? "Executing linutil"

rm -f $TMPFILE
check $? "Deleting the temporary file"
