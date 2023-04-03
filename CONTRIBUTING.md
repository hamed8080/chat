# Contributing to Chat

## Introduction

### Welcome

Thank you for considering contributing to Chat.

Please know that everyone is welcome to contribute to Chat.
Contributing doesn’t just mean submitting pull requests—there are 
many different ways for you to get involved,
including answering questions on the github issues and
reporting or screening bugs, and writing documentation. 

This document focuses on how to contribute code and documentation to
this repository.

### Legal

By submitting a pull request, you represent that you have the right to license your
contribution to the community, and agree by submitting the patch that your 
contributions are licensed under the Apache 2.0 license (see [`LICENSE.txt`](/LICENSE.txt)).

## Contributions Overview

Chat is an open source project and we encourage contributions
from the community.

### Contributing Code and Documentation

Before contributing code or documentation to Chat,
we encourage you to first open a 
[GitHub issue](https://github.com/hamed8080/chat/issues/new/choose) 
for a bug report or feature request.
This will allow us to provide feedback on the proposed change.
However, this is not a requirement. If your contribution is small in scope,
feel free to open a PR without first creating an issue.

All changes to Chat source must go through the PR review process before
being merged into the `main` branch.
See the [Code Contribution Guidelines](#code-contribution-guidelines) below for
more details.

## Building Chat

### Prerequisites

Chat is a Swift package. If you're new to Swift package manager,
the [documentation here](https://swift.org/getting-started#using-the-package-manager)
provides an explanation of how to get started and the software you'll need
installed.

### Build Steps

1. Checkout this repository using:

    ```bash
    git clone git@github.com:hamed8080/chat.git
    ```

2. Navigate to the root of your cloned repository with:

    ```bash
    cd Chat
    ```

3. Create a new branch off of `master` for your change using:

    ```bash
    git checkout -b branch-name-here
    ```

    Note that `master` (the repository's default branch) will always hold the most
    recent approved changes. In most cases, you should branch off of `master` when
    starting your work and open a PR against `master` when you're ready to merge
    that work.

4. Build Chat from the command line by running:

    ```bash
    swift build
    ```

    Alternatively, to use Xcode, open the `Package.swift` file
    at the repository's root. Then, build it by pressing Command-B.

## Code Contribution Guidelines

### Overview

- Do your best to keep the git history easy to understand.
  
- Use informative commit titles and descriptions.
  - Include a brief summary of changes as the first line.
  - Describe everything that was added, removed, or changed, and why.

- All changes must go through the pull request review process.

### Pull Request Preparedness Checklist

When you're ready to have your change reviewed, please make sure you've completed the following
requirements:

- [x] Niether you have added feature or fixed a bug you should test the fucntionaly of the new code manully.

- [x] Add source code documentation to all added or modified APIs that explains
  the new behavior.

### Opening a Pull Request

When opening a pull request, please make sure to fill out the pull request template
and complete all tasks mentioned there.

Your PR should mention the number of the GitHub issue your work is addressing.
  
Most PRs should be against the `master` branch. If your change is intended 
for a specific release, you should also create a separate branch 
that cherry-picks your commit onto the associated release branch.

### Code Review Process

All PRs will need approval from someone on the core team
(someone with write access to the repository) before being merged.
