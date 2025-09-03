はい、ご指摘のとおり、全部で20の表題を作成しております。
内訳は以下の通りです。

1.  **令和6年秋期**
2.  **令和6年春期**
3.  **令和5年秋期**
4.  **令和5年春期**
5.  **令和4年秋期**
6.  **令和4年春期**
7.  **令和3年秋期**
8.  **令和3年春期**
9.  **令和2年秋期**
10. **令和元年秋期**
11. **平成31年春期**
12. **平成30年秋期**
13. **平成30年春期**
14. **平成29年秋期**
15. **平成29年春期**
16. **平成28年秋期**
17. **平成28年春期**
18. **平成27年秋期**
19. **平成27年春期**
20. **平成26年秋期**

最後の「平成26年秋期」については、ご指示どおりSQLの設問がなかった旨を記載いたしました。







承知いたしました。
応用情報技術者試験の午後問題（データベース分野）20問から、SQL文を抽出・整理しました。

***

## 令和6年秋期 午後 データベース

*   **設問の概要：** トレーディングカードの個人売買サイトの構築
*   **SQLの目的：** 指定されたカテゴリIDとその配下にあるすべてのサブカテゴリIDを取得し、それらのカテゴリに属する商品を検索条件に基づいて抽出するSQL文。

```sql
WITH RECURSIVE 指定カテゴリ(カテゴリID, カテゴリ名, 上位カテゴリID) AS (
    SELECT A.カテゴリID, A.カテゴリ名, A.上位カテゴリID
    FROM カテゴリ A WHERE A.カテゴリID = :カテゴリID
    【 f 】
    SELECT B.カテゴリID, B.カテゴリ名, B.上位カテゴリID
    FROM カテゴリ B, 指定カテゴリ C WHERE B.上位カテゴリID = C.カテゴリID
)
SELECT * FROM 出品
INNER JOIN 指定カテゴリ
ON 【 g 】
WHERE 出品.出品価格 BETWEEN :下限価格 AND :上限価格
AND 出品.商品状態 = :商品状態
AND 出品.出品状況 = :出品状況
AND (出品.商品名 【 h 】 OR 出品.商品説明 【 h 】)
```

***

## 令和6年春期 午後 データベース

*   **設問の概要：** 人事評価システムの設計と実装
*   **SQLの目的：**
    *   図2：国民の祝日と会社の記念日を一覧表示するSQL文。
    *   図3：指定された管理者が評価する対象の従業員一覧を、部署名と従業員氏名でソートして出力するSQL文。
    *   図4：国民の祝日ビューを作成するSQL文。

```sql
-- 図2 国民の祝日と会社記念日の一覧を日付の昇順に出力するSQL文
SELECT 祝日 AS 日付, 祝日名 AS 日付名
FROM 国民の祝日
WHERE 祝日 【 b 】
UNION ALL
SELECT 会社記念日 AS 日付, 会社記念日名 AS 日付名
FROM 会社記念日
WHERE 会社番号 = :会社番号
AND 会社記念日 【 b 】
【 c 】
```

```sql
-- 図3 従業員の一覧を部署番号、従業員番号の昇順に出力するSQL文
SELECT DEP.部署番号, DEP.部署名, EMP.従業員番号, EMP.従業員氏名
FROM 従業員 EMP INNER JOIN 部署 DEP
ON EMP.会社番号 = DEP.会社番号
【 d 】
AND EMP.会社番号 = :会社番号
AND DEP.管理者番号 = :管理者番号
【 c 】
```

```sql
-- 図4 国民の祝日ビューを作成するSQL文
CREATE VIEW 【 e 】 (祝日, 祝日名)
AS SELECT 祝日, 祝日名
FROM 【 f 】
```

***

## 令和5年秋期 午後 データベース

*   **設問の概要：** 在庫管理システム
*   **SQLの目的：** ウィンドウ関数を使用し、倉庫コード・商品コードごとに、各年月日の6日前から当日までの平均在庫数と売上個数を集計するSQL文。

```sql
SELECT 年, 月, 日, 倉庫コード, 商品コード,
       AVG(在庫数) OVER (【 i 】) AS 平均在庫数,
       SUM(売上個数) OVER (【 i 】) AS 期間内売上個数
FROM 在庫推移状況
WINDOW 期間定義 AS (
    PARTITION BY 倉庫コード, 商品コード
    ORDER BY 年, 月, 日 ASC
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    【 j 】
)
```

