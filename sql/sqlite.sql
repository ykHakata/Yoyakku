DROP TABLE admin;

CREATE TABLE admin (                                -- 管理ユーザー
    id          INTEGER PRIMARY KEY AUTOINCREMENT,  -- 管理ユーザーID
    login       TEXT,                               -- ログインID名
    password    TEXT,                               -- ログインパスワード
    status      INTEGER,                            -- ステータス
    create_on   TEXT,                               -- 登録日
    modify_on   TEXT                                -- 修正日
);

INSERT INTO admin
(login,password,create_on)
VALUES
('MRT','MRT','2013-03-29'),
('HEACON','HEACON','2013-03-29'),
('Ai','Ai','2013-03-29'),
('CUBE','CUBE','2013-03-29'),
('PLUM','PLUM','2013-03-29'),
('FREEDOM','FREEDOM','2013-03-29'),
('HEARTSTRINGS','HEARTSTRINGS','2013-03-29'),
('staff','staff','2013-03-29'),
('EYE-GANG','EYE-GANG','2013-03-29'),
('soundtrack','soundtrack','2013-03-29'),
('島村楽器','島村楽器','2013-03-29'),
('YABAN','YABAN','2013-03-29'),
('Bamboo','Bamboo','2013-03-29'),
('Deja-vu','Deja-vu','2013-03-29'),
('Fine','Fine','2013-03-29'),
('T&S','T&S','2013-03-29'),
('VOLT','VOLT','2013-03-29'),
('ナイスビーム','ナイスビーム','2013-03-29'),
('M','M','2013-03-29'),
('BEBOP','BEBOP','2013-03-29'),
('BIGHIT','BIGHIT','2013-03-29'),
('みかさの森','みかさの森','2013-03-29'),
('オクターブ','オクターブ','2013-03-29'),
('ABBEYROAD戸畑','ABBEYROAD戸畑','2013-03-29'),
('ABBEYROAD幸神','ABBEYROAD幸神','2013-03-29'),
('ANDY','ANDY','2013-03-29'),
('GROOVE小倉','GROOVE小倉','2013-03-29'),
('GROOVE若松高須','GROOVE若松高須','2013-03-29'),
('ソウルミーティング','ソウルミーティング','2013-03-29'),
('リングホール','リングホール','2013-03-29'),
('島村楽器','島村楽器','2013-03-29'),
('Caddis','Caddis','2013-03-29'),
('キノコスタジオ','キノコスタジオ','2013-03-29'),
('LOG','LOG','2013-03-29'),
('VOX','VOX','2013-03-29'),
('6117','6117','2013-03-29'),
('OVERLOAD','OVERLOAD','2013-03-29'),
('246KYOTO','246KYOTO','2013-03-29'),
('GEN','GEN','2013-03-29'),
('NORI','NORI','2013-03-29'),
('バックステージ','バックステージ','2013-03-29'),
('しろくま','しろくま','2013-03-29'),
('nook','nook','2013-03-29');

DROP TABLE general;

CREATE TABLE general (                              -- 一般ユーザー
    id          INTEGER PRIMARY KEY AUTOINCREMENT,  -- 一般ユーザーID
    login       TEXT,                               -- ログインID名
    password    TEXT,                               -- ログインパスワード
    status      INTEGER,                            -- ステータス
    create_on   TEXT,                               -- 登録日
    modify_on   TEXT                                -- 修正日
);

INSERT INTO general
(login,password,create_on)
VALUES
('MRT','MRT','2013-03-29'),
('HEACON','HEACON','2013-03-29'),
('Ai','Ai','2013-03-29'),
('CUBE','CUBE','2013-03-29'),
('PLUM','PLUM','2013-03-29'),
('FREEDOM','FREEDOM','2013-03-29'),
('HEARTSTRINGS','HEARTSTRINGS','2013-03-29'),
('staff','staff','2013-03-29'),
('EYE-GANG','EYE-GANG','2013-03-29'),
('soundtrack','soundtrack','2013-03-29'),
('島村楽器','島村楽器','2013-03-29'),
('YABAN','YABAN','2013-03-29'),
('Bamboo','Bamboo','2013-03-29'),
('Deja-vu','Deja-vu','2013-03-29'),
('Fine','Fine','2013-03-29'),
('T&S','T&S','2013-03-29'),
('VOLT','VOLT','2013-03-29'),
('ナイスビーム','ナイスビーム','2013-03-29'),
('M','M','2013-03-29'),
('BEBOP','BEBOP','2013-03-29'),
('BIGHIT','BIGHIT','2013-03-29'),
('みかさの森','みかさの森','2013-03-29'),
('オクターブ','オクターブ','2013-03-29'),
('ABBEYROAD戸畑','ABBEYROAD戸畑','2013-03-29'),
('ABBEYROAD幸神','ABBEYROAD幸神','2013-03-29'),
('ANDY','ANDY','2013-03-29'),
('GROOVE小倉','GROOVE小倉','2013-03-29'),
('GROOVE若松高須','GROOVE若松高須','2013-03-29'),
('ソウルミーティング','ソウルミーティング','2013-03-29'),
('リングホール','リングホール','2013-03-29'),
('島村楽器','島村楽器','2013-03-29'),
('Caddis','Caddis','2013-03-29'),
('キノコスタジオ','キノコスタジオ','2013-03-29'),
('LOG','LOG','2013-03-29'),
('VOX','VOX','2013-03-29'),
('6117','6117','2013-03-29'),
('OVERLOAD','OVERLOAD','2013-03-29'),
('246KYOTO','246KYOTO','2013-03-29'),
('GEN','GEN','2013-03-29'),
('NORI','NORI','2013-03-29'),
('バックステージ','バックステージ','2013-03-29'),
('しろくま','しろくま','2013-03-29'),
('nook','nook','2013-03-29');

