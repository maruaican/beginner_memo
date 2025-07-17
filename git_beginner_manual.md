# Git操作マニュアル（初心者向け）

## 1. 標準的なGit Pushの手順

### 目的

ローカルで行った変更をリモートリポジトリ（GitHubなど）に反映する。

### 前提条件

- リモートリポジトリと接続済み（`git remote -v` で確認）
- ローカルリポジトリ内で作業している（`git status` で確認）

### 基本手順

```bash
# 1. 変更を確認
git status

# 2. ファイルをステージに追加
git add .

# 3. コミット（変更を記録）
git commit -m "変更内容の説明"

# 4. リモートにプッシュ
git push origin main  # ブランチ名が main の場合
```

---

## 2. ローカルをバックアップから上書きしてしまった場合の対処法

### 状況例

ローカルリポジトリのフォルダを手動でバックアップのフォルダで上書きしてしまった。pushしようとしたらエラーになる。

### 代表的なエラー

```
error: failed to push some refs to ...
hint: Updates were rejected because the remote contains work that you do
hint: not have locally.
```

### 対処方法

#### A. リモートを優先したい場合（ローカルを捨ててもよい）

```bash
# リモートの内容でローカルを強制的に上書き（注意！）
git fetch origin
git reset --hard origin/main
```

> **補足**：この操作では、**ローカルの作業内容はすべて失われます**。リモートリポジトリ（origin/main）の状態でローカルが完全に上書きされます。

#### B. ローカルの内容を優先して強制的にpushしたい場合

```bash
# 警告：他の人の作業が消える可能性があるため、チーム作業では非推奨
git push -f origin main
```

---

## 3. git pull したのに "Already up to date." と出るのに内容が違うとき

### よくある原因

| 原因             | 説明                                |
| -------------- | --------------------------------- |
| ブランチが違う        | ローカルが `main`、リモートが `master` などの場合 |
| リモート先が違う       | `origin` のURLが別リポジトリになっている        |
| ローカルにコミット履歴がない | `git init` だけした直後など               |
| そもそもリモートに変更がない | 他の人がpushしていない可能性                  |

### チェック手順

```bash
# 1. 現在のブランチ確認
git branch

# 2. リモートの設定確認
git remote -v

# 3. リモートの最新の状態を取得
git fetch origin

# 4. 差分を確認
git log HEAD..origin/main
```

### 対処法（例）

#### A. ブランチ名が違った場合

```bash
git checkout -b main origin/main
```

#### B. ローカルとリモートを強制的に同期したい場合

```bash
git reset --hard origin/main
```

---

## 4. git restore の活用（ローカル作業のやり直しに便利）

### 目的

ローカルでの作業をやり直したいとき、特にファイルを元に戻したいときに使う。

### 使用例

#### A. 作業途中のファイルを元に戻す

```bash
git restore ファイル名
```

#### B. ステージに追加したファイルを取り消す

```bash
git restore --staged ファイル名
```

### 活用場面

- AIエージェントや自動整形ツールで、意図しない変更が行われたとき
- `git status` で赤や緑の変更があるけど、やっぱりやり直したいとき

---

## 5. 状況別チェックリスト

| チェックポイント | コマンド                   | 正常な例                                |
| -------- | ---------------------- | ----------------------------------- |
| リモート設定   | `git remote -v`        | `origin https://github.com/xxx.git` |
| 現在のブランチ  | `git branch`           | `* main`                            |
| コミット状況   | `git log`              | コミット履歴が表示される                        |
| 差分の確認    | `git diff origin/main` | 差分がある場合のみ内容が表示される                   |

---

## 最後に：初心者へのアドバイス

- リモートリポジトリは **バックアップ** のようなもの。トラブル時も慌てず確認を。
- `git status` や `git log` をこまめに見ること。
- 困ったらまず `fetch` と `diff` で「差分」を見よう。
- 作業前に `git pull` する習慣を！

---

以上がGit初心者向けの操作マニュアルです。