***

## 令和5年春期 午後 データベース

*   **設問の概要：** KPI達成状況集計システムの開発
*   **SQLの目的：** 複数のテーブルからデータを集計し、4つの集計リストテーブル（所属_役職_一時、月別個人目標_一時、日別個人実績_一時、項番1~3の出力表）にデータを挿入する一連のSQL文。

```sql
-- 項番1
INSERT INTO 所属_役職_一時(従業員コード, 組織コード)
SELECT A.従業員コード, A.所属組織コード FROM 所属 A, 役職 B
WHERE TO_DATE(:集計年月日) 【 e 】 A.所属開始年月日 AND A.所属終了年月日
AND A.役職コード = B.役職コード AND 【 f 】

-- 項番2
INSERT INTO 月別個人目標_一時(従業員コード, KPIコード, 目標個人集計)
SELECT 【 g 】, KPIコード, 【 g 】 FROM 月別個人目標
WHERE 年月 = 【 g 】年度開始年月日 AND TO_DATE(:集計年月日)

-- 項番3
INSERT INTO 日別個人実績_一時(従業員コード, KPIコード, 実績個人集計)
SELECT 従業員コード, KPIコード, SUM(日別実績値) FROM 日別個人実績
WHERE 年月日 【 g 】 TO_DATE(:年度開始年月日) AND TO_DATE(:集計年月日)
【 g 】

-- 項番4
INSERT INTO 【 h 】(組織コード, KPIコード, 目標組織集計, 実績組織集計, 対象従業員数)
SELECT A.組織コード, B.KPIコード, SUM(B.目標個人集計),
       SUM(COALESCE(C.実績個人集計, 0)), 【 i 】
FROM 所属_役職_一時 A
【 i 】 従業員ごと目標集計_一時 B
ON A.従業員コード = B.従業員コード
【 i 】 従業員ごと実績集計_一時 C
ON B.従業員コード = C.従業員コード AND B.KPIコード = C.KPIコード
GROUP BY A.組織コード, B.KPIコード

-- 項番5
SELECT A.*, A.目標組織集計/A.対象従業員数, A.実績組織集計/A.対象従業員数
FROM 【 h 】 A ORDER BY A.組織コード, A.KPIコード
```

***

## 令和4年秋期 午後 データベース

*   **設問の概要：** スマートデバイス管理システムのデータベース設計
*   **SQLの目的：**
    *   図2：契約テーブルに対するアクセス権限をADMINユーザに付与するSQL文。
    *   図3：料金プランテーブルを作成するSQL文。

```sql
-- 図2 表3のアクセス制御を設定するためのSQL文
GRANT 【 j 】 ON 契約 TO ADMIN
```

```sql
-- 図3 表4の料金プラン表を作成するためのSQL文
CREATE TABLE 料金プラン
(料金プランコード CHAR(8) NOT NULL,
 通信事業者コード 【 k 】,
 料金プラン名 VARCHAR(30) NOT NULL,
 基本料金 DECIMAL(5,0) NOT NULL,
 通話単価 DECIMAL(5,2) NOT NULL,
 通信単価 DECIMAL(5,4) NOT NULL,
 【 l 】,
 【 m 】(通信事業者コード) REFERENCES 通信事業者(通信事業者コード))
```

***

## 令和4年春期 午後 データベース

*   **設問の概要：** クーポン発行サービス
*   **SQLの目的：**
    *   図2：クーポン明細テーブルに一意制約を追加するSQL文。
    *   図4：クーポン明細テーブルに、ロックなしで新しい連番のクーポン情報を挿入するSQL文。
    *   図5：クーポン管理テーブルの発行済枚数を更新し、クーポン明細テーブルに新しいクーポン情報を挿入する、ロックあり方式のSQL文。

```sql
-- 図2 "同一会員1枚限りの獲得制限"を制約とするためのSQL文
【 d 】 クーポン明細 ADD CONSTRAINT クーポン明細_IX1
UNIQUE(クーポンコード, 獲得会員コード, 獲得制限_1枚限り)
```

