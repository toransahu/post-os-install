#!/bin/bash

set -euox pipefail
source ./logging.sh

GH_DIR=~/disk/E/workspace/github.com
GH_ME=toransahu
GH_OS_DIR=$GH_DIR/$GH_ME/post-os-install
GH_MACOS_DIR=$GH_DIR/$GH_ME/post-macos-install
GH_LINUX_DIR=$GH_DIR/$GH_ME/post-linux-install
GH_LINUX_TWEAKS=$GH_DIR/$GH_ME/linux-tweaks
REPOS=(linux-tweaks post-os-install post-macos-install post-linux-install dotfiles dotfiles.pvt)
X_PLATFORM=

DOTFILES=".paths.sh .bashrc .bash_aliases .bashitrc .bash_profile .profile .bashrc.save .editorconfig .tmux.conf .vimrc .zshrc .commonrc .coc-settings.json .zprofile"
DOTFILES_PVT=".bash_history .zsh_history .duckdb_history .psql_history .python_history .2fa .gitconfig"
DOTDIRS=".personalized "
DOTDIRS_PVT=".config .ssh "

setup_workspace_dir() {
    mkdir -p $GH_DIR
}

clone_repos() {
    for repo in ${REPOS[@]}; do
        if [ ! -d "$GH_DIR/$GH_ME/$repo" ]; then
            git clone https://github.com/toransahu/$repo $GH_DIR/$GH_ME/$repo
        else
            echo $repo already cloned. Pulling updates
            cd $GH_DIR/$GH_ME/$repo && git pull origin master && cd -
        fi
    done
}

copy_dotfiles() {
    SOURCE=$1
    shift
    DEST=$1
    shift
    echo Running copy_dotfiles $SOURCE $DEST
    for file in $@; do
        cp "$SOURCE/$file" "$DEST/" && echo "Copy $file successful" || echo "Copy $file failed"
    done
}

copy_dotdirs() {
    SOURCE=$1
    shift
    DEST=$1
    shift
    echo Running copy_dotdirs $SOURCE $DEST
    for dir in $@; do
        cp -r $SOURCE/$dir $DEST/ && echo "Copy $dir successful" || echo "Copy $dir failed"
    done
}

deploy_dotfiles() {
    BACKUP_DIR=~/dotfiles-backup/$(date +%y%m%dT%H%M%S)
    mkdir -p $BACKUP_DIR
    copy_dotfiles $HOME $BACKUP_DIR/ $DOTFILES
    copy_dotfiles $GH_DIR/$GH_ME/dotfiles ~/ $DOTFILES
}

deploy_dotfiles_pvt() {
    BACKUP_DIR=~/dotfiles-backup/$(date +%y%m%dT%H%M%S)
    mkdir -p $BACKUP_DIR
    copy_dotfiles $HOME $BACKUP_DIR/ $DOTFILES_PVT
    copy_dotfiles $GH_DIR/$GH_ME/dotfiles.pvt ~/ $DOTFILES_PVT
}

deploy_dotdirs() {
    BACKUP_DIR=~/dotfiles-backup/$(date +%y%m%dT%H%M%S)
    mkdir -p $BACKUP_DIR
    copy_dotdirs $HOME $BACKUP_DIR/ $DOTDIRS
    copy_dotdirs $GH_DIR/$GH_ME/dotfiles ~/ $DOTDIRS
}

deploy_dotdirs_pvt() {
    dirs=".config .ssh "
    BACKUP_DIR=~/dotfiles-backup/$(date +%y%m%dT%H%M%S)
    mkdir -p $BACKUP_DIR
    copy_dotdirs $HOME $BACKUP_DIR/ $DOTDIRS_PVT
    copy_dotdirs $GH_DIR/$GH_ME/dotfiles.pvt ~/ $DOTDIRS_PVT
}

vcs_dotfiles() {
    copy_dotfiles $HOME $GH_DIR/$GH_ME/dotfiles $DOTFILES
    copy_dotfiles $HOME $GH_DIR/$GH_ME/dotfiles.pvt $DOTFILES_PVT
    copy_dotdirs $HOME $GH_DIR/$GH_ME/dotfiles $DOTDIRS
    copy_dotdirs $HOME $GH_DIR/$GH_ME/dotfiles.pvt $DOTDIRS_PVT
}

