function jq
    command jq $argv | bat --language=json --paging=auto --plain
end
