PROMPT='➡️  %~ %# '

# Save current command into list (prepend with numbering)
savecmd() {
    local file=~/.saved_cmds
    local cmd="$BUFFER"

    [[ -f $file ]] || touch $file

    # Increment all numbers
    awk '{print $1+1, substr($0, index($0,$2))}' $file > ${file}.tmp

    # Insert new command as #1
    echo "1 $cmd" | cat - ${file}.tmp > ${file}.new

    mv ${file}.new $file
    rm -f ${file}.tmp
}

zle -N savecmd
bindkey '^]' savecmd     # Ctrl+] to save

# ZLE widget: view mode
# Paste saved command into BUFFER instead of executing it
paste_saved_cmd() {
    local file=~/.saved_cmds
    local num="$1"

    # extract command by number
    local cmd=$(awk -v n=$num '$1==n { $1=""; print substr($0,2); exit }' "$file")

    if [[ -z "$cmd" ]]; then
        BUFFER=""       # clear buffer
        echo "Invalid selection: $num"
        return 1
    fi

    BUFFER="$cmd"       # paste into command line
    CURSOR=${#BUFFER}   # move cursor to end
}

# ZLE view mode
view_saved_cmds() {
    local file=~/.saved_cmds

    echo
    cat "$file"
    echo -n "Select number: "

    local key
    read -k key          # read ONE key only
    echo "$key"

    if [[ "$key" =~ '^[1-9]$' ]]; then
        paste_saved_cmd "$key"
    else
        echo "Cancelled."
    fi
}

zle -N view_saved_cmds
bindkey '^[' view_saved_cmds    # Ctrl+[ to view & execute