```sql
-- 図4 ロックなし方式のSQL文
INSERT INTO クーポン明細(クーポンコード, クーポン発行連番, 獲得会員コード, 獲得制限_1枚限り)
WITH 発行済枚数取得 AS (SELECT COALESCE(MAX(【 e 】), 0) AS 発行済枚数
    FROM クーポン明細 WHERE クーポンコード = :クーポンコード)
SELECT :クーポンコード,
       (SELECT 発行済枚数 + 1 FROM 発行済枚数取得 WHERE
          (SELECT 発行済枚数 FROM 発行済枚数取得) < 発行上限枚数),
       :会員コード, 獲得制限_1枚限り
FROM クーポン管理 WHERE クーポンコード = :クーポンコード
```

```sql
-- 図5 ロックあり方式のSQL文
UPDATE クーポン管理 【 f 】
WHERE クーポンコード = :クーポンコード AND 発行済枚数 < 【 g 】;
INSERT INTO クーポン明細 (クーポンコード, クーポン発行連番, 獲得会員コード, 獲得制限_1枚限り)
SELECT :クーポンコード, 発行済枚数, :会員コード, 獲得制限_1枚限り
FROM クーポン管理 WHERE クーポンコード = :クーポンコード;
```

***

## 令和3年秋期 午後 データベース

*   **設問の概要：** 企業向け電子書籍サービス
*   **SQLの目的：**
    *   表2：社員による電子書籍の割当依頼処理（一括購入数量の取得、割当済数量の取得、割当処理）を行う一連のSQL文。
    *   図2：社員が閲覧可能な書籍（自身で購入した書籍と、一括購入で割り当てられた書籍）の一覧を取得するSQL文。

```sql
-- 表2 手順1
SELECT 一括購入数量
FROM 一括購入
WHERE 一括購入ID = :一括購入ID

-- 表2 手順2
SELECT 【 d 】
FROM 一括購入割当
WHERE 一括購入ID = :一括購入ID

-- 表2 手順4
INSERT INTO 一括購入割当
(一括購入ID, 社員ID, 企業ID)
【 f 】
```

```sql
-- 図2 閲覧可能な重複を含まない書籍の一覧を取得するSQL文
SELECT sk.【 c 】
FROM 社員書籍購入 sk
WHERE sk.企業ID = :企業ID AND sk.社員ID = :社員ID
【 g 】
SELECT ik.【 c 】
FROM 一括購入 ik
INNER JOIN 一括購入割当 iw
【 h 】
WHERE ik.企業ID = :企業ID AND iw.社員ID = :社員ID
```

***

## 令和3年春期 午後 データベース

*   **設問の概要：** 経営分析システムのためのデータベース設計
*   **SQLの目的：** 貸出予約情報と貸出実績情報を結合し、貸出予定日における遅延返却発生件数を集計して、貸出テーブルに挿入するためのデータを生成するSQL文。

```sql
SELECT R.貸出予定年月日, R.駐車場ID, R.車種ID, R.会員ID, COUNT(*) AS 遅延返却発生件数
FROM (SELECT Y.貸出予約コード, Y.駐車場ID, Y.車種ID, Y.会員ID,
             TIMESTAMP_TO_DATE(Y.貸出予定時刻) AS 貸出予定年月日, Y.返却予定時刻 FROM 貸出予約 Y) R
【 f 】 J.貸出予約コード
WHERE R.返却予定時刻 < J.返却実績時刻
【 g 】
```

***

## 令和2年秋期 午後 データベース

*   **設問の概要：** 宿泊施設の予約システム
*   **SQLの目的：**
    *   図3：指定された条件（施設、部屋種別、期間）で予約可能な部屋数を検索するSQL文。
    *   図6：予約明細テーブル内で重複して挿入されたレコード（同一部屋、同一宿泊日）のうち、最初に挿入されたもの以外を抽出するSQL文。

```sql
-- 図3 部屋の空き状況の確認を行うためのSQL文
SELECT 施設ID, 部屋種別ID, COUNT(*) FROM 部屋
WHERE 【 c 】 (
    SELECT * FROM 予約明細 WHERE 予約明細.部屋ID = 部屋.部屋ID
    AND 予約明細.宿泊日 >= :チェックイン日付 AND 予約明細.宿泊日 < :チェックアウト日付
)
AND 施設ID = :施設ID AND 部屋種別ID = :部屋種別ID
GROUP BY 施設ID, 部屋種別ID
HAVING 【 d 】 >= :部屋数
```

