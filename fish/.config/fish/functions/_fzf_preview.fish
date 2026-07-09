# Preview function for fzf completion (Shift+Tab)
# Shows bat for files, eza tree for directories
function _fzf_preview
    if test -d $argv[1]
        eza --tree --icons --all --color=always $argv[1] | head -200
    else
        bat -pp --line-range :500 --force-colorization $argv[1]
    end
end
