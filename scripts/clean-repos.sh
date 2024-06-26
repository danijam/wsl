#!/bin/bash

# exit on error
set -e

repos_dir=~/repos

# Check if the repos directory exists
if [ ! -d "$repos_dir" ]; then
    echo "Repos directory not found: $repos_dir"
    exit 1
fi

# Loop through each directory in the repos directory
for dir in "$repos_dir"/*; do
    if [ -d "$dir" ]; then
        echo "Processing directory: $dir"
        # require user input to continue
        read -p "Press enter to continue"

        # if not a git repo then continue to the next directory
        if [ ! -d "$dir/.git" ]; then
            echo "Not a git repository: $dir"
            continue
        fi
        echo "Found git repository: $dir"

        # if current branch is not main then continue to the next directory
        cd "$dir"
        current_branch=$(git branch --show-current)
        if [ "$current_branch" != "main" ]; then
            echo "Not on main branch: $current_branch"
            continue
        fi
        echo "On main branch"

        # fetch latest from remote
        echo "Fetching latest changes from remote"
        git fetch

        # if there are uncommitted changes then continue to the next directory
        if [ -n "$(git status --porcelain)" ]; then
            echo "Uncommitted changes found in $dir"
            continue
        fi
        echo "No uncommitted changes"

        # pull the latest changes
        echo "Pulling latest changes from remote"
        git pull

        # clean up the local branches
        echo "Cleaning up local branches"
        git fetch -p && \
        git for-each-ref --format '%(refname:short) %(upstream:track)' | \
        awk '$2 == "[gone]" {print $1}' | \
        xargs -r git branch -D
        echo "Local branches cleaned up"

        # if there are any branches left apart from main then continue to the next directory
        if [ -n "$(git branch | grep -v main)" ]; then
            echo "Branches other than main found in $dir"
            continue
        fi
        echo "No branches other than main"

        # at this point we have a repo that has no branches other than main,
        # no uncommitted changes and is up to date with the remote
        # so we can delete it
        cd ..
        echo "Deleting $dir"
        rm -rf "$dir"
    fi
done
