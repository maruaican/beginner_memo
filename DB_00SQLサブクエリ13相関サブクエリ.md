# 相関サブクエリ

# １　全体像（テキスト図）

```
外側SELECT（顧客/社員などの1行） ──→ 相関サブクエリ（内側）
                                  ↑（外側の列を参照）
評価：外側の各行ごとに 内側の FROM→WHERE→GROUP BY→HAVING→SELECT→ORDER BY を実行
使いどころ：
  WHERE [NOT] EXISTS (SELECT 1 … )（存在判定：半結合/反結合）
  WHERE 列 比較演算子 (=, >, <, >=, <=) (スカラ相関)
  WHERE 列 = ANY / > ALL（多行比較）
  SELECT句の相関スカラサブクエリ（列を“その場で”計算）
  FROM句のLATERAL/CROSS APPLY（行ごとの派生表）
  HAVING句でグループごとの相関条件
  UPDATE/DELETEの相関条件
```

# １－１　定義（IPA準拠）と用語の由来

* 定義（要約）：**相関サブクエリ**とは，「内側のサブクエリが外側の問合せの列（外側参照）を用いる」サブクエリ。
　外側の各行について内側を評価する。
* 用語の由来：correlate（相互に関係づける）＋ subquery。外側と内側が“結び付く”ことが語源。
  （注）評価順は常に **FROM→WHERE→GROUP BY→HAVING→SELECT→ORDER BY**。相関では「外側1行ごとに内側で同じ評価順」が繰り返される。

# １－２　技術の必要性（解決する具体的課題）

* 顧客ごとの「最新注文日」「累計金額」など**行ごとに条件や集計が違う**場面。
* 「存在する/しない」判定（半結合/反結合）で**重複やNULLの罠を回避**。
* 「部門平均より高給」など**グループ内比較**。
* 「各顧客の直近1件を横に並べる」など**行ごとの上位N抽出**（LATERAL）。
* UPDATE/DELETE時の**整合性チェック**や**ターゲット限定**。

# １－３　試験の着眼点（頻出領域と解答に必要な知識）

* 頻出：
  （１）**EXISTS / NOT EXISTS**（NULLに強い），**部門平均との比較**の**相関スカラ**，**ANY/ALL**，**最新行の取得（自己相関 NOT EXISTS）**。
  （２）**NOT IN＋NULL混入で結果0行**（試験作成者が「NOT INはNULLで全滅する」誤解を狙って出題）。
  （３）**多行返すのに=で比較**（「複数行を1行に要約せよ：MAX/MIN/AVGや条件で1件に絞る」）。
* 重要知識：
  ・EXISTSは「見つかったら即TRUE」で**高速/軽い**傾向（適切な索引が前提）。
  ・NOT EXISTSは**反結合**でNULLに影響されない（**NOT INは危険**）。
  ・ANY/ALLの読み替え（>= ALL はそのグループの最大値以上 等）。
  ・相関は**外側1行×内側評価**なので**索引・データ量・集約回数**が速度を決める。
  ・**評価順**と**外側/内側の別名のスコープ**を正確に。

# １－４　体系マップ（分類・関係・比較表）

```
種類         用途                   NULL耐性     性能感（目安）    代表書き方
EXISTS       存在チェック(半結合)   影響なし     軽い/高速         WHERE EXISTS(SELECT 1 … 外側列…)
NOT EXISTS   非存在チェック(反結合) 影響なし     軽い/高速         WHERE NOT EXISTS(SELECT 1 … 外側列…)
相関スカラ   1値比較/列生成         内側次第     中（要索引）      列 > (SELECT AVG(…) WHERE …外側…)
ANY/SOME     “いずれか”比較         内側次第     中                列 >= ANY(SELECT … WHERE …外側…)
ALL          “すべて”比較            内側次第     中                列 >= ALL(SELECT … WHERE …外側…)
LATERAL/APPLY 行ごと上位N/派生表     内側次第     中〜重            FROM 外側, LATERAL(SELECT … WHERE …外側…)
HAVING相関   グループ条件            内側次第     中                HAVING 集計条件 AND (SELECT … 外側…)
DML相関      UPDATE/DELETEの限定     内側次第     中                DELETE … WHERE NOT EXISTS(SELECT …)
```

１－５　代表例
## 顧客

| 顧客ID | 顧客名  |
| ---- | ---- |
| 1    | 佐藤商事 |
| 2    | 鈴木工業 |
| 3    | 田中屋  |
| 4    | 高橋商会 |

---

## 注文

| 注文ID | 顧客ID | 注文日  |
| ---- | ---- | ---- |
| 101  | 1    | 8/1  |
| 102  | 1    | 8/10 |
| 103  | 2    | 8/5  |
| 104  | 3    | 8/20 |
| 105  | NULL | 8/25 |

