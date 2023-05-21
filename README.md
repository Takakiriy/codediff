# codediff

codediff is a CLI command that displays difference
between two folders in Visual Studio Code
in easy-to-understand manner.
You can also specify Git repository URL or a diff configuration file.

You can also be used on mac without free comparison software.

([Japanese](./README-jp.md))

![screen shot](./codediff.png)


## Command Example

### If specifying a comparison target for the codediff command

    codediff  path/to/folder1  path/to/folder2

or

    codediff  https://URL1#branch1  https://URL2#branch2

You can also specify paths and URL to compare.

- Create a setting file at `~/_tmp/_diff/1/.codediff.ini`
- `.git` folder is created in `~/_tmp/_diff/1/working` and Git commit difference is created
- Visual Studio Code is opened
- Please change to Source Control view and show difference

### If there is not command parameterｓ and there is not `~/_tmp/_diff/1/.codediff.ini` file

    codediff

- Create a setting file at `~/_tmp/_diff/1/.codediff.ini`.
    Created file is a copy of `codediff_template.ini` file
    that there is in `codediff` command folder
- Visual Studio Code is opened
- To compare is not done, yet
- Please, edit the setting file `.codediff.ini` and run `codediff` again (below described)

### If there is not command parameterｓ and there not `~/_tmp/_diff/1/.codediff.ini` file

    codediff

- Read `~/_tmp/_diff/1/.codediff.ini` file
- `.git` folder is created in `~/_tmp/_diff/1/working` and Git commit difference is created
- Visual Studio Code is opened
- Please change to Source Control view and show difference

### If codediff command has a setting file path parameter

    codediff  codediff.ini

- Copy the specified setting file to `~/_tmp/_diff/1/.codediff.ini` and read it.
    At this time, LocalPath parameter is replaced to full path
- `.git` folder is created in `~/_tmp/_diff/1/working` and Git commit difference is created
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