```sql
-- 図6 削除するレコードを抽出するSQL文
SELECT t1.予約ID, t1.予約明細ID, t1.部屋ID, t1.宿泊日 FROM 予約明細 t1
WHERE t1.予約ID > (SELECT 【 h 】 FROM 予約明細 t2
    WHERE 【 i 】 AND 【 j 】)
```

***

## 令和元年秋期 午後 データベース

*   **設問の概要：** 健康応援システムの構築
*   **SQLの目的：**
    *   図2：月次レポートテーブルに、全従業員分のレポート年月を持つレコードを挿入するSQL文。
    *   図3：月次レポートテーブルの月間総歩数を、歩数テーブルから集計して更新するSQL文。

```sql
-- 図2 処理手順(1)で用いるSQL文
INSERT INTO 月次レポート (従業員番号, レポート年月)
【 e 】
FROM 従業員
```

```sql
-- 図3 処理手順(2)④で用いるSQL文
UPDATE 月次レポート
SET 月間総歩数 =
    (SELECT COALESCE(【 f 】, 0)
     FROM 歩数
     WHERE 【 g 】
     AND TOYM(歩数.測定日) = :レポート年月)
WHERE レポート年月 = :レポート年月
```

***

## 平成31年春期 午後 データベース

*   **設問の概要：** 薬剤管理システムの再構築
*   **SQLの目的：**
    *   図2：今回の外来受診で処方された薬剤と、過去半年以内に処方された薬剤の組み合わせの中で、「併用禁忌」と「併用注意」に該当するものを一覧表示するSQL文。
    *   図3：処方前の在庫を確保するためのビューを作成するSQL文。

```sql
-- 図2 "併用禁忌"と"併用注意"に該当する薬剤の組合せ一覧を出力するSQL文
WITH チェック対象薬剤 AS(
    SELECT B1.薬剤コード FROM 処方箋明細 B1,
        (SELECT A1.処方箋ID FROM 外来受診 A1, 処方箋 A2
         WHERE A1.受診者ID = :受診者ID AND A1.処方箋ID = A2.処方箋ID AND
               A2.発行年月日 >= TO_DATE(:半年前年月日)) B2
    WHERE B1.処方箋ID = B2.処方箋ID
    【 g 】
    SELECT C1.薬剤コード FROM 処方箋明細 C1
    WHERE C1.処方箋ID = :処方箋ID
)
SELECT * FROM 薬剤併用情報 T1
WHERE 【 h 】
(SELECT U1.薬剤コード1, T2.薬剤コード2 FROM
    (SELECT U1.薬剤コード AS 薬剤コード1, U2.薬剤コード AS 薬剤コード2
     FROM チェック対象薬剤 U1 CROSS JOIN チェック対象薬剤 U2) T2
 WHERE T1.薬剤コード1 = T2.薬剤コード1 AND T1.薬剤コード2 = T2.薬剤コード2)
```

```sql
-- 図3 確保量を管理するためのビューを作成するSQL文
CREATE VIEW 処方前確保在庫(薬剤コード, 確保量_大人1日) AS
SELECT T3.薬剤コード, 【 i 】
FROM 【 j 】
     (SELECT T2.薬剤コード, T2.処方量_大人1日
      FROM 処方箋 T1, 処方箋明細 T2
      WHERE T1.処方箋ID = T2.処方箋ID AND T1.発行年月日 <= CURRENT_DATE AND
            T1.有効年月日 【 k 】) T3
GROUP BY T3.薬剤コード
```

***

## 平成30年秋期 午後 データベース

*   **設問の概要：** 入室管理システムの設計
*   **SQLの目的：**
    *   図2：指定された社員IDと室IDに対して、現在の日付で入室が可能かどうかをチェックするSQL文。
    *   図3：HRスキーマに、入室管理用の社員ビューを作成するSQL文。
    *   図4：作成したビューに対する参照権限を、入室管理システムのAPユーザに付与するSQL文。
    *   図5：申請者と承認者が同じ組織長であることを確認するためのビューを作成するSQL文。

