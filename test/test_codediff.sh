#!/bin/bash
ThisScriptParentPath="$( readlink -f "${0%/*}" )"
ProjectPath="${ThisScriptParentPath%/*}"

PositionalArgs=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--manual-test)  Options_ManualTest="yes"; shift;;  #// Without value
        -*) echo "Unknown option $1"; exit 1;;
        *) PositionalArgs+=("$1"); shift;;
    esac
done
set -- "${PositionalArgs[@]}"  #// set $1, $2, ...
unset PositionalArgs

function  Main() {
    TestLocal
    TestGitRepository
    TestGitRepositorySubFolder
    EndOfTest
}

function  TestLocal() {
    echo  ""
    echo  "TestLocal =================================="
    local  workingFolderPath="$HOME/_tmp/_diff/1"

    #// 1st command
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
    Pause  "Next: Check opening a folder that contains .codediff.ini file."

    ../codediff  ${TestOption}
    if [ "$( cat "${workingFolderPath}/.codediff.ini" )" != "$( cat "../codediff_template.ini" )" ]; then  TestError  "1"  ;fi
    AssertNotExist  "${workingFolderPath}/working"
    Pause  "OK?"

    #// 2nd command
    CopyIniFileTemplate  "files/1_codediff.ini"  "${workingFolderPath}"
    Pause  "Next: Check opening the working folder."

    ../codediff  ${TestOption}
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "a2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    Pause  "OK?"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "a1" ]; then  TestError  "3"  ;fi
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
}

function  TestGitRepository() {
    echo  ""
    echo  "TestGitRepository =================================="
    local  workingFolderPath="$HOME/_tmp/_diff/1"
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"

    CopyIniFileTemplate  "files/2_repository_codediff.ini"  "${workingFolderPath}"
    Pause  "Next: Check opening the working folder."

    ../codediff  ${TestOption}
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git a2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    Pause  "OK?"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git a1" ]; then  TestError  "3"  ;fi
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
}

function  TestGitRepositorySubFolder() {
    echo  ""
    echo  "TestGitRepositorySubFolder =================================="
    local  workingFolderPath="$HOME/_tmp/_diff/1"
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"

    CopyIniFileTemplate  "files/3_sub_folder_codediff.ini"  "${workingFolderPath}"
    Pause  "Next: Check opening the working folder."

    ../codediff  ${TestOption}
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git sub 2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    Pause  "OK?"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git sub 1" ]; then  TestError  "3"  ;fi
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
}

function  CopyIniFileTemplate() {
    local  templatePath="$1"
    local  workingFolderPath="$2"
    mkdir -p  "${workingFolderPath}"

    cat  "${templatePath}"  |  sed -E "s|__Project__|${ProjectPath}|"  > "${workingFolderPath}/.codediff.ini"
}

function  ChangeToOldCommit() {
    pushd  "${workingFolderPath}/working"  > /dev/null

    git reset  > /dev/null  2>&1
    git checkout "."  > /dev/null  2>&1
    popd  > /dev/null
}

function  Pause() {
    local  message="$1"
    if [ "${Options_ManualTest}" == "" ]; then
        return
    fi

    echo  ""
    echo  "${message}"
    read  -p "To continue, press Enter key."  dummyVariable 
}

function  AssertNotExist() {
    local  path="$1"

    if [ -e "${path}" ]; then
        Error  "ERROR: Found \"${path}\""
    fi
}

function  AssertReadOnly() {
    local  path="$1"
    local  writable=${False}

    local  attributes="$(ls -la "${path}")"
    echo "${attributes:0:10}" | grep w  > /dev/null  &&  writable=${True}

    if [ "${writable}" == "${True}" ]; then
        Error  "ERROR: Not read only file \"${path}\""
    fi
}

function  Error() {
    local  errorMessage="$1"
    local  exitCode="$2"
    if [ "${errorMessage}" == "" ]; then
        errorMessage="ERROR"
    fi
    if [ "${exitCode}" == "" ]; then  exitCode=2  ;fi

    echo  "${errorMessage}" >&2
    exit  "${exitCode}"
}

function  TestError() {
    local  errorMessage="$1"
    if [ "${errorMessage}" == "" ]; then
        errorMessage="a test error"
    fi
    if [ "${ErrorCountBeforeStart}" == "${NotInErrorTest}" ]; then

        echo  "ERROR: ${errorMessage}"
    fi
    LastErrorMessage="${errorMessage}"
    ErrorCount=$(( ${ErrorCount} + 1 ))
}
ErrorCount=0

function  EndOfTest() {
    echo  ""
    echo  "ErrorCount: ${ErrorCount}"
    if [ "${ErrorCount}" == "0" ]; then
        echo  "Pass."
    fi
}

True=0
False=1
if [ "${Options_ManualTest}" != "" ]; then
    TestOption=""
else
    TestOption=" --test"
fi

Main
