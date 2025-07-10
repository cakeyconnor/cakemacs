#!/bin/sh
# Posix compliant script to manage CakeMacs, use the help command for more information on each specific command.

case "$1" in
    sync)
        git -C ~/.cakemacs.d/ pull
        ;;
    install)
        echo "Installing CakeMacs..."
        if [ -e "$HOME/.cakemacs.d/emacs.d/" ]; then
            if [ -e "$HOME/.emacs.d/" ]; then
                echo "Backing up previous Emacs Configuration"
                mv "$HOME/.emacs.d/" "$HOME/.emacs.d.backup/"
                echo "Moved to $HOME/.emacs.d.backup/"
            fi

            mv "$HOME/.cakemacs.d/emacs.d/" "$HOME/.cakemacs.d/.emacs.d"
            mv "$HOME/.cakemacs.d/.emacs.d" "$HOME"

            if [ -f "$HOME/.emacs.d/init.el" ]; then
                :
            else
                echo "Something has gone wrong, have you touched stuff in the emacs.d directory? Undoing changes..."

                if [ -e "$HOME/.emacs.d" ]; then
                    mv "$HOME/.emacs.d" "$HOME/emacs.d.undo"
                fi

                if [ -e "$HOME/.cakemacs.d/.emacs.d" ]; then
                    mv "$HOME/.cakemacs.d/.emacs.d" "$HOME/.cakemacs.d/emacs.d.undo"
                fi

                if [ -e "$HOME/.emacs.d.backup" ]; then
                    echo "Restoring previous Emacs configuration"
                    mv "$HOME/.emacs.d.backup" "$HOME/.emacs.d"
                fi
            fi
        else
            echo "Missing directories, executing sync command"
            if [ -f "$HOME/.cakemacs.d/emacs.d/cakemacs" ]; then
                "$HOME/.cakemacs.d/bin/cakemacs" sync
            else
                echo "$HOME/.cakemacs.d/bin/cakemacs file does not exist, please do not move around directories or scripts will break."
            fi
        fi
        ;;
    uninstall)
        if [ -f "$HOME/.emacs.d/thisisacakemacsconfig" ]; then
            rm -rf "$HOME/.emacs.d/"
            echo "CakeMacs has been uninstalled"
        else
            echo "No CakeMacs configuration found to uninstall."
        fi
        ;;
    purge)
        if [ -f "$HOME/.emacs.d/thisisacakemacsconfig" ]; then
            rm -rf "$HOME/.emacs.d/"
            echo "CakeMacs Emacs configuration purged."
        else
            if [ -e "$HOME/.emacs.d/" ]; then
                echo "The current Emacs configuration is not a CakeMacs configuration, your configuration has not been purged."
            else
                echo "Emacs directory does not exist, or it is not located at $HOME/.emacs.d/"
            fi
        fi
	
	if [ -e "$HOME/.cakemacs.d/" ]; then
	    rm -rf "$HOME/.cakemacs.d/"
	else
	    echo "$HOME/.cakemacs.d/ directory does not exist"
	fi
        ;;
    help)
	echo "------ CakeMacs Commands Help ------"
	echo "Sync: Syncs the current configuration with the latest configuration version that is on the github"
	echo "Install: Installs the current CakeMacs configuration, highly recommended to run the sync command before installing"
	echo "Uninstall: Safely uninstalls the CakeMacs configuration but not the files to recreate it."
	echo "Purge: Purges everything related to CakeMacs, unsafely."
	echo "Help: Gives information on CakeMacs shell commands"
	echo "------------------------------------"
	;;
    *)
        echo "Usage: cakemacs [sync|install|uninstall|purge|help]"
        ;;
esac
