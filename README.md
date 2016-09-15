# NAME

    Yoyakku - 音楽スタジオ用予約サイト

# URL

サイトアクセス

    http://www.yoyakku.com/

サイトの使い方ご紹介ページ

    http://www.yoyakku.com/tutorial

スーパーユーザー用ログイン

    http://www.yoyakku.com/root_login

スマホに特化した予約確認画面

    http://www.yoyakku.com/simple_res

# HISTORY

    2013-01 作成開始

        技術習得および WEB サービスノウハウ蓄積の課題として開発を開始

        開発当初のコンセプト

        音楽リハーサルスタジオの予約状況を一元管理

        スタジオ空き時間を素早く直感的に検索、予約
        スタジオ空き時間を他のスタジオ店舗と容易に比較
        地域ごとに絞り込んで検索
        レンタル料金の比較も容易

        スマートフォンでもしっかり動作する
        将来的には音楽リハーサルスタジオ以外にも対応

        開発当初は KAYAK というホテル予約サイトを参考にした
        https://www.kayak.co.jp/

    2013-05 WEB サーバーでの公開開始
    2013-06 音楽スタジオへの PR 活動、要望の調査
    2013-07 開発の中断
    2013-09 実装方法に問題があり機能拡張が困難なため再実装を試みるが断念

    2015-05 Github を活用しての再実装を開始

# DEPLOYMENT

# LOCAL

アプリケーションスタート

```bash
# WEBフレームワークを起動 (development モード)
$ carton exec -- morbo script/yoyakku

# WEBフレームワークを起動 (testing モード)
$ carton exec -- morbo --mode testing script/yoyakku
```

テストコードを実行

```bash
# テストコードを実行すると自動的にデータベースが初期化、通常は testing で実行
$ carton exec -- script/yoyakku test --mode testing

# テスト結果を詳細に出力
$ carton exec -- script/yoyakku test -v --mode testing

# テスト結果を詳細かつ個別に出力
$ carton exec -- script/yoyakku test -v --mode testing t/yoyakku.t
```

データベースの初期化

```bash
# 開発環境用データーベース (db/yoyakku.db が初期化)
$ carton exec -- script/yoyakku init_db

# テスト環境用データーベース (db/yoyakku_test.db が初期化)
$ carton exec -- script/yoyakku init_db --mode testing
```

シンタックスチェック

```bash
# コマンドを実行するディレクトリに注意
$ pwd
/Users/yk/Github/Yoyakku/lib

$ carton exec -- perl -c ./Yoyakku/Util.pm
./Yoyakku/Util.pm syntax OK
```
