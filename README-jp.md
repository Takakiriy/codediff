# codediff

フォルダーまたは Git リポジトリの差分を
Git のコミットの差分として Visual Studio Code で表示します。

![スクショ](./codediff.png)

## コマンドのサンプル

    codediff  #// ~/_tmp/_diff/1 フォルダーが無い場合
        #// ~/_tmp/_diff/1 に Git ワーキング フォルダー を作ります
        #// 設定ファイル .codediff.ini が作られます
        #// Visual Studio Code が開きます
        #// 設定ファイル .codediff.ini を編集します
    codediff  #// ~/_tmp/_diff/1 フォルダーがある場合
        #// ローカルに .git フォルダーを作り、差分のコミットを作ります
        #// Visual Studio Code が開きます
        #// Source Control ビューに切り替えて、差分を確認します

## 設定ファイル

サンプル：

    # codediff command setting file

    [New]
    LocalFullPath = /home/user1/project1
    DeleteRelativePath = _base

    [Old]
    RepositoryURL = https://github.com/Takakiriy/example1
    BranchOrTag = develop

下記の書式の設定を 2つ並べます。

ローカルの他のフォルダーからコピーする場合：

    [__CommitMessage__]
    LocalFullPath = ____
    DeleteRelativePath = ____
    DeleteRelativePath = ____
        ...
    
Git リポジトリ からダウンロードする場合：

    [__CommitMessage__]
    RepositoryURL = ____
    BranchOrTag = ____
    BaseRelativePath = ____
    DeleteRelativePath = ____
    DeleteRelativePath = ____
        ...

`DeleteRelativePath` は全てのセクションに書く必要はありません。

## テスト

    cd  test
    ./test_codediff.sh
    ./test_codediff.sh --manual-test