```sql
-- 図2 入室可否をチェックするSQL文
SELECT 【 a 】 FROM ROOM.入室許可 WHERE 社員ID = :社員ID
AND 室ID = :室ID
AND 入室許可開始年月日 <= :今日
AND 入室許可終了年月日 >= :今日
```

```sql
-- 図3 ビュー表"入室管理用社員"を定義するSQL文
CREATE VIEW HR.入室管理用社員(社員ID, 氏名, 勤務区分) AS
SELECT 社員ID, 氏名, 勤務区分 FROM HR.社員
```

```sql
-- 図4 ビュー表"入室管理用社員"を参照するための権限を付与するSQL文
【 b 】 【 c 】 ON 【 d 】 TO 【 e 】
```

```sql
-- 図5 変更したビュー表"入室管理用社員"を定義するSQL文
CREATE VIEW HR.入室管理用社員(社員ID, 氏名, 勤務区分, 組織長氏名) AS
SELECT T1.社員ID, T1.氏名, T1.勤務区分, T2.氏名
FROM HR.社員 T1, HR.社員 T2, HR.組織 T3
WHERE 【 f 】
```

***

## 平成30年春期 午後 データベース

*   **設問の概要：** 備品購買システムの設計と実装
*   **SQLの目的：** 発注明細、納品明細、返品情報を結合し、発注ごとの発注数量、納品数量、返品数量を一覧表示するSQL文。COALESCE関数でNULLを0に変換している。

```sql
SELECT ORD.発注番号, ORD.商品番号, ORD.商品名, ORD.発注数量,
       COALESCE(【 g 】, 0)
FROM
(SELECT OD.発注番号, OT.商品番号, OT.商品名, OT.発注数量
 FROM 発注明細 OD INNER JOIN 発注 OT ON OD.発注番号 = OT.発注番号
 WHERE 【 h 】) ORD
LEFT OUTER JOIN
(SELECT DE.発注番号, DD.商品番号, SUM(DD.納品数量) AS 納品数量計
 FROM 納品 DE INNER JOIN 納品明細 DD ON DE.納品番号 = DD.納品番号
 WHERE DE.発注番号 = :発注番号
 【 i 】) DLI
ON ORD.発注番号 = DLI.発注番号
AND ORD.商品番号 = DLI.商品番号
【 j 】
```

***

## 平成29年秋期 午後 データベース

*   **設問の概要：** 青果卸売業のシステム改修
*   **SQLの目的：** 商品、販売明細、産地、返品の各テーブルを結合し、当日返品された商品の品目ごと・産地ごとの合計返品金額と合計返品数量を算出するSQL文。

```sql
SELECT 品目コード, 品目名, 産地コード, 産地名,
       【 f 】 AS 合計返品金額, SUM(t1.パレット数) AS 合計返品数量
FROM 返品 t1
INNER JOIN 販売明細 t2 USING (販売番号, 販売明細番号)
【 g 】
INNER JOIN 品目 USING (品目コード)
INNER JOIN 産地 USING (産地コード)
WHERE 返品日 = CURRENT_DATE
【 h 】
GROUP BY 品目コード, 産地コード
ORDER BY 品目コード ASC, 産地コード ASC
```

***

## 平成29年春期 午後 データベース

*   **設問の概要：** 稟議申請システム
*   **SQLの目的：**
    *   図3：ログイン中の利用者が参照できる（自身が申請、または承認者となっている）稟議申請を検索するSQL文。
    *   図4：購買稟議と契約稟議の申請について、金額と支払日の一覧を出力するSQL文。CASE式を用いて項目キーに応じた値を取得している。

```sql
-- 図3 稟議申請を検索するSQL文
SELECT 申請書.申請書ID, 申請書.タイトル, 申請書.申請日, ユーザ.ユーザ名, 部署マスタ.部署名
FROM 申請書 INNER JOIN 承認申請 ON 申請書.申請書ID = 承認申請.申請書ID
INNER JOIN ユーザ ON 申請書.申請者ID = ユーザ.ユーザID
INNER JOIN 部署マスタ ON ユーザ.部署ID = 部署マスタ.部署ID
WHERE (承認申請.承認申請状態 NOT IN ('可決','否決')) AND
((申請書.申請者ID = :ユーザID) OR
 (申請書.申請書ID IN (SELECT DISTINCT 申請書ID FROM 承認者情報 INNER JOIN 承認申請
    ON 【 c 】 WHERE 【 d 】)))
```

