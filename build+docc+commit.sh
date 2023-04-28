#!/bin/bash

source $(dirname $0)/environment+variables.sh

#Use git worktree to checkout the $DOCC_BRANCH_NAME branch of this repository in a $DOCC_BRANCH_NAME sub-directory
git worktree add --checkout $DOCC_BRANCH_NAME

cd $DOCC_BRANCH_NAME #move to worktree directory to create all files there

# # Pretty print DocC JSON output so that it can be consistently diffed between commits
export DOCC_JSON_PRETTYPRINT="YES"

swift package --allow-writing-to-directory $DOCC_OUTPUT_FOLDER \
    generate-documentation --target $TARGET_NAME \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path $HOST_BASE_PATH \
    --output-path $DOCC_OUTPUT_FOLDER

cp images/icon.png $DOCC_OUTPUT_FOLDER/$TARGET_NAME/favicon.ico
cp images/icon.svg $DOCC_OUTPUT_FOLDER/$TARGET_NAME/favicon.svg

### Save the current commit we've just built documentation from in a variable
CURRENT_COMMIT_HASH=$(git rev-parse --short HEAD)

## Commit our changes to the $DOCC_BRANCH_NAME branch
echo "worktree documentation path: ${PWD}/$DOCC_OUTPUT_FOLDER"
git add $DOCC_OUTPUT_FOLDER

if [ -n "$(git status --porcelain)" ]; then
    echo "Documentation changes found. Committing the changes to the '$DOCC_BRANCH_NAME' branch."
    echo "Please call push manually"
    git commit -m "Update Github Pages documentation site to $CURRENT_COMMIT_HASH"
    open -n https://$GITHUB_USER_NAME.github.io/${HOST_BASE_PATH}/documentation/${LOWERCASE_TARGET_NAME}/
else
    # No changes found, nothing to commit.
    echo "No documentation changes found."
fi

git worktree remove -f $DOCC_BRANCH_NAME

# After deleting the worktree we should back to the root directory for pushing new files.
cd $ROOT_DIR
git push origin $DOCC_BRANCH_NAME

