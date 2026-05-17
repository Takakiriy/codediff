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
    ModifyGlobalVariables

    TestParameters
    TestLocal
    # TestLocalBranch
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
    local  workingFolderPath="${HOME2}/_tmp/_diff/1"

    rm -rf  "${HOME2}/_tmp/_diff"
    rm -f  "_codediff.log"
    Pause  "Next: Check opening a Visual Studio Code and select Source Control view (git)."

    ../codediff  ${TestOption}  "files/repository_1"  "files/repository_2"  ||  Error
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "a2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    Pause  "OK? Close Visual Studio Code"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "a1" ]; then  TestError  "3"  ;fi

    ../codediff  ${TestOption}  \
        "https://github.com/Takakiriy/codediff#example_1"  \
        "https://github.com/Takakiriy/codediff#example_2"  ||  Error
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git a2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    test  "$( cat "_codediff.log" )" == "OpenIDE \"${HOME}/_tmp/_diff/1/working\""  ||  Error
    Pause  "OK? Close Visual Studio Code"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git a1" ]; then  TestError  "3"  ;fi
    rm -rf  "${HOME2}/_tmp/_diff"
    rm -f  "_codediff.log"
}

function  TestLocalBranch() {
    echo  ""
    echo  "TestLocalBranch =================================="

    #// Set up local repository
    rm -rf  "${ProjectPath}/test/_repository.git"

    git init --bare --shared=true  "${ProjectPath}/test/_repository.git"
    rm -rf  "${ProjectPath}/test/_work"
    mkdir   "${ProjectPath}/test/_work"
    cd      "${ProjectPath}/test/_work"
    echo  "aaa" > "a.txt"
    git init
    git add  "."
    git commit -m "First commit"
    git remote add origin  file://${ProjectPath}/test/_repository.git

    git push --set-upstream origin master
    git checkout -b  feature
    echo  "fff" > "a.txt"
    git add  "."
    git commit -m "Feature commit"

    git push --set-upstream origin feature
Error  "not implemented"
}

function  TestLocal() {
    echo  ""
    echo  "TestLocal =================================="
    local  workingFolderPath="${HOME2}/_tmp/_diff/1"

    #// 1st command
    rm -rf  "${HOME2}/_tmp/_diff"
    rm -f  "_codediff.log"
    Pause  "Next: Check opening a folder that contains .codediff.ini file."

    ../codediff  ${TestOption}
    if [ "$( cat "${workingFolderPath}/.codediff.ini" )" != "$( cat "../codediff_template.ini" )" ]; then  TestError  "1"  ;fi
    AssertNotExist  "${workingFolderPath}/working"
    Pause  "OK? Close Visual Studio Code"

    #// 2nd command
    CopyIniFileTemplate  "files/1_codediff.ini"  "${workingFolderPath}"
    Pause  "Next: Check opening the working folder."

    ../codediff  ${TestOption}  ||  Error
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "a2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    Pause  "OK? Close Visual Studio Code"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "a1" ]; then  TestError  "3"  ;fi
    rm -rf  "${HOME2}/_tmp/_diff"
    rm -f  "_codediff.log"
}

function  TestGitRepository() {
    echo  ""
    echo  "TestGitRepository =================================="
    local  workingFolderPath="${HOME2}/_tmp/_diff/1"
    rm -rf  "${HOME2}/_tmp/_diff"
    rm -f  "_codediff.log"

    CopyIniFileTemplate  "files/2_repository_codediff.ini"  "${workingFolderPath}"
    Pause  "Next: Check opening the working folder."

    ../codediff  ${TestOption}  ||  Error
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git a2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    Pause  "OK? Close Visual Studio Code"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git a1" ]; then  TestError  "3"  ;fi
    rm -rf  "${HOME2}/_tmp/_diff"
    rm -f  "_codediff.log"
}

