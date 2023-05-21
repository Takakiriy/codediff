# codediff

Show difference between folders or Git repository
as Git commit difference in Visual Studio Code.

([Japanese](./README-jp.md))

![screen shot](./codediff.png)

## Command Example

### If there is not `~/_tmp/_diff/1` folder

    codediff

- Create a Git working folder at `~/_tmp/_diff/1`
- Setting file `.codediff.ini` is made
- Visual Studio Code is opened
- Edit the setting file `.codediff.ini`

### If there is `~/_tmp/_diff/1` folder

    codediff

- Read `~/_tmp/_diff/1/.codediff.ini` file
- `.git` folder is created in local and Git commit difference is created
- Visual Studio Code is opened
- Please change to Source Control view and show difference

### If codediff command has a setting file path parameter

    codediff  codediff.ini

- Copy the specified setting file to `~/_tmp/_diff/1` and read it.
    At this time, LocalPath parameter is replaced to full path
- `.git` folder is created in local and Git commit difference is created
- Visual Studio Code is opened
- Please change to Source Control view and show difference


## Setting file

Example:

    # codediff command setting file

    [New]
    LocalPath = /home/user1/project1
    DeleteRelativePath = _base

    [Old]
    RepositoryURL = https://github.com/Takakiriy/example1
    BranchOrTag = develop

Write 2 sections as the following format setting.

Case of copy from local other folder:

    [__CommitMessage__]
    LocalPath = ____
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

If you embed the settings in a part such as YAML,
write a `#codediff` tag and codediff settings.
The settings are until it becomes shallower than
the depth of the line following the tag.

    This is a YAML file:

    diff: |  #codediff:
        [New]
        LocalPath = /home/user1/project1
        DeleteRelativePath = _base

        [Old]
        RepositoryURL = https://github.com/Takakiriy/example1
        BranchOrTag = develop
    This is out of codediff settings:

## Test

    cd  test
    ./test_codediff.sh
    ./test_codediff.sh --manual-test
