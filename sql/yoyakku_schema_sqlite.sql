DROP TABLE IF EXISTS admin;
CREATE TABLE admin (                                -- 管理ユーザー
    id          INTEGER PRIMARY KEY AUTOINCREMENT,  -- 管理ユーザーID (例: 5)
    login       TEXT,                               -- ログインID名 (例: 'yoyakku@gmail.com')
    password    TEXT,                               -- ログインパスワード (例: 'yoyakku0000')
    status      INTEGER,                            -- ステータス (例: 0: 未承認, 1: 承認済み, 2: 削除)
    create_on   TEXT,                               -- 登録日 (例: '2015-06-06 12:24:12')
    modify_on   TEXT                                -- 修正日 (例: '2015-06-06 12:24:12')
);

DROP TABLE IF EXISTS general;
CREATE TABLE general (                              -- 一般ユーザー
    id          INTEGER PRIMARY KEY AUTOINCREMENT,  -- 一般ユーザーID (例: 5)
    login       TEXT,                               -- ログインID名 (例: 'yoyakku@gmail.com')
    password    TEXT,                               -- ログインパスワード (例: 'yoyakku0000')
    status      INTEGER,                            -- ステータス (例: 0: 未承認, 1: 承認済み, 2: 削除)
    create_on   TEXT,                               -- 登録日 (例: '2015-06-06 12:24:12')
    modify_on   TEXT                                -- 修正日 (例: '2015-06-06 12:24:12')
);

DROP TABLE IF EXISTS profile;
CREATE TABLE profile (                                  -- 個人情報
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- 個人情報ID (例: 5)
    general_id      INTEGER,                            -- 一般ユーザーID (例: 5, admin_id 存在時 null)
    admin_id        INTEGER,                            -- 管理ユーザーID (例: 5, general_id 存在時 null)
    nick_name       TEXT,                               -- ニックネーム (例: 'ヨヤック')
    full_name       TEXT,                               -- 氏名 (例: '黒田清隆')
    phonetic_name   TEXT,                               -- ふりがな (例: 'くろだ きよたか')
    tel             TEXT,                               -- 電話番号 (例: '080-3456-4321')
    mail            TEXT,                               -- メールアドレス (例: 'yoyakku@gmail.com')
    status          INTEGER,                            -- ステータス (例: 0: 未承認, 1: 承認済み, 2: 削除)
    create_on       TEXT,                               -- 登録日 (例: '2015-06-06 12:24:12')
    modify_on       TEXT                                -- 修正日 (例: '2015-06-06 12:24:12')
);