function  TestGitRepositorySubFolder() {
    echo  ""
    echo  "TestGitRepositorySubFolder =================================="
    local  workingFolderPath="${HOME2}/_tmp/_diff/1"
    rm -rf  "${HOME2}/_tmp/_diff"
    rm -f  "_codediff.log"

    CopyIniFileTemplate  "files/3_sub_folder_codediff.ini"  "${workingFolderPath}"
    Pause  "Next: Check opening the working folder."

    ../codediff  ${TestOption}  ||  Error
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git sub 2" ]; then  TestError  "2"  ;fi
    AssertReadOnly  "${workingFolderPath}/working/a.txt"
    Pause  "OK? Close Visual Studio Code"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git sub 1" ]; then  TestError  "3"  ;fi
    rm -rf  "${HOME2}/_tmp/_diff"
    rm -f  "_codediff.log"
}

function  TestOfDelete() {
    echo  ""
    echo  "TestOfDelete =================================="
    local  workingFolderPath="${HOME2}/_tmp/_diff/1"
    rm -rf  "${HOME2}/_tmp/_diff"
    rm -f  "_codediff.log"

    CopyIniFileTemplate  "files/4_delete_codediff.ini"  "${workingFolderPath}"
    Pause  "Next: Check opening the working folder."

    ../codediff  ${TestOption}  ||  Error
    if [ "$( cat "${workingFolderPath}/working/d.txt" )" != "d2" ]; then  TestError  "2"  ;fi
    AssertNotExist  "${workingFolderPath}/working/dd.txt"
    AssertNotExist  "${workingFolderPath}/working/sub_d"
    Pause  "OK? Close Visual Studio Code"
    ChangeToOldCommit
    AssertNotExist  "${workingFolderPath}/working/sub1"
    AssertNotExist  "${workingFolderPath}/working/d.txt"
    rm -rf  "${HOME2}/_tmp/_diff"
    rm -f  "_codediff.log"
}

function  TestInText() {
    for iCase in {1..2}; do
        echo  ""
        echo  "TestInText ${iCase} =================================="
        local  workingFolderPath="${HOME2}/_tmp/_diff/1"
        rm -rf  "${HOME2}/_tmp/_diff"
        rm -f  "_codediff.log"
        mkdir -p  "${workingFolderPath}"

        echo  "old setting"  >  "${workingFolderPath}/.codediff.ini"
        if [ "${iCase}" == 1 ]; then

            ../codediff  ${TestOption}  "files/5_codediff_in_text.yaml"  ||  Error
        elif [ "${iCase}" == 2 ]; then
            pushd  "files" > /dev/null  ||  Error
            ../../codediff  ${TestOption}  "5_codediff_in_text.yaml"  ||  Error
            rm -f  "_codediff.log"
            popd > /dev/null  ||  Error
        fi
        test  "$( cat "${workingFolderPath}/working/a.txt" )" == "a2"  ||  TestError  "2"
        AssertReadOnly  "${workingFolderPath}/working/a.txt"
        ChangeToOldCommit
        test  "$( cat "${workingFolderPath}/working/a.txt" )" == "a1"  ||  TestError  "3"
        rm -rf  "${HOME2}/_tmp/_diff"
        rm -f  "_codediff.log"
    done
}

