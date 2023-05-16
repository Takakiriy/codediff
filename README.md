# codediff

Show difference between folders or Git repository
as Git commit difference in Visual Studio Code.

([Japanese](./README-jp.md))

![screen shot](./codediff.png)

## Command Example

    codediff  #// If there is not `~/_tmp/_diff/1` folder:
        #// Create a Git working folder at `~/_tmp/_diff/1`
        #// Setting file `.codediff.ini` is made
        #// Visual Studio Code is opened
        #// Edit the setting file `.codediff.ini`

    codediff  #// If there is `~/_tmp/_diff/1` folder:
        #// .git folder is created in local and Git commit difference is created
        #// Visual Studio Code is opened
        #// Change to Source Control view and show difference

## Setting file

Example:

    # codediff command setting file

    [New]
    LocalFullPath = /home/user1/project1
    DeleteRelativePath = _base

    [Old]
    RepositoryURL = https://github.com/Takakiriy/example1
    BranchOrTag = develop

Write 2 sections as the following format setting.

Case of copy from local other folder:

    [__CommitMessage__]
    LocalFullPath = ____
    DeleteRelativePath = ____
    DeleteRelativePath = ____
        ...

Case of downloading from Git repository:

    [__CommitMessage__]
    RepositoryURL = ____
    BranchOrTag = ____
    BaseRelativePath = ____
    DeleteRelativePath = ____
    DeleteRelativePath = ____
        ...

It is not necessary to write `DeleteRelativePath` in all sections.

## Test

    cd  test
    ./test_codediff.sh
    ./test_codediff.sh --manual-test