---

## 商品

| 商品ID | 商品名   | 単価     |
| ---- | ----- | ------ |
| 201  | ノートPC | 120000 |
| 202  | マウス   | 2000   |
| 203  | モニタ   | 30000  |

---

## 注文明細

| 注文明細ID | 注文ID | 商品ID | 数量 | 単価     |
| ------ | ---- | ---- | -- | ------ |
| 1001   | 101  | 201  | 1  | 120000 |
| 1002   | 101  | 202  | 2  | 2000   |
| 1003   | 102  | 203  | 1  | 30000  |
| 1004   | 103  | 202  | 5  | 2000   |
| 1005   | 104  | 201  | 2  | 120000 |

---

## 社員

| 社員ID | 社員名 | 部署ID | 給与     |
| ---- | --- | ---- | ------ |
| 1    | 山田  | 10   | 400000 |
| 2    | 佐藤  | 10   | 380000 |
| 3    | 鈴木  | 20   | 450000 |
| 4    | 田中  | 20   | 300000 |

---

## 部署

| 部署ID | 部署名 |
| ---- | --- |
| 10   | 営業  |
| 20   | 製造  |


（評価順は各SQLの直後に注記。FROM→WHERE→GROUP BY→HAVING→SELECT→ORDER BY。相関では「外側1行ごとに内側も同順で評価」。）

# （１）EXISTS：ノートPCを1回でも買った顧客

```sql
SELECT
  c.顧客名
FROM
  顧客 c
WHERE
  EXISTS (
    SELECT
      1
    FROM
      注文 o
      JOIN 注文明細 od ON o.注文ID = od.注文ID
      JOIN 商品 p ON od.商品ID = p.商品ID
    WHERE
      o.顧客ID = c.顧客ID AND p.商品名 = 'ノートPC'
  );
```

出力：

佐藤商事
田中屋


性能：軽い/高速（索引：注文(顧客ID), 注文明細(注文ID), 商品(商品名)）。
注記：評価順（外側1行ごとに内側FROM→…）。

# （２）NOT EXISTS：注文が一度も無い顧客（NULL安全）

SELECT c.顧客名
FROM
  顧客 c
WHERE
  NOT EXISTS (
    SELECT
      1
    FROM
      注文 o
    WHERE
      o.顧客ID = c.顧客ID
  );

出力：

```
高橋商会
```

性能：軽い/高速（反結合）。**NOT INではNULL行（注文.顧客ID=NULL）で全滅の恐れ**。
注記：評価順同上。

（誤答例）NOT INで同じことをやる

```sql
-- 誤りになり得る：注文.顧客ID に NULL が1件でもあると全体がUNKNOWN→0行
SELECT 顧客名
FROM 顧客
WHERE 顧客ID NOT IN (SELECT 顧客ID FROM 注文);
```

結果：**0行**（本データは注文ID105で顧客IDがNULL）。
正答に直す：**NOT EXISTS**を用いる（上記（２））。

# （３）相関スカラ：部門平均より高給の社員
```sql
SELECT
  e1.社員名,e1.給与
FROM
  社員 e1
WHERE
  e1.給与 > (
    SELECT
      AVG(e2.給与)
    FROM
      社員 e2
    WHERE
      e2.部署ID = e1.部署ID
  );
```

出力：

```
山田 400000
鈴木 450000
```

性能：中（索引：社員(部署ID, 給与)）。
注記：評価順同上。外側社員1行ごとに平均を再計算（実装は最適化され得る）。

# （４）SELECT句の相関スカラ：顧客ごとの最新注文日
```sql
SELECT
  c.顧客名,
  (
    SELECT
      MAX(o.注文日)
    FROM
      注文 o
    WHERE
      o.顧客ID = c.顧客ID
  ) AS 最新注文日
FROM
  顧客 c
ORDER BY
  c.顧客名;
```

出力：

```
佐藤商事 | 2025-08-10
鈴木工業 | 2025-08-05
田中屋   | 2025-08-20
高橋商会 | NULL
```

性能：中（顧客×集約。索引：注文(顧客ID, 注文日)）。
注記：評価順同上。

# （５）ANY/ALL：部署内で最高給与の社員（>= ALL）

```sql
SELECT
  e1.社員名,  e1.部署ID,  e1.給与
FROM  社員 e1
WHERE  e1.給与 >= ALL (
    SELECT  e2.給与
    FROM    社員 e2
    WHERE   e2.部署ID = e1.部署ID
  );
```

出力：

```
山田 10 400000
鈴木 20 450000
```

読み替え：**>= ALL** は「部署内の**最大値以上**」。
性能：中。注記：評価順同上。

