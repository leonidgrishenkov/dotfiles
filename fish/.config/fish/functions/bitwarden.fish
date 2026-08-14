function bwu --description "Unlock Bitwarden and export session"
    set -gx BW_SESSION (bw unlock --raw)
    and bw sync
end