function  TestCopyFolder() {
    echo  ""
    echo  "TestCopyFolder =================================="
    MakeCopySource  "_work/source"

    CopyFolder  "_work/source"  "_work/destination"
    pushd  "_work/destination"  >  /dev/null
    local  result="$( find "." | sort )"
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
    local  result="$( find "." | sort )"
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

function  gitInitOption() {
    if [ "$( LessThanVersion "$(git --version  |  awk  '{print $NF}' )" "2.31.1" )" == "${True}" ]; then
        echo  ""
    else
        echo  "-bmain"  #// "-b main" occurs an error in bash debug
    fi
}

function  LessThanVersion() {
    # Example:
    #     if [ "$( LessThanVersion "$(git --version  |  awk  '{print $NF}' )" "2.31.1")" == "${True}" ]; then
    local  textContainsVersionA="$1"
    local  textContainsVersionB="$2"
    local  isGoodFormat="true"
    echo "${textContainsVersionA}" | grep -E '[0-9]+.[0-9]+.[0-9]+' > /dev/null  ||  isGoodFormat="false"
    echo "${textContainsVersionB}" | grep -E '[0-9]+.[0-9]+.[0-9]+' > /dev/null  ||  isGoodFormat="false"
    if [ "${isGoodFormat}" == "false" ]; then
        Error  "\"${textContainsVersionA}\" or \"${textContainsVersionB}\" is not semantic version."
    fi

    local  numbersA=( $( echo "${textContainsVersionA}" | grep -o -e "[0-9]\+" ) )
    local  numbersB=( $( echo "${textContainsVersionB}" | grep -o -e "[0-9]\+" ) )
    if [ "${numbersA[0]}" -lt "${numbersB[0]}" ]; then
        echo "${True}"
        return
    elif [ "${numbersA[0]}" == "${numbersB[0]}" ]; then
        if [ "${numbersA[1]}" -lt "${numbersB[1]}" ]; then
            echo "${True}"
            return
        elif [ "${numbersA[1]}" == "${numbersB[1]}" ]; then
            if [ "${numbersA[2]}" -lt "${numbersB[2]}" ]; then
                echo "${True}"
                return
            fi
        fi
    fi
    echo "${False}"
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

function  ModifyGlobalVariables() {

    #// Set default values. "! -v" means that variable is not defined.
    if ! [[ -v http_proxy ]]; then  http_proxy=""  ;fi
    if ! [[ -v https_proxy ]]; then  https_proxy=""  ;fi
    if ! [[ -v no_proxy ]]; then  no_proxy=""  ;fi
    if ! [[ -v HTTP_PROXY ]]; then  __VariHTTP_PROXYableName__=""  ;fi
    if ! [[ -v HTTPS_PROXY ]]; then  HTTPS_PROXY=""  ;fi
    if ! [[ -v NO_PROXY ]]; then  NO_PROXY=""  ;fi
    echo  "http_proxy = ${http_proxy}"
    echo  "https_proxy = ${https_proxy}"
    echo  "no_proxy = '${no_proxy}'"
    echo  "HTTP_PROXY = ${HTTP_PROXY}"
    echo  "HTTPS_PROXY = ${HTTPS_PROXY}"
    echo  "NO_PROXY = '${NO_PROXY}'"

    #// USER, USERNAME, HOME, USERPROFILE, ProgramFiles = ...
    if [ -e "/c/Windows" ]; then  #// if Windows Git bash
        ScriptEnvironment="Windows"
        export USER="${USERNAME}"
        export USERPROFILE="${HOME}"
        export HOME2="${USERPROFILE}"
        export ProgramFiles="/c/Program Files"
    elif [  -e "/mnt/c/" ] && [ "${PWD:0:7}" == "/mnt/c/" ]; then  #// if Linux on WSL2
        ScriptEnvironment="Linux"
        if ! [[ -v USERNAME ]]; then  #// If USERNAME was not defined in parent script  #// "! -v" means that variable is not defined.
            export USERNAME="$( /mnt/c/WINDOWS/system32/cmd.exe /c 'echo %USERNAME%'  2> /dev/null )"
            export USERNAME="${USERNAME:0:${#USERNAME}-1}"  #// Cut last CR
        fi
        export USERPROFILE="/mnt/c/Users/${USERNAME}"
        export HOME2="${USERPROFILE}"
        export ProgramFiles="/mnt/c/Program Files"
    else  #// if Linux
        ScriptEnvironment="Linux"
        export USERNAME="${USER}"
        export USERPROFILE=""
        export HOME2="${HOME}"
        export ProgramFiles=""
    fi
    if [ "${ScriptEnvironment}" == "Linux" ]; then
        if [ "${USER}" == "root" ]; then
            ScriptEnvironment="LinuxRoot"
        else
            ScriptEnvironment="LinuxUser"
        fi
    fi
    if [ "${PWD:0:7}" == "/mnt/c/" ]; then
        WslMnt="/mnt"
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

GitInitOption=$(gitInitOption)

True=0
False=1
if [ "${Options_ManualTest}" != "" ]; then
    TestOption=""
else
    TestOption=" --test"
fi

Main