DROP TABLE IF EXISTS storeinfo;
CREATE TABLE storeinfo (                                    -- 店舗情報
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,  -- 店舗ID (例: 10, 自動採番)
    region_id           INTEGER,                            -- 地域区分ID (例: 10, 自動採番)
    admin_id            INTEGER,                            -- 管理ユーザーID (例: 10, 自動採番)
    name                TEXT,                               -- 店舗名 (例: ヨヤックスタジオ)
    icon                TEXT,                               -- 店舗アイコン (例: ファイルアップロード)
    post                TEXT,                               -- 住所郵便 (例: 8120041)
    state               TEXT,                               -- 住所都道府県 (例: 福岡県)
    cities              TEXT,                               -- 住所市町村 (例: 福岡市博多区)
    addressbelow        TEXT,                               -- 住所以下 (例: 吉塚4丁目12-9)
    tel                 TEXT,                               -- 電話番号 (例: 080-3456-4321, )
    mail                TEXT,                               -- メールアドレス (例: yoyakku@gmail.com, メールアドレス形式)
    remarks             TEXT,                               -- 店舗備考欄 (例: 駅前の便利な場所にあるスタジオ)
    url                 TEXT,                               -- 店舗リンク先 (例: http://www.yoyakku.com/)
    locationinfor       TEXT,                               -- 地図位置情報 (例: 位置情報のテキスト)
    status              INTEGER,                            -- ステータス (例: 0: web公開, 1: web非公開, 2: 削除)
    create_on           TEXT,                               -- 登録日 (例: 2015-06-06 12:24:12, datetime 形式)
    modify_on           TEXT                                -- 修正日 (例: 2015-06-06 12:24:12, datetime 形式)
);

DROP TABLE IF EXISTS roominfo;
CREATE TABLE roominfo(                                      -- 部屋情報設定
    id                   INTEGER PRIMARY KEY AUTOINCREMENT, -- 部屋情報ID (例: 10, 自動採番)
    storeinfo_id         INTEGER,                           -- 店舗ID (例: 10, 自動採番)
    name                 TEXT,                              -- 部屋名 (例: Aスタ)
    starttime_on         TEXT,                              -- 開始時刻 (例: 6: '6:00', 7: '7:00', ... 29: '29:00')
    endingtime_on        TEXT,                              -- 終了時刻 (例: 7: '7:00', 8: '8:00', ...  30: '30:00')
    rentalunit           INTEGER,                           -- 貸出単位 (例: 1: 1時間, 2: 2時間)
    time_change          INTEGER,                           -- 開始時間切り替え (例: 0: ':00', 1: ':30')
    pricescomments       TEXT,                              -- 料金コメント (例: １時間1,500から)
    privatepermit        INTEGER,                           -- 個人練習許可設定 (例: 0: 許可する, 1: 許可しない)
    privatepeople        INTEGER,                           -- 個人練習許可人数 (例: 1: 1人まで, 2: 2人まで, 3: 3人まで)
    privateconditions    INTEGER,                           -- 個人練習許可条件 (例: 0: 当日予約のみ, 1: １日前より, 2: ２日前より, ... 7: ７日前より, 8: 条件なし, )
    bookinglimit         INTEGER,                           -- 予約制限 (例: 0: 制限なし, 1: １時間前, 2: ２時間前, 3: ３時間前)
    cancellimit          INTEGER,                           -- キャンセル制限 (例: 0: 当日不可, 1: １日前不可, 2: ２日前不可, ... 7: ７日前不可, 8: 制限なし)
    remarks              TEXT,                              -- 備考 (例: 3～4人向け)
    webpublishing        INTEGER,                           -- web公開設定 (例: 0: 公開する, 1: 公開しない)
    webreserve           INTEGER,                           -- web予約受付設定 (例: 0: 今月のみ, 1: １ヶ月先, 2: ２ヶ月先, 3: ３ヶ月先)
    status               INTEGER,                           -- ステータス (例: 0: 利用停止, 1: 利用開始)
    create_on            TEXT,                              -- 登録日 (例: 2015-06-06 12:24:12, datetime 形式)
    modify_on            TEXT                               -- 修正日 (例: 2015-06-06 12:24:12, datetime 形式)
);

DROP TABLE IF EXISTS reserve;
CREATE TABLE reserve(                                   -- 予約履歴
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- 予約ID (例: 10, 自動採番)
    roominfo_id     INTEGER,                            -- 部屋情報ID (例: 10, 自動採番)
    getstarted_on   TEXT,                               -- 利用開始日時
    enduse_on       TEXT,                               -- 利用終了日時
    useform         INTEGER,                            -- 利用形態名
    message         TEXT,                               -- 伝言板
    general_id      INTEGER,                            -- 一般ユーザーID
    admin_id        INTEGER,                            -- 管理ユーザーID
    tel             TEXT,                               -- 電話番号
    status          INTEGER,                            -- ステータス (例: 0: 予約中, 1: キャンセル)
    create_on       TEXT,                               -- 登録日 (例: 2015-06-06 12:24:12, datetime 形式)
    modify_on       TEXT                                -- 修正日 (例: 2015-06-06 12:24:12, datetime 形式)
);

DROP TABLE IF EXISTS acting;
CREATE TABLE acting(                                    -- 代行リスト
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- 代行リストID (例: 5)
    general_id      INTEGER,                            -- 一般ユーザーID (例: 5)
    storeinfo_id    INTEGER,                            -- 店舗ID (例: 5)
    status          INTEGER,                            -- ステータス (例: 0: 無効, 1: 有効)
    create_on       TEXT,                               -- 登録日 (例: '2015-06-06 12:24:12')
    modify_on       TEXT                                -- 修正日 (例: '2015-06-06 12:24:12')
);

DROP TABLE IF EXISTS ads;
CREATE TABLE ads(                                       -- 広告
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- 広告ID (例: 5)
    kind            INTEGER,                            -- 広告種別 (例: 5)
    storeinfo_id    INTEGER,                            -- 店舗ID (例: 5)
    region_id       INTEGER,                            -- 地域区分ID (例: 10000)
    url             TEXT,                               -- 広告リンク先 (例: 'http://www.heacon.com/')
    displaystart_on TEXT,                               -- 表示開始日時 (例: '2013-03-07')
    displayend_on   TEXT,                               -- 表示終了日時 (例: '2013-03-07')
    name            TEXT,                               -- 広告名 (例: 'アニソン好きの集い')
    event_date      TEXT,                               -- イベント広告日時 (例: '2013/3/7 18:00-22:00')
    content         TEXT,                               -- 広告内容 (例: 'とくにエヴァンゲリオン')
    create_on       TEXT,                               -- 登録日 (例: '2015-06-06 12:24:12')
    modify_on       TEXT                                -- 修正日 (例: '2015-06-06 12:24:12')
);

DROP TABLE IF EXISTS region;
CREATE TABLE region(                                -- 地域区分マスタ
    id          INTEGER PRIMARY KEY AUTOINCREMENT,  -- 地域区分ID
    name        TEXT,                               -- 地域区分名
    create_on   TEXT,                               -- 登録日
    modify_on   TEXT                                -- 修正日
);

DROP TABLE IF EXISTS post;
CREATE TABLE post(                      -- 郵便番号マスタ
    post_id     INTEGER  PRIMARY KEY,   -- 郵便番号
    region_id   INTEGER,                -- 地域区分ID
    post_id_old INTEGER,                -- (旧)郵便番号
    state_re    TEXT,                   -- 都道府県名(よみ)
    cities_re   TEXT,                   -- 市区町村名(よみ)
    town_re     TEXT,                   -- 町域名(よみ)
    state       TEXT,                   -- 都道府県名
    cities      TEXT,                   -- 市区町村名
    town        TEXT,                   -- 町域名
    more_info1  INTEGER,                -- 一町域が二以上の郵便番号で表される場合の表示
    more_info2  INTEGER,                -- 小字毎に番地が起番されている町域の表示
    more_info3  INTEGER,                -- 丁目を有する町域の場合の表示
    more_info4  INTEGER,                -- 一つの郵便番号で二以上の町域を表す場合の表示
    more_info5  INTEGER,                -- 更新の表示
    more_info6  INTEGER,                -- 変更理由
    create_on   TEXT,                   -- 登録日
    modify_on   TEXT                    -- 修正日
);