# （６）自己相関 NOT EXISTS：顧客ごとの**最新の注文行**を1行に

```sql
SELECT
  o1.注文ID,
  o1.顧客ID,
  o1.注文日
FROM
  注文 o1
WHERE
  o1.顧客ID IS NOT NULL
  AND NOT EXISTS (
    SELECT
      1
    FROM
      注文 o2
    WHERE
      o2.顧客ID = o1.顧客ID
      AND o2.注文日 > o1.注文日
  );
);
```

出力：

```
(102, 顧客1, 2025-08-10)
(103, 顧客2, 2025-08-05)
(104, 顧客3, 2025-08-20)
```

性能：中（索引：注文(顧客ID, 注文日 DESC)で高速）。
注記：評価順同上。

# （７）相関IN（参考：機能的にはEXISTS推奨）
「ノートPCが購入品目に**含まれる**顧客」

```sql
SELECT
  c.顧客名
FROM
  顧客 c
WHERE
  'ノートPC' IN (
    SELECT
      p.商品名
    FROM
      注文 o
      JOIN 注文明細 od ON od.注文ID = o.注文ID
      JOIN 商品 p ON p.商品ID = od.商品ID
    WHERE
      o.顧客ID = c.顧客ID
  );
```

出力：

```
佐藤商事
田中屋
```

備考：成立するが**EXISTSの方が意図が明確**で一般に軽い。
注記：評価順同上。

# （８）FROM句 LATERAL（上位1件を横に結合）
※標準SQL: `LATERAL`、他方言：`CROSS APPLY`等

```sql
SELECT
  c.顧客名,
  latest_o.注文日 AS 直近注文日
FROM
  顧客 c
  LEFT JOIN LATERAL (
    SELECT
      o.注文日
    FROM
      注文 o
    WHERE
      o.顧客ID = c.顧客ID
    ORDER BY
      o.注文日 DESC
    FETCH FIRST 1 ROW ONLY
  ) latest_o ON TRUE
ORDER BY
  c.顧客名;

```

出力は（４）と同様。
性能：中〜重（並び替え/上位N。索引：注文(顧客ID, 注文日 DESC)必須）。
注記：評価順同上。

# （９）HAVINGでの相関（例：顧客ごとの合計が**全顧客平均**より大きい）

```sql
SELECT
  c.顧客ID,
  c.顧客名,
  SUM(od.数量 * od.単価) AS 顧客合計
FROM
  顧客 c
  JOIN 注文 o ON o.顧客ID = c.顧客ID
  JOIN 注文明細 od ON od.注文ID = o.注文ID
GROUP BY
  c.顧客ID,
  c.顧客名
HAVING
  SUM(od.数量 * od.単価) > (
    SELECT
      AVG(total_amount)
    FROM
      (
        SELECT
          SUM(od2.数量 * od2.単価) AS total_amount
        FROM
          注文 o2
          JOIN 注文明細 od2 ON od2.注文ID = o2.注文ID
        GROUP BY
          o2.顧客ID
      ) customer_totals
  );
```

出力：本データでは**田中屋**と**佐藤商事**（注：手計算可）。
性能：重い/低速（集約の入れ子）。
注記：評価順同上。

# （10）UPDATE/DELETEでの相関

```sql
-- 注文に対応する顧客が存在しない行を削除（整合性回復）
DELETE FROM 注文 o
WHERE
  NOT EXISTS (
    SELECT
      1
    FROM
      顧客 c
    WHERE
      c.顧客ID = o.顧客ID
  );

-- 部署平均未満の社員を5%昇給
UPDATE 社員 e1
SET
  給与 = 給与 * 1.05
WHERE
  給与 < (
    SELECT
      AVG(e2.給与)
    FROM
      社員 e2
    WHERE
      e2.部署ID = e1.部署ID
  );
```

性能：中（トランザクション/索引前提）。
注記：評価順同上。

# １－６　よくある誤解と正しい知識

* 誤解：「NOT IN でも NOT EXISTS と同じ」
  → 正：**サブクエリ側にNULLが1つでもあるとNOT INはUNKNOWNで0行**。NULL安全は**NOT EXISTS**。
* 誤解：「相関サブクエリは必ず遅い」
  → 正：最適化で**半結合/反結合**に変換され**高速**に動くことが多い。**索引と選択度**が鍵。
* 誤解：「= でサブクエリ比較すればよい」
  → 正：**内側は1行1列**でなければエラー/不定。必要なら**MAX/MIN**や**条件で1件化**。
* 誤解：「EXISTS は結果内容を返す」
  → 正：EXISTSは**存在の真偽だけ**。返るのは外側の行。
* 誤解：「外側別名は内側で使えないことがある」
  → 正：**相関**は内側で外側の別名を参照してよい（スコープに注意）。
