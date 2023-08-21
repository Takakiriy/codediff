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
    TestParameters
    TestLocal
    # TestLocalBranch
    TestGitRepository
    TestGitRepositorySubFolder
    TestOfDelete
    TestInText
    TestCopyFolder

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
    Pause  "OK? Close Visual Studio Code"
    ChangeToOldCommit
    if [ "$( cat "${workingFolderPath}/working/a.txt" )" != "git a1" ]; then  TestError  "3"  ;fi
    rm -rf  "$HOME/_tmp/_diff"
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
    local  result="$( find .  |  sort )"
    popd  >  /dev/null
local  answer=".
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
    local  result="$( find .  |  sort  )"
    popd  >  /dev/null
local  answer=".
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
    if [ "$( LessThanVersion "$(git --version)" "2.31.1" )" == "${True}" ]; then
        echo  ""
    else
        echo  "-bmain"  #// "-b main" occurs an error in bash debug
    fi
}

# LessThanVersion
#     if [ "$( LessThanVersion "$(git --version)" "2.31.1")" == "${True}" ]; then
function  LessThanVersion() {
    local  textContainsVersionA="$1"
    local  textContainsVersionB="$2"
    local  isGoodFormat="${True}"
    echo "${textContainsVersionA}" | grep -e "[0-9]\+\.[0-9]\+\.[0-9]\+" > /dev/null  ||  isGoodFormat="${False}"
    echo "${textContainsVersionB}" | grep -e "[0-9]\+\.[0-9]\+\.[0-9]\+" > /dev/null  ||  isGoodFormat="${False}"
    if [ "${isGoodFormat}" == "${False}" ]; then
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

# pp
#     Debug print
# Example:
#     pp "$config"
#     pp "$config" config
#     pp "$array" array  ${#array[@]}  "${array[@]}"
#     pp "123"
#     $( pp "$config" >&2 )
function  pp() {
    local  value="$1"
    local  variableName="$2"
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
        echo  "@@@${variableName}= \"${value}\" ---------------------------"  >&2
    elif [[ "${type}" == "multiLine" ]]; then
        echo  "@@@${variableName}---------------------------"  >&2
        echo  "\"${value}\"" >&2
    elif [[ "${type}" == "array" ]]; then
        echo  "@@@${variableName}---------------------------"  >&2
        local  count="$3"
        if [ "${count}" == "" ]; then
            echo  "[0]: \"$4\""  >&2
            echo  "[1]: ERROR: pp parameter is too few"  >&2
        else
            local  i=""
            for (( i = 0; i < ${count}; i += 1 ));do
                echo  "[$i]: \"$4\""  >&2
                shift
            done
        fi
    else
        echo  "@@@${variableName}? ---------------------------"  >&2
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

GitInitOption=$(gitInitOption)
True=0
False=1
if [ "${Options_ManualTest}" != "" ]; then
    TestOption=""
else
    TestOption=" --test"
fi

Main