setup_ssh() {
    chmod 700 ~/.ssh/
    chmod 600 ~/.ssh/id_*
}

setup_gpg() {
     gpg --import $GH_ME/dotfiles.pvt/.gnupg/toran.sahu@yahoo.com.key
}

install_additional_packages() {
    wget -O - https://raw.githubusercontent.com/toransahu/post-linux-install/master/src/setup_additional_pkg.sh | sh
}

setup_python() {
    items="pyenv_prereq pyenv"
    for i in $items; do
        source $GH_DIR/$GH_ME/post-$X_PLATFORM-install/src/install_$i.sh
    done
}

setup_java() {
    items="jenv "
    for i in $items; do
        source $GH_DIR/$GH_ME/post-$X_PLATFORM-install/src/install_$i.sh
    done
}

setup_zsh() {
    source $GH_DIR/$GH_ME/post-$X_PLATFORM-install/src/install_zsh_autosuggestions.sh
    source $GH_DIR/$GH_ME/post-$X_PLATFORM-install/src/install_zsh_syntax_highlighting.sh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

setup_tmux() {
    items="tmux tmux_clipboard tmux_pkg_mngr"
    for i in $items; do
        source $GH_DIR/$GH_ME/post-$X_PLATFORM-install/src/install_$i.sh
    done
}

setup_vim() {
    items="vim vim_coc vim_coc_ext vim_nerd_font"
    for i in $items; do
        source $GH_DIR/$GH_ME/post-$X_PLATFORM-install/src/install_$i.sh
    done

}

setup_cinnamon() {
    echo Running setup_cinnamon
}

platform_check() {
    X_PLATFORM=$(source $GH_DIR/$GH_ME/post-os-install/platform_check.sh)
    echo Detected plaform=$X_PLATFORM
}

common_setup() {
    setup_workspace_dir
    clone_repos
    deploy_dotfiles
    deploy_dotfiles_pvt
    deploy_dotdirs
    deploy_dotdirs_pvt
    setup_ssh
    setup_gpg
}

any_platform_setup() {
    source $GH_DIR/$GH_ME/post-$X_PLATFORM-install/src/preprocessor.sh
    pkgs="firefox google_chrome git_delta ripgrep fzf jq tree speedtest"
    for pkg in $pkgs; do
        pkg_install_script=$GH_DIR/$GH_ME/post-$X_PLATFORM-install/src/install_$pkg.sh
        if [ ! -f "$pkg_install_script" ]; then
            warn "$pkg_install_script does not exist for $X_PLATFORM"
        else
	    source $pkg_install_script && echo "Successfully (re)installed $pkg" || echo "Failed to (re)install $pkg"
        fi
    done
}

macos_only_setup() {
    pkgs="brew mos iterm2 rectangle gnu_coreutils"
    for pkg in $pkgs; do
        source $GH_MACOS_DIR/src/install_$pkg.sh
    done

    # pkgs="python java zsh tmux"
    pkgs="python zsh tmux"
    for pkg in $pkgs; do
	setup_$pkg && echo "Successfully (re)installed $pkg" || echo "Failed to (re)install $pkg"
    done
    source ~/.paths.sh
}

platform_specific_setup() {
    echo "OS detected: $X_PLATFORM"
    if [[ "$X_PLATFORM" == "linux"* ]]; then
        :
    elif [[ "$X_PLATFORM" == "macos"* ]]; then
        # Mac OSX
        macos_only_setup
        :
    elif [[ "$X_PLATFORM" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
        :
    elif [[ "$X_PLATFORM" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
        :
    elif [[ "$X_PLATFORM" == "win32" ]]; then
        # I'm not sure this can happen.
        :
    elif [[ "$X_PLATFORM" == "freebsd"* ]]; then
        # ...
        :
    else
        echo Unknown OS!
    fi
}

setup() {
    common_setup
    platform_check
    any_platform_setup
    platform_specific_setup
}

setup
# vcs_dotfiles

# TODO: work specific pkgs:  colima protobuf gcloud
