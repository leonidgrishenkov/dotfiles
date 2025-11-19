
function install_theme() {
    if [ -z "$DOTFILES_DIR" ]; then
        echo 'DOTFILES_DIR env var is required'
        exit 1
    fi

    base_url=https://github.com/catppuccin/yazi/raw/main/themes
    theme_name="$1" # NOTE: actually subpath to theme in repo, like: frappe/catppuccin-frappe-blue.toml
    output_path=/tmp/theme.toml

    echo "Installing catppuccin theme: $theme_name"

    wget -q --show-progress \
        -O $output_path \
        "${base_url}/${theme_name}"

    #TODO: add here step to change this key in toml file: mgr.syntect_theme (see readme for details)
}