DROP TABLE profile;

CREATE TABLE profile (                                  -- 個人情報
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- 個人情報ID
    general_id      INTEGER,                            -- 一般ユーザーID
    admin_id        INTEGER,                            -- 管理ユーザーID
    nick_name       TEXT,                               -- ニックネーム
    full_name       TEXT,                               -- 氏名
    phonetic_name   TEXT,                               -- ふりがな
    tel             TEXT,                               -- 電話番号
    mail            TEXT,                               -- メールアドレス
    status          INTEGER,                            -- ステータス
    create_on       TEXT,                               -- 登録日
    modify_on       TEXT                                -- 修正日
);

INSERT INTO profile
(general_id, admin_id, nick_name, full_name, phonetic_name, tel, mail, status, create_on, modify_on)
VALUES
('1','','いとう伊藤','伊藤博文','いとう ひろぶみ','098-000-0997','foo@gmail.com','1','2015-05-23','2015-05-23'),
('2','','くろだ黒田','黒田清隆','くろだ きよたか','098-000-0997','foo@gmail.com','1','2015-05-23','2015-05-23'),
('','1','やまがた山縣','山縣有朋','やまがた ありとも','098-000-0997','foo@gmail.com','1','2015-05-23','2015-05-23'),
('','2','まつかた松方','松方正義','まつかた まさよし','098-000-0997','foo@gmail.com','1','2015-05-23','2015-05-23'),
('','3','おおくま大隈','大隈重信','おおくま しげのぶ','098-000-0997','foo@gmail.com','1','2015-05-23','2015-05-23');

CREATE TABLE storeinfo (                                    -- 店舗情報
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,  -- 店舗ID
    region_id           INTEGER,                            -- 地域区分ID
    admin_id            INTEGER,                            -- 管理ユーザーID
    name                TEXT,                               -- 店舗名
    icon                TEXT,                               -- 店舗アイコン
    post                TEXT,                               -- 住所郵便
    state               TEXT,                               -- 住所都道府県
    cities              TEXT,                               -- 住所市町村
    addressbelow        TEXT,                               -- 住所以下
    tel                 TEXT,                               -- 電話番号
    mail                TEXT,                               -- メールアドレス
    remarks             TEXT,                               -- 店舗備考欄
    url                 TEXT,                               -- 店舗リンク先
    locationinfor       TEXT,                               -- 地図位置情報
    status              INTEGER,                            -- ステータス
    create_on           TEXT,                               -- 登録日
    modify_on           TEXT                                -- 修正日
);

CREATE TABLE roominfo(                                      -- 部屋情報設定
    id                   INTEGER PRIMARY KEY AUTOINCREMENT, -- 部屋情報ID
    storeinfo_id         INTEGER,                           -- 店舗ID
    name                 TEXT,                              -- 部屋名
    starttime_on         TEXT,                              -- 開始時刻
    endingtime_on        TEXT,                              -- 終了時刻
    rentalunit           INTEGER,                           -- 貸出単位
    time_change          INTEGER,                           -- 開始時間切り替え
    pricescomments       TEXT,                              -- 料金コメント
    privatepermit        INTEGER,                           -- 個人練習許可設定
    privatepeople        INTEGER,                           -- 個人練習許可人数
    privateconditions    INTEGER,                           -- 個人練習許可条件
    bookinglimit         INTEGER,                           -- 予約制限
    cancellimit          INTEGER,                           -- キャンセル制限
    remarks              TEXT,                              -- 備考
    webpublishing        INTEGER,                           -- web公開設定
    webreserve           INTEGER,                           -- web予約受付設定
    status               INTEGER,                           -- ステータス
    create_on            TEXT,                              -- 登録日
    modify_on            TEXT                               -- 修正日
);
