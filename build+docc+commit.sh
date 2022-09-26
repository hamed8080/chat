#!/bin/bash

TARGET_NAME="FanapPodChatSDK"
BUNDLE_ID="ir.fanap.${TARGET_NAME}"
BUNDLE_VERSION="1.0.0"
DOCC_FILE_PATH="/Users/hamed/Desktop/Workspace/ios/Fanap/FanapPodChatSDK/Sources/FanapPodChatSDK/FanapPodChatSDK.docc"
DOCC_HOST_BASE_PATH="fanappodchatsdk"
DOCC_OUTPUT_FOLDER="./docs"
DOCC_SYMBOL_GRAPHS=".build/symbol-graphs/"
DOCC_SYMBOL_GRAPHS_OUTPUT=".build/swift-docc-symbol-graphs"
BRANCH_NAME="gl-pages"

function isSymbolGraphDirectoryExist() {
    [ -d $DOCC_SYMBOL_GRAPHS ]
}

function makeSymbolGraphs() {
    mkdir -p $DOCC_SYMBOL_GRAPHS &&
        swift build --target $TARGET_NAME \
            -Xswiftc -emit-symbol-graph \
            -Xswiftc -emit-symbol-graph-dir -Xswiftc $DOCC_SYMBOL_GRAPHS

    mkdir $DOCC_SYMBOL_GRAPHS_OUTPUT &&
        mv "${DOCC_SYMBOL_GRAPHS}${TARGET_NAME}"* $DOCC_SYMBOL_GRAPHS_OUTPUT
}

#Use git worktree to checkout the $BRANCH_NAME branch of this repository in a $BRANCH_NAME sub-directory
git worktree add --checkout $BRANCH_NAME

# # Pretty print DocC JSON output so that it can be consistently diffed between commits
export DOCC_JSON_PRETTYPRINT="YES"

if isSymbolGraphDirectoryExist; then
    echo "Symbol directory graph is exist"
else
    makeSymbolGraphs
fi

## Create docc files and folders
swift package --allow-writing-to-directory $DOCC_OUTPUT_FOLDER \
    generate-documentation \
    --target $TARGET_NAME \
    --output-path $DOCC_OUTPUT_FOLDER \
    --transform-for-static-hosting \
    --hosting-base-path $DOCC_HOST_BASE_PATH \
    --additional-symbol-graph-dir $DOCC_SYMBOL_GRAPHS_OUTPUT \
    --disable-indexing

### Save the current commit we've just built documentation from in a variable
CURRENT_COMMIT_HASH=$(git rev-parse --short HEAD)

## Commit and push our changes to the $BRANCH_NAME branch
mv docs "$BRANCH_NAME/"
cd $BRANCH_NAME #move to worktree directory
echo "worktree docs path: ${PWD}/docs"
git add docs

if [ -n "$(git status --porcelain)" ]; then
    echo "Documentation changes found. Committing the changes to the '$BRANCH_NAME' branch."
    echo "Please call push manually"
    git commit -m "Update Gitlab Pages documentation site to $CURRENT_COMMIT_HASH"
else
    # No changes found, nothing to commit.
    echo "No documentation changes found."
fi

git worktree remove -f $BRANCH_NAME
