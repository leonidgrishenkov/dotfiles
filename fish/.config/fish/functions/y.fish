# Yazi wrapper — change CWD on exit
# https://yazi-rs.github.io/docs/quick-start#shell-wrapper
function y
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    set -l cwd (cat "$tmp" 2>/dev/null)
    if test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd "$cwd"
    end
    rm -f "$tmp"
end

