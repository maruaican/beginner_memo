@echo off
REM 複数のWordファイル（.docx）をMarkdown（.md）に変換するバッチ
REM 前提：pandocがインストールされていること
REM pandoc公式サイト　https://pandoc.org/installing.html
REM pandoc-3.7.0.2-windows-x86_64.msiをダウンロードしてインストール
REM バッチファイルの形式はANSI（Shift_JIS）が無難。UTF-8だと、余計な空白やバックスラッシュが入って動かない可能性がある。

REM このバッチファイルに変換したい.docxファイルをドラッグ＆ドロップして使用してください

for %%f in (%*) do (
    pandoc "%%f" -f docx -t gfm --wrap=preserve -o "%%~dpnf.md"
)

pause