```sql
-- 図4 金額と支払日の一覧を検索するSQL文
SELECT 申請書.申請書ID, 申請書.タイトル,
       【 e 】 AS 金額, 【 f 】 AS 支払日
FROM 申請書 INNER JOIN 申請書項目 t1 ON 【 g 】
INNER JOIN 申請書項目 t2 ON 【 h 】, 承認申請
WHERE
((申請書.書式ID = '購買' AND t1.項目キー = 'amount' AND t2.項目キー = 'pay_date') OR
 (申請書.書式ID = '契約' AND t1.項目キー = 'pay_initial' AND t2.項目キー = 'start_date'))
AND (承認申請.申請書ID = 申請書.申請書ID AND 承認申請.承認申請状態 = '可決')
```

***

## 平成28年秋期 午後 データベース

*   **設問の概要：** ネットショップの会員管理
*   **SQLの目的：**
    *   図2：過去1年間の購入履歴から、会員ごと・商品分類ごとの購入金額合計を一覧表示するSQL文。
    *   図3：カーソルを用いて購入履歴を一件ずつ処理し、会員種別（一般会員／特別会員）の判定と、購入データの処理状態を更新するプログラムの一部。

```sql
-- 図2 過去の購入済み商品分類一覧を表示するSQL文
SELECT t1.会員番号, t1.氏名, t6.商品分類番号, t6.商品分類名,
       【 c 】 AS 購入金額合計
FROM 会員 t1
INNER JOIN (SELECT t2.購入番号, t2.会員番号 FROM 購入 t2 WHERE 【 d 】 > (:一年前)) t3 ON t1.会員番号 = t3.会員番号
INNER JOIN 購入明細 t4 ON t3.購入番号 = t4.購入番号
INNER JOIN 商品 t5 ON t4.商品番号 = t5.商品番号
INNER JOIN 商品分類 t6 ON t5.商品分類番号 = t6.商品分類番号
GROUP BY t1.会員番号, t1.氏名, t6.商品分類番号, t6.商品分類名
```

```sql
-- 図3 カーソルを使用した会員種別判定バッチ処理を行うプログラム(一部)
DECLARE cur CURSOR FOR
    SELECT t2.会員番号, t2.購入番号, t2.購入金額
    FROM 購入 t2
    WHERE 【 e 】
    AND t2.購入日時 <= :判定対象期限
    AND t2.判定処理状態 <> '判定処理済み'
    【 f 】;
UPDATE 会員 t1 SET t1.会員種別 = '一般会員';
SET current_kaiin_no = 0;
SET goukei = 0;
OPEN cur;
fetch_loop: LOOP
    FETCH cur INTO kaiin_no, kounyu_no, kounyu_kingaku;
    IF kaiin_no <> current_kaiin_no THEN
        SET current_kaiin_no = kaiin_no;
        SET update_flag = 0;
        SET goukei = 0;
    END IF;
    IF update_flag = 0 THEN
        SET goukei = goukei + kounyu_kingaku;
        UPDATE 購入 t2 SET t2.判定処理状態 = '判定処理済み'
        WHERE t2.購入番号 = kounyu_no;
        IF 【 g 】 THEN
            UPDATE 会員 t1 【 h 】 WHERE t1.会員番号 = kaiin_no;
            SET update_flag = 1;
        END IF;
    ELSE
        UPDATE 購入 t2 SET t2.判定処理状態 = '繰越し' WHERE t2.購入番号 = kounyu_no;
    END IF;
END LOOP fetch_loop;
CLOSE cur;
```

***

## 平成28年春期 午後 データベース

*   **設問の概要：** コンビニエンスストアのデータウェアハウス構築
*   **SQLの目的：**
    *   図2：店舗の在庫数と販売数を結合して売上ファクト表のデータを抽出するSQL文。
    *   図3：店舗ごと・月ごとの売れ行きが悪い商品の一覧を作成するSQL文。