* 誤解：「ANY/ALL が難しい」
  → 正：**>= ALL は“最大値以上”**, \*\*>= ANY は“最小値以上”\*\*と置換して読む。

# １－７　一問一答（5問：問題→回答→解説）
---
### Q1. 注文が1件も無い顧客を求めよ。
**A.**
```sql
SELECT
  c.顧客名
FROM
  顧客 c
WHERE
  NOT EXISTS (
    SELECT
      1
    FROM
      注文 o
    WHERE
      o.顧客ID = c.顧客ID
  );
```
**エイリアス:** `c`: 顧客, `o`: 注文

解説：反結合。**NULL安全**。評価順：外側各行→内側FROM…

---
### Q2. 部署内で**最高給与**の社員を求めよ（ANY/ALL使用）。
**A.**
```sql
SELECT
  e1.社員名,
  e1.部署ID
FROM
  社員 e1
WHERE
  e1.給与 >= ALL (
    SELECT
      e2.給与
    FROM
      社員 e2
    WHERE
      e2.部署ID = e1.部署ID
  );
```
**エイリアス:** `e1`: 社員(外側), `e2`: 社員(内側)

解説：>= ALL＝部署内最大値以上。

---
### Q3. 顧客ごとの**最新注文日**を列として出せ。
**A.**
```sql
SELECT
  c.顧客名,
  (
    SELECT
      MAX(o.注文日)
    FROM
      注文 o
    WHERE
      o.顧客ID = c.顧客ID
  ) AS 最新注文日
FROM
  顧客 c;
```
**エイリアス:** `c`: 顧客, `o`: 注文

解説：SELECT句の相関スカラ。

---
### Q4. 「ノートPC」を**一度でも**購入した顧客をEXISTSで。
**A.**
```sql
SELECT
  c.顧客名
FROM
  顧客 c
WHERE
  EXISTS (
    SELECT
      1
    FROM
      注文 o
      JOIN 注文明細 od ON od.注文ID = o.注文ID
      JOIN 商品 p ON p.商品ID = od.商品ID
    WHERE
      o.顧客ID = c.顧客ID AND p.商品名 = 'ノートPC'
  );
```
**エイリアス:** `c`: 顧客, `o`: 注文, `od`: 注文明細, `p`: 商品

解説：見つかった時点でTRUE→**高速**。

---
### Q5. 次の誤りを修正せよ。
```sql
SELECT 顧客名
FROM 顧客
WHERE 顧客ID NOT IN (SELECT 顧客ID FROM 注文); -- 注文.顧客IDにNULL有り
```
**A.**
```sql
SELECT
  c.顧客名
FROM
  顧客 c
WHERE
  NOT EXISTS (
    SELECT
      1
    FROM
      注文 o
    WHERE
      o.顧客ID = c.顧客ID
  );
```
**エイリアス:** `c`: 顧客, `o`: 注文


解説：**NOT IN＋NULL**は全滅。**NOT EXISTS**で正答。

# １－８　要約（3行以内）

* 相関サブクエリは「外側1行ごとに内側を評価」する仕組みで，存在判定（EXISTS/NOT EXISTS）とスカラ比較が頻出。
* **NOT INはNULLで危険**，**NOT EXISTSはNULL安全**。ANY/ALL は「最大/最小で読み替え」。
* 速度は索引と選択度で決まる。半結合/反結合の発想で書ければ**正確かつ高速**に解ける。


# ３．図式化ルール（本回答の適用）
（１）関係は矢印で表現：顧客１→多 注文，多←１。
（２）プロセスは最少の箱と矢印で：外側1行→内側評価→真偽→採用/棄却。
（３）比較は2〜3列表で提示（上記1-4参照）。

# ４．SQL専用ルール（本回答の適用）
（１）販売業モデルを使用（顧客/商品/注文/注文明細/社員/部署）。
（２）項目名は業務日本語。別名も日本語（例：顧=顧客, 注=注文, 明=注文明細）。
（３）**評価順は常に明記**：FROM→WHERE→GROUP BY→HAVING→SELECT→ORDER BY。
（４）関数従属性は同一表内のみを前提（相関の論旨に不介入）。
（５）性能感は**軽い/高速／重い/低速**で明示し，原因（索引・データ量・結合/集約回数）を説明。

# ５．学習の定着ポイント

* 試験作成者の狙い」：①NOT IN＋NULL，②多行を=で比較，③ANY/ALLの読解。
* まず**EXISTS/NOT EXISTS**で半結合/反結合を“図で”考える → 次に**相関スカラ**で1行化。
* 語源で覚える：correlate＝結び付ける → **外側と内側が結び付く**サブクエリ。