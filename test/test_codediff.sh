#!/bin/bash
ThisScriptParentPath="$( readlink -f "${0%/*}" )"
ProjectPath="${ThisScriptParentPath%/*}"
cd  "${ThisScriptParentPath}"

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
    TestParameters
    TestLocal
    TestGitRepository
    TestGitRepositorySubFolder
    TestOfDelete
    TestInText
    TestCopyFolder
    TestSame
    TestConflictCheck
    EndOfTest
}

function  TestParameters() {
    echo  ""
    echo  "TestParameters =================================="
    local  workingFolderPath="$HOME/_tmp/_diff/1"

    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
    Pause  "Next: Check opening a Visual Studio Code and select Source Control view (git)."

    ../codediff  ${TestOption}  "files/repository_1"  "files/repository_2"
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "a2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    Pause  "OK? Close Visual Studio Code"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "a1" ]; then  TestError  "3"  ;fi

    ../codediff  ${TestOption}  \
        "https://github.com/Takakiriy/codediff#example_1"  \
        "https://github.com/Takakiriy/codediff#example_2"
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git a2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    test  "$( cat "_codediff.log" )" == "OpenIDE \"${HOME}/_tmp/_diff/1/working\""  ||  Error
    Pause  "OK? Close Visual Studio Code"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git a1" ]; then  TestError  "3"  ;fi
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
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
    Pause  "OK? Close Visual Studio Code"

    #// 2nd command
    CopyIniFileTemplate  "files/1_codediff.ini"  "${workingFolderPath}"
    Pause  "Next: Check opening the working folder."

    ../codediff  ${TestOption}
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "a2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    Pause  "OK? Close Visual Studio Code"
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
    Pause  "OK? Close Visual Studio Code"
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
    Pause  "OK? Close Visual Studio Code"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git sub 1" ]; then  TestError  "3"  ;fi
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
}

function  TestOfDelete() {
    echo  ""
    echo  "TestOfDelete =================================="
    local  workingFolderPath="$HOME/_tmp/_diff/1"
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"

    CopyIniFileTemplate  "files/4_delete_codediff.ini"  "${workingFolderPath}"
    Pause  "Next: Check opening the working folder."

    ../codediff  ${TestOption}
    if [ "$( cat "${workingFolderPath}/working/d.txt" )" != "d2" ]; then  TestError  "2"  ;fi
    AssertNotExist  "${workingFolderPath}/working/dd.txt"
    AssertNotExist  "${workingFolderPath}/working/sub_d"
    Pause  "OK? Close Visual Studio Code"
    ChangeToOldCommit
    AssertNotExist  "${workingFolderPath}/working/sub1"
    AssertNotExist  "${workingFolderPath}/working/d.txt"
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
}

function  TestInText() {
    echo  ""
    echo  "TestInText =================================="
    local  workingFolderPath="$HOME/_tmp/_diff/1"
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
    mkdir -p  "${workingFolderPath}"

    echo  "old setting"  >  "${workingFolderPath}/.codediff.ini"

    ../codediff  ${TestOption}  "files/5_codediff_in_text.yaml"
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "a2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "a1" ]; then  TestError  "3"  ;fi
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
}

function  TestCopyFolder() {
    echo  ""
    echo  "TestCopyFolder =================================="
    MakeCopySource  "_work/source"

    CopyFolder  "_work/source"  "_work/destination"
    pushd  "_work/destination"  >  /dev/null
    local  result="$( find . | sort )"
    popd  >  /dev/null
local  answer=\
".
./a.txt
./build
./build/_do_not_copy
./empty
./empty/s
./sub1
./sub1/s
./sub1/s/a.txt
./sub2
./sub2/s
./sub2/s/a.txt
./sub2/s/build
./sub2/s/build/_do_not_copy"
    test  "${result}" == "${answer}"  ||  Error
    rm -rf  "_work/destination"

    CopyFolder  "_work/source"  "_work/destination"  --exclude build  --exclude sub2/s/build  --exclude empty/s
    pushd  "_work/destination"  >  /dev/null
    local  result="$( find . | sort )"
    popd  >  /dev/null
local  answer=\
".
./a.txt
./empty
./sub1
./sub1/s
./sub1/s/a.txt
./sub2
./sub2/s
./sub2/s/a.txt"
    test  "${result}" == "${answer}"  ||  Error
    rm -rf  "_work/destination"

    CopyFolder  "_work/source"  "_work/destination"  --exclude ./sub2  --exclude ./sub2/s/build  --exclude ./empty/s
    test  "${result}" == "${answer}"  ||  Error
    rm -rf  "_work"
}

function  TestConflictCheck() {
    echo  ""
    echo  "TestConflictCheck =================================="
    local  lf=$'\n'

    #// Conflict in repository
    ../codediff  ${TestOption}  "https://github.com/Takakiriy/codediff"  --merge "example_1, example_2"  --check
    local  exitCode=$?
    test  ${exitCode} == 1  ||  Error

    #// Not conflict in repository
    ../codediff  ${TestOption}  "https://github.com/Takakiriy/codediff"  --merge "example_1, example_1"  --check
    local  exitCode=$?
    test  ${exitCode} == 0  ||  Error

    #// Conflict in local
    GitInitForTest  "./_work"
    GitAddCommitForTest  "./_work"  "main"  "main"       "Make commit base"  "aaa${lf}bbb${lf}ccc${lf}ddd${lf}eee"
    GitAddCommitForTest  "./_work"  "main"  "feature_1"  "feature-1 commit"  "aaa${lf}BBBBB${lf}ccc${lf}ddd${lf}eee"
    GitAddCommitForTest  "./_work"  "main"  "feature_2"  "feature-2 commit"  "aaa${lf}B--BB${lf}ccc${lf}ddd${lf}eee"

    ../codediff  ${TestOption}  "./_work"  --merge "feature_1, feature_2"  --check  &&  Error
    ../codediff  ${TestOption}  "./_work"  --merge "feature_1, feature_1"  --check  ||  Error
    ../codediff  ${TestOption}  "./_work"  --merge "feature_1"             --check  ||  Error
    ../codediff  ${TestOption}  "./_work"  --merge "main, feature_1, feature_2"  --check  &&  Error
    ../codediff  ${TestOption}  "./_work"  --merge "main, feature_2"             --check  ||  Error

    rm -rf  "./_work"
}

function  GitInitForTest() {
    local  gitWorkingPath="$1"
    rm -rf    "${gitWorkingPath}"
    mkdir -p  "${gitWorkingPath}"
    pushd  "${gitWorkingPath}"  > /dev/null

    echo  "$ git init"
    git init -b "main"  ||  Error
    git config --local user.email "yourname@example.com"  ||  Error
    git config --local user.name  "Your Name"  ||  Error
    echo "" > "README"
    git add "."  ||  Error
    git commit -m "first commit"  ||  Error
    popd  > /dev/null
}

function  GitAddCommitForTest() {
    local  gitWorkingPath="$1"
    local  baseBranch="$2"
    local  commitBranch="$3"
    local  commitMessage="$4"
    local  text="$5"
    pushd  "${gitWorkingPath}"  > /dev/null

    AssertExist  "./.git"

    echo  "$ git checkout  \"${commitBranch}\""
    if [ "${baseBranch}" != "" ] && [ "${baseBranch}" != "${commitBranch}" ]; then
        git checkout  "${baseBranch}"  ||  Error
        git checkout -b "${commitBranch}"  ||  Error
    else
        git checkout  "${commitBranch}"  ||  Error
    fi

    echo  "$ echo .... > \"a.txt\""
    echo  "${text}"  >  "a.txt"
    echo  "$ git add \".\""
    git add "."  ||  Error
    echo  "$ git commit -m \"${commitMessage}\""
    git commit -m "${commitMessage}"  ||  Error
    popd  > /dev/null
}

function  AssertExist() {
    local  path="$1"
    if [ ! -e "${path}" ]; then
        Error  "ERROR: Not found \"${path}\""
    fi
}

function  TestSame() {
    echo  ""
    echo  "TestSame =================================="
    local  workingFolderPath="$HOME/_tmp/_diff/1"
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
    rm -rf  "files/__repository_1"
    mkdir -p  "${workingFolderPath}"
    cp -ap  "files/repository_1"  "files/__repository_1"

    ../codediff  ${TestOption}  "files/repository_1"  "files/__repository_1"  ||  Error
    rm -rf  "$HOME/_tmp/_diff"
    rm -f  "_codediff.log"
    rm -rf  "files/__repository_1"
}

function  MakeCopySource() {
    local  source="$1"
    test  "${source}" == "_work/source"  ||  Error
    rm -rf  "_work"
    mkdir   "_work"
    cp -Rap  "files/copy_test"  "_work/source"
    rm  "_work/source/empty/s/_delete_me"
}

function  CopyIniFileTemplate() {
    local  templatePath="$1"
    local  workingFolderPath="$2"
    mkdir -p  "${workingFolderPath}"

    cat  "${templatePath}"  |  sed -E "s|__Project__|${ProjectPath}|"  > "${workingFolderPath}/.codediff.ini"
}

function  ChangeToOldCommit() {
    pushd  "${workingFolderPath}/working"  > /dev/null  ||  Error

    git reset --hard  > /dev/null  2>&1
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

#// CopyFolder
#//     Copy of this function in codediff
function  CopyFolder() {
    local  source="$1"
    local  destination="$2"

    local  excludePaths=( )
    while true; do
        local  option="$3"
        if [ "${option}" == "" ]; then
            break
        fi
        if [ "${option}" == "--exclude" ]; then
            excludePaths+=("$4")
            shift  2
        elif [ "${option:0:10}" == "--exclude=" ]; then
            excludePaths+=("${option:10}")
            shift
        else
            Error  "Not supported option: ${ignoreDotGit}"
        fi
    done

    source="$( CutLastOf  "${source}"  "/" )"
    destination="$( CutLastOf  "${destination}"  "/" )"

    mkdir -p  "${destination}/"
    if [ "${#excludePaths[@]}" == 0 ]; then
        ls -a "${source}" | grep -v  -e "^\.$"  -e "^\.\.$" | xargs  -I {} \
            cp -Rap  "${source}/{}"  "${destination}/"
    else
        local  sourceEscaped="$( echo "${source}" | sed -E 's/([$^.*+?\(\){}\|[])/\\\1/g' | sed -E 's/]/\\]/g' )"
        local  sourceFilePathText="$( find "${source}" -type f  |  sort )"
        local  sourceEmptyFolderPathText="$( ScanEmptyFolderPaths  "${source}"  "${sourceFilePathText}" )"
        local  filePathText="$( echo "${sourceFilePathText}"  |  sed -E "s|^${sourceEscaped}|.|" )"
        local  emptyFolderPathText="$( echo "${sourceEmptyFolderPathText}"  |  sed -E "s|^${sourceEscaped}|.|" )"
        local  excludePath=""
        for excludePath in "${excludePaths[@]}"; do
            if [ "${excludePath:0:2}" != "./" ]; then
                excludePath="./${excludePath}"
            fi
            local  excludePathEscaped="$( echo "${excludePath}" | sed -E 's/([$^.*+?\(\){}\|[])/\\\1/g' | sed -E 's/]/\\]/g' )"

            filePathText="$( echo "${filePathText}"  |  grep -vE "^${excludePathEscaped}" )"
            emptyFolderPathText="$( echo "${emptyFolderPathText}"  |  grep -vE "^${excludePathEscaped}" )"
        done
        local  fileFolderPathText="$( echo "${filePathText}"  |  sed -E 's|/[^/]*$||'  |  uniq )"

        echo  "${emptyFolderPathText}"  |  xargs  -I {} \
            mkdir -p  "${destination}/{}"
        echo  "${fileFolderPathText}"  |  xargs  -I {} \
            mkdir -p  "${destination}/{}"
        echo  "${filePathText}"  |  xargs  -I {} \
            cp -Rap  "${source}/{}"  "${destination}/{}"
    fi
}

function  ScanEmptyFolderPaths() {
    local  basePath="$1"
    local  scanedFilePaths="$2"

    local  folderPaths="$( find "${basePath}" -type d  |  sort  |  sed -E "s|$|:|"  |  sed -E "s|^|:|" )"
    local  fileFolderPaths="$( echo "${scanedFilePaths}"  |  sed -E 's|/[^/]*$|:|'  |  sed -E "s|^|:|"  |  uniq )"
    local  emptyFolderPaths="$( grep -vFf <(echo "${fileFolderPaths}")  <(echo "${folderPaths}")  | \
        sed -E 's/:$//'  |  sed -E 's/^://' )"

    echo  "${emptyFolderPaths}"
}

function  CutLastOf() {
    local  wholeString="$1"
    local  lastExpected="$2"

    if [ "${wholeString:${#wholeString}-${#lastExpected}:${#lastExpected}}" == "${lastExpected}" ]; then
        echo  "${wholeString:0:${#wholeString}-${#lastExpected}}"
    else
        echo  "${wholeString}"
    fi
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

    PrintCallStack

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

function  pp() {
    # pp
    #     Debug print
    # Example:
    #     pp "$config"
    #     pp "$config" config
    #     pp "$array" array  ${#array[@]}  "${array[@]}"
    #     pp "123"
    #     $( pp "$config" >&2 )
    local  value="${1-""}"  #// "${1-""}" means that "$1" default is "".
    local  variableName="${2-""}"  #// "${1-""}" means that "$1" default is "".
    if [ "${variableName}" != "" ]; then  variableName=" ${variableName} "  ;fi  #// Add spaces
    local  oldIFS="$IFS"
    IFS=$'\n'
    local  valueLines=( ${value} )
    IFS="$oldIFS"

    local  type=""
    if [ "${variableName}" != "" ]; then
        if [[ "$(declare -p ${variableName} 2>&1 )" =~ "declare -a" ]]; then
            local  type="array"
        fi
    fi
    if [ "${type}" == "" ]; then
        if [ "${#valueLines[@]}" == 1  -o  "${#valueLines[@]}" == 0 ]; then
            local  type="oneLine"
        else
            local  type="multiLine"
        fi
    fi

    if [[ "${type}" == "oneLine" ]]; then
        echo  "@@@${variableName}= \"${value}\" -------- $( GetCodePosition 1 ) ---------------------------"  >&2
    elif [[ "${type}" == "multiLine" ]]; then
        echo  "@@@${variableName} -------- $( GetCodePosition 1 ) ---------------------------"  >&2
        echo  "\"${value}\"" >&2
    elif [[ "${type}" == "array" ]]; then
        echo  "@@@${variableName} -------- $( GetCodePosition 1 ) ---------------------------"  >&2
        local  count="${3-""}"  #// "${1-""}" means that "$1" default is "".
        if [ "${count}" == "" ]; then
            echo  "[0]: \"$4\""  >&2
            echo  "[1]: ERROR: pp parameter is too few"  >&2
        elif [ "${count}" == "0" ]; then
            echo  "[]"  >&2
        else
            local  i=""
            for (( i = 0; i < ${count}; i += 1 ));do
                echo  "[${i}]: \"$4\""  >&2
                shift
            done
        fi
    else
        echo  "@@@${variableName}? -------- $( GetCodePosition 1 ) ---------------------------"  >&2
    fi
}

function  GetCodePosition() {
    local  parent="${1-"0"}"  #// "${1-"0"}" means that "$1" default is "0".
    local  frame=( $( caller "${parent}" ) )
    local  fileName="${frame[2]}"
    local  lineNum="${frame[0]}"
    echo  "${fileName}:${lineNum}"
}

function  PrintCallStack() {
    echo  "Call stack:"  >&2
    local  index=0
    local  frame
    while frame=( $( caller "${index}" ) ); do
        local  functionName="${frame[1]}"
        local  fileName="${frame[2]}"
        local  lineNum="${frame[0]}"
        echo  "    ${functionName} (${fileName}:${lineNum})"  >&2
        (( index += 1 ))  ||  true
    done
}

True=0
False=1
if [ "${Options_ManualTest}" != "" ]; then
    TestOption=""
else
    TestOption=" --test"
fi

Main
