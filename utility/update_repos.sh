#!/bin/bash
# https://stackoverflow.com/a/36800741
#
# Usage:
#   ./update_git_repos.sh [parent_directory] 

updateRepo() {
    local dir="$1"
    local original_dir="$2"
    cd $dir # switch to the git repo
    repo_url=$(git config --get remote.origin.url)

    echo "****************************************************************************"
    echo "Updating Repo: $dir with url: $repo_url"
    echo "Starting update in $PWD"

    main_branch="master" 
    if [ "$repo_url" == "git@someserver:repo/repo.git" ]; then # if you have a repo where the primary branch isnt master
        $main_branch="trunk"
    fi

    # update the repo, then stash any local changes
    echo -e "\ncalling: git fetch --all && git stash"
    (git fetch --all && git stash)
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    # switch to master/trunk branch and rebase it, then switch back to original branch
    if [ $current_branch != $main_branch ]; then
        echo -e "\ncalling: git checkout $main_branch && git rebase && git checkout $current_branch"
        (git checkout $main_branch && git rebase && git checkout $current_branch)
    fi

    # rebase the original branch and then stash pop back to original state
    echo -e "\ncalling: git rebase && git stash pop on branch: $current_branch"
    (git rebase && git stash pop ) 

    #switch back to the starting directory
    cd $original_dir
    echo ""
}

directory_to_update=${1}

if [ -z "$directory_to_update" ] ; then
    echo "no directory passed in, using current directory"
    directory_to_update=$PWD
fi 
echo "Updating git repo's in directory: $directory_to_update"
count=0
for dir in $(find $directory_to_update -maxdepth 4 -type d -name .git | xargs -n 1 dirname); do
    updateRepo $dir $directory_to_update #& #uncomment to make it run in multiple threads, meh
    ((count+=1))
done

echo "$count local git repos have been updated!"