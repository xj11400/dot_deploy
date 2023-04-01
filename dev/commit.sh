#!/bin/bash

function submodule_commit() {
    if [ ! -z "$(git status | grep -E "modified:.+core")" ]; then
        git add core
        git commit -m "<submodule>(core): $(git diff --staged core | grep index | cut -d ' ' -f 2)"
    fi
}

#submodule_commit

NEW=$(git status | grep -E "modified:.+\(.*new commits" | awk '{print $2}')
for update in $NEW;do
    echo $update
    git add $update
    git commit -m "<$update>: $(git diff --staged $update | grep index | cut -d ' ' -f 2)"
done