```sql
-- 図2 売上ファクト表に挿入するデータを抽出するSQL文
SELECT ST.確認年月日, ST.店舗ID, ST.商品ID, COALESCE(SS.日間販売数量, 0),
       ST.日間在庫数量
FROM
(SELECT SC.確認年月日, SC.店舗ID, SC.商品ID,
        AVG(SC.在庫数量) AS 日間在庫数量
 FROM 在庫 SC
 GROUP BY SC.確認年月日, SC.店舗ID, SC.商品ID) ST
【 α 】
(SELECT SL.販売年月日, SL.店舗ID, SD.商品ID,
        SUM(SD.販売数量) AS 日間販売数量
 FROM 販売 SL
 INNER JOIN 販売詳細 SD ON SL.販売ID = SD.販売ID
 GROUP BY SL.販売年月日, SL.店舗ID, SD.商品ID) SS
ON ST.確認年月日 = SS.販売年月日
AND 【 e 】
AND 【 f 】
【 β 】
```

```sql
-- 図3 売れ行きが悪い商品分類の一覧を作成するSQL文
SELECT SF.売上年月, SF.店舗ID, IT.商品分類ID,
       AVG(SF.日間販売数量) AS 平均販売数量, AVG(SF.日間在庫数量) AS 平均在庫数量
FROM
(SELECT TO_YYYYMM(SA.売上年月日) AS 売上年月, SA.店舗ID, SA.商品ID,
        SA.日間販売数量, SA.日間在庫数量
 FROM 売上ファクト SA) SF
INNER JOIN 商品 IT ON SF.商品ID = IT.商品ID
GROUP BY SF.売上年月, SF.店舗ID, IT.商品分類ID
【 g 】
```

***

## 平成27年秋期 午後 データベース

*   **設問の概要：** 人事情報のデータ構造
*   **SQLの目的：**
    *   図2, 5：再帰SQL（共通表式）を用いて、指定された部署とその配下にある全ての部署の情報を階層的に取得するSQL文。

```sql
-- 図2 指定した部署とその配下の全ての部署を出力するSQL文
WITH RECURSIVE 関連部署(部署ID, 部署名, 上位部署ID) AS (
    SELECT 部署ID, 部署名, 上位部署ID
    FROM 部署 WHERE 部署ID = :部署ID
    UNION ALL
    SELECT 部署.部署ID, 部署.部署名, 部署.上位部署ID
    FROM 部署, 関連部署 WHERE 部署.上位部署ID = 関連部署.部署ID
)
SELECT 部署ID, 部署名, 上位部署ID FROM 関連部署
```

```sql
-- 図5 指定した日の会社全体の部署構造を出力するSQL文
WITH RECURSIVE 関連部署(部署ID, 部署名, 上位部署ID) AS (
    SELECT 部署ID, 部署名, 上位部署ID
    FROM 部署 WHERE 部署ID = 【 d 】
    AND :年月日 BETWEEN 部署.適用開始年月日 AND 部署.適用終了年月日
    UNION ALL
    SELECT 部署.部署ID, 部署.部署名, 部署.上位部署ID
    FROM 部署, 関連部署 WHERE 部署.上位部署ID = 関連部署.部署ID
    AND :年月日 BETWEEN 部署.適用開始年月日 AND 部署.適用終了年月日
)
SELECT 部署ID, 部署名, 上位部署ID FROM 関連部署
```

***

## 平成27年春期 午後 データベース

*   **設問の概要：** アクセスログ監査システムの構築
*   **SQLの目的：**
    *   図2：アクセスログから、非営業日に発生したログのみを抽出するSQL文。
    *   図3：利用者テーブル、サーバテーブル、アクセスログテーブルを結合し、部外者による失敗したアクセスログを抽出するSQL文。

```sql
-- 図2 非営業日利用一覧表示機能で用いるSQL文
SELECT AC.*
FROM アクセスログ AC
WHERE 【 c 】
(SELECT * FROM 非営業日 NS
 WHERE 【 d 】)
```

```sql
-- 図3 部外者失敗一覧表示機能で用いるSQL文
SELECT AC.*
FROM アクセスログ AC
INNER JOIN 利用者 US ON AC.利用者ID = US.利用者ID
INNER JOIN サーバ SV ON AC.サーバID = SV.サーバID
WHERE 【 e 】
AND 【 f 】
```

***

## 平成26年秋期 午後 データベース

*   **設問の概要：** 分散トランザクション
*   **SQLの設問はありません。**