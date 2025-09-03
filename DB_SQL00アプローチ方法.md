USER
AP試験の午後のデータベースの問題にはSQL文の穴埋め問題があるよね。

どうやってアプローチすればいいだろうか。
私は、次のような点からアプローチしている。

FROM句の表の属性（ER図から）を探って、使われていない属性はないか。
SELECT内に集約関数があれば、GROUP BYが使われているか。
COALESCEが使われていれば、LEFT JOINが使われているはずだ。

埋め込み変数”例 ：発注番号”が本文で設定されていれば、必ずSQL文内には使われる。

本文に「昇順」「降順」とあれば、ORDER BYが使われる。
本文に「ごとに」と記載されていれば、GROUP BYが使われる。
LEFT JOINされた後の表（別名）にはNULLが含まれているので、それをどうにかして処理しなければならない。
など。

今までの過去問を分析して、どのようにアプローチすればいいか、一覧として出力して。質問があったらお願いします。


LLM
いい着眼点をすでに持っていますね。
午後のデータベースSQL穴埋め問題は「本文・ER図・SQL部分の三点照合」をしながら、典型的な“お作法”を抑えるのがコツです。

以下に、過去問分析から整理した **アプローチ一覧** を提示します。

---

# 応用情報技術者試験のSQL文穴埋め問題の定石パターンとアプローチ方法

# １　SQL穴埋め問題のアプローチ一覧

```
本文（問題文） → ER図 → 部分SQL → 解答欄
```

* SQL穴埋め問題は、
 1. 本文のキーワード：キーワードのとおりに、SQLが組まれているか。
 2. ER図：リレーション、主キー・複合主キーどおりにSQL（JOIN）が組まれているか。
 　　　　 FROM句の表内の属性が使っているか、使われていないものがないか。
 3. 典型的構文：非集約属性に対するGROUPBY
 
の三点照合が鍵。

---

## １－１　ER図・テーブル定義からの確認
* ER図で「多←１」の矢印を確認し、JOIN条件（外部キー＝主キー）を特定する。
* FROM句に出てくる表の属性を洗い出し、使われていないものがあるか確認する。
* 中間表（例：注文明細）の存在は「複数対複数」の関係を解消するために必須 → JOIN忘れ防止。

---

## １－２　本文のキーワードと典型的SQL構文の対応

| 本文の記述         | SQLで対応する構文・キーワード                      |
| ------------- | ------------------------------------- |
| 「…ごとに」        | GROUP BY                              |
| 「最大」「最小」「平均」  | MAX, MIN, AVG                         |
| 「～件以上」        | HAVING（GROUP BY後）                     |
| 「存在するかどうか」    | EXISTS / NOT EXISTS                   |
| 「含まれていない」     | NOT IN / NOT EXISTS                   |
| 「昇順」「降順」      | ORDER BY ASC / DESC                   |
| 「NULLのとき～に置換」 | COALESCE（SELECT内に普通の置ける） / CASE                       |
| 「～（販売実績等）がない場合でも」    | LEFT JOIN                             |

| 「最新」「最も古い」    | ORDER BY 日付 DESC/ASC + LIMIT or サブクエリ |



---

## １－３　SELECTとGROUP BYの対応
* 集約関数（SUM, COUNT, AVG…）が出たら、非集約列は必ずGROUP BYに含める。
* 本文で「部署ごと」「顧客ごと」とあれば、GROUP BYの有無を確認。

---

## １－４　JOINとNULL処理の定石
* **LEFT JOINがあるとき** → 必ず「NULL対策」が出る（COALESCEやCASE）。
* **INNER JOINのみのとき** → NULLは基本的に出ない。
* 本文で「対応するデータ（例：販売実績がない商品）がない場合でも表示」とあればLEFT JOIN確定。

---
## １－５　本文と埋め込み変数
* 本文に「埋め込み変数（例：:発注番号）」がある場合、SQL内で必ず使われる。
  → WHERE句の条件に出るか、サブクエリ内で利用される。
* 本文の業務的な指示（「ある発注番号について」など）は、この変数に直結。

---

## １－６　ORDER BYと出力形式
* 本文に「昇順」「降順」とあれば確実にORDER BY。
* 本文に「上位○件」や「最新1件」とあれば、ORDER BY + FETCH / LIMIT のパターン。

---

## １－７　よくある試験の「罠」

* **ON句とWHERE句の混同**：

  * JOIN条件はON、検索条件はWHERE。
  * ONに書くべき条件をWHEREに書いて不正解になることあり。

* **HAVINGとWHEREの混同**：

  * WHEREは行を絞る。集約前に行を絞るならWHERE。
  * GROUP BYで集約後の条件はHAVING。
  * 本文に「部署ごとの平均給与が30万以上」とあればHAVING。

* **NOT INとNULL**：
  * サブクエリにNULLが混じると全体が空になる → NOT EXISTSにすべき。

* **COALESCE忘れ**：
  * LEFT JOIN後にNULLをそのまま出すと本文要件に合わない。

---

# ２　一問一答（練習用）

**Q1.** 本文に「部署ごとに社員数を数えよ」とあるときに必要なSQL句は？
**A1.** GROUP BY 部署ID / 部署名
**解説**：非集約列（部署）でグループ化しないとCOUNTが正しく集計されない。

**Q2.** 本文に「商品が存在しない注文も表示」とあった場合、JOINの種類は？
**A2.** LEFT JOIN
**解説**：注文を基準に商品をLEFT JOIN → 商品がNULLでも注文を残す。

**Q3.** 「社員ごとの平均給与」を求めるとき、GROUP BYは必要か？
**A3.** 不要
**解説**：社員ごとなら1人＝1行。社員IDで既に一意なのでAVGしても意味がない。

**Q4.** WHERE句とHAVING句の違いは？
**A4.** WHEREは行を絞る、HAVINGは集約結果を絞る。
**解説**：本文に「部署ごとの平均給与が30万以上」とあればHAVING。

**Q5.** 本文に「社員が所属していない部署も表示」とあるとき、どうする？
**A5.** 部署 LEFT JOIN 社員、COUNT(COALESCE(社員ID,0)) など。
**解説**：LEFT JOIN + COALESCEで社員ゼロの部署を表示。


ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
了解しました。では\*\*「空欄ありSQL（AP）問題を与えられたときに、どの順序でどこを見てどう判断するか」\*\*を完全にパターン化した実践ガイドを出します。試験で「パターンで解ける問題は即座に片づけ、熟考型に時間を残す」戦略に最適化しています。出力フォーマットはご指定どおりに揃えます。

---

# １　全体像（テキスト図）

```
問題文（業務要件） ──> キーワード抽出（即判定）
      ↓
ER図／表定義確認（1→多､主キー・外部キー）──> テーブル間の参照関係確定
      ↓
空欄位置特定（SELECT/ FROM / JOIN / ON / WHERE / GROUP BY / HAVING / ORDER BY / サブクエリ）
      ↓
解法パターンに照合（速攻パターン or 熟考パターン）
      ↓
速攻：定石句を穴埋め → 検算（評価順確認）
熟考：疑義点（NULL, 集約, 相関）を深掘り → 正答
```

---

## １－１　定義（IPA準拠）と用語の由来

(1) **SQL**：Structured Query Language。RDB操作言語（IBM System R由来）。
(2) **穴埋め問題（AP形式）**：業務要件から標準的なSQL句を瞬時に選ぶ技能を測定。
(3) **解法パターン（解放パターン）**：過去問に頻出する「入力（業務文）→出力（SQL句）」の定型変換規則群。

---

## １－２　技術の必要性（解決する具体的課題）

(1) 試験時間を有効に使う（パターン問題を即解、熟考問題へ時間配分）。
(2) 試験作成者が狙う「受験者の混乱ポイント（ON/WHERE, WHERE/HAVING, NOT IN/NULLなど）」を先読みしてミスを回避。
(3) 実務で致命的になりやすい「NULL取り扱い・集約漏れ・結合漏れ」を試験対策として体得。

---

## １－３　試験の着眼点（頻出領域と解答に必要な知識を解説）

(1) **キーワード判定**：本文の語句を即座にSQL句へ対応付け。
　① 「…ごとに」→ GROUP BY
　② 「件数」「上位」→ COUNT / ORDER BY + LIMIT
　③ 「存在する/しない」→ EXISTS / NOT EXISTS（NOT IN注意）
(2) **ER図観察点**：多←１の矢印（外部キー→主キー）、中間表の有無（M\:Nの解消）
(3) **空欄位置の意味**：空欄がFROM系かSELECT系かでアプローチが別（FROM系は構造、SELECT系は集約/関数）
(4) **評価順の理解**：必須→ `評価順: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY`（必ず確認）

---

## １－４　体系マップ（分類・関係・比較表）

### 解法パターン一覧（高速判定フラグ付）

| パターン名                     |               キーワードの例 | 空欄位置の典型                          |   速攻可？  |
| ------------------------- | --------------------: | :------------------------------- | :-----: |
| A. 集約（グループ）               |        「…ごとに」「平均」「合計」 | SELECT / GROUP BY / HAVING       | ◎（判定簡単） |
| B. LEFT JOIN + NULL処理     | 「～がない場合でも表示」「～が存在しない」 | FROM / JOIN / SELECT（COALESCE）   |    ◎    |
| C. 存在確認（EXISTS）           |       「存在するか」「該当があるか」 | WHERE（EXISTS/NOT EXISTS）         |    ◎    |
| D. NOT INの罠               |         「含まれていない」「除外」 | WHERE（NOT IN） → 要切替              |  △（要注意） |
| E. 最新/上位N件                |              「最新」「上位」 | ORDER BY + LIMIT/FETCH（またはサブクエリ） |    ◎    |
| F. スカラ相関サブクエリ             |         「それぞれのXに対して…」 | SELECT( (SELECT ... ) )          |  △（考慮要） |
| G. FROM句サブクエリ（派生表）        |           「まず集計してから…」 | FROM (SELECT ... ) AS ○○         |  ◎（速攻）  |
| H. JOIN条件の場所（ON vs WHERE） |      「該当がある行だけ」「結合条件」 | JOIN ... ON / WHERE              | ◎（判定簡単） |
| I. 集約＋非集約列ミス              |          「SELECTに複数列」 | SELECT / GROUP BY                |  △（要注意） |

---

## １－５　代表例（正答例・誤答例）

> 各例の前に**評価順**を注記します（ルール厳守）。

### ① パターンA：部署ごとの社員数（GROUP BY）

```
評価順: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

-- 正答
SELECT 部署ID, COUNT(*) AS 社員数
FROM 社員
GROUP BY 部署ID;

-- 誤答（非集約列をGROUP BYに入れ忘れ）
SELECT 部署ID, 社員名, COUNT(*)  -- 社員名はGROUP BYにないのでNG
FROM 社員
GROUP BY 部署ID;
```

### ② パターンB：商品と売上（販売実績がない商品も表示）

```
評価順: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

-- 正答
SELECT 商品.商品ID, 商品.商品名, COALESCE(SUM(注文明細.数量),0) AS 売上数量
FROM 商品 LEFT JOIN 注文明細
  ON 商品.商品ID = 注文明細.商品ID
GROUP BY 商品.商品ID, 商品.商品名;

-- 誤答（INNER JOINで商品が消える）
SELECT 商品.商品ID, SUM(注文明細.数量)
FROM 商品 INNER JOIN 注文明細
  ON 商品.商品ID = 注文明細.商品ID
GROUP BY 商品.商品ID;
```

### ③ パターンC：顧客に注文があるか（EXISTS）

```
評価順: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

-- 正答
SELECT 顧客ID, 顧客名
FROM 顧客
WHERE EXISTS (
  SELECT 1 FROM 注文
  WHERE 注文.顧客ID = 顧客.顧客ID
);

-- 誤答（NOT INでNULLにより全滅の危険）
WHERE 顧客ID NOT IN (SELECT 顧客ID FROM 注文);  -- 注文.顧客IDにNULLがあると危険
```

### ④ パターンE：最新1件（ORDER BY + LIMIT）

```
評価順: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

-- 正答 (SQL標準風)
SELECT *
FROM 注文
ORDER BY 注文日 DESC
FETCH FIRST 1 ROWS ONLY;

-- MySQL風
... ORDER BY 注文日 DESC LIMIT 1;
```

### ⑤ パターンG：FROM句で事前集計（派生表）

```
評価順: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

-- 正答
SELECT 部署別.部署ID, 部署別.社員数
FROM (
  SELECT 部署ID, COUNT(*) AS 社員数
  FROM 社員
  GROUP BY 部署ID
) 部署別
WHERE 部署別.社員数 >= 5;
```

---

## １－６　よくある誤解と正しい知識

(1) **ONとWHEREの混同**
　・ONは「結合の条件」。LEFT JOINでONに条件を入れるかWHEREに入れるかで行残存が変わる。
　・（例）LEFT JOIN ... ON A.id=B.id AND B.状態='有効' と WHERE B.状態='有効' は意味が違う（後者はINNER相当化）。

(2) **WHEREとHAVINGの混同**
　・WHEREは「集約前に行を除外」する。HAVINGは「集約後にグループを除外」する。

(3) **NOT IN vs NOT EXISTS**
　・NOT IN はサブクエリ結果にNULLがあると全体がFALSE/UNKNOWNになり得る。
　・安全策：NOT EXISTS（相関サブクエリ）を使う。

(4) **スカラサブクエリの多返却ミス**
　・SELECT句内に複数行返すサブクエリを書いてしまうミス → MAX/MINで1行に絞るか、WHERE条件で一意化。

(5) **関数従属性の誤用**
　・関数従属性は同一表内での関係（例：社員ID→社員名）。異表間で関数従属性の論理展開を行わない。

(6) **性能感（重い/軽い）**
　・INDEX有り／無し、データ量、結合数、集約回数が性能に影響。
　・一般に：FROM句サブクエリで事前集計は**高速**（集約量を減らす）／相関サブクエリは**低速・重い**（行ごとに走る）ことが多い。

---

## １－７　一問一答（5問：問題→回答→解説）

※テスト形式で「空欄」を (あ) (い) 等で表す。評価順を毎問注記。

### 問1（パターンA：部署ごと社員数）

```
評価順: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

問題：
SELECT (あ), COUNT(*) AS 社員数
FROM 社員
(い) 部署ID;

解答：
(あ) 部署ID
(い) GROUP BY

解説：
「部署ごとに」はGROUP BY。SELECTにある非集約列はGROUP BYに入れる。
```

### 問2（パターンB：商品、売上が無くても表示）

```
評価順: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

問題：
SELECT 商品.商品ID, 商品.商品名, (あ)(注文明細.数量) AS 売上数量
FROM 商品 (い) 注文明細
  ON 商品.商品ID = 注文明細.商品ID
GROUP BY 商品.商品ID, 商品.商品名;

解答：
(あ) COALESCE(SUM(
        -- 完成: COALESCE(SUM(注文明細.数量),0)
(い) LEFT JOIN

解説：
LEFT JOINで売上がない商品はNULLになるためCOALESCEで0に置換する。
```

### 問3（パターンC：注文のある顧客抽出）

```
評価順: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

問題：
SELECT 顧客ID, 顧客名
FROM 顧客
WHERE (あ) (
  SELECT 1 FROM 注文
  WHERE 注文.顧客ID = 顧客.顧客ID
);

解答：
(あ) EXISTS

解説：
存在確認にはEXISTSが簡潔かつNULLに強い。
```

### 問4（パターンD：NOT INの罠→安全解法）

```
評価順: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

問題：
「指定されたキャンセル注文に含まれない商品」を抽出したい。
誤答パターン： WHERE 商品ID NOT IN (SELECT 商品ID FROM 注文明細 WHERE 状態='キャンセル')
安全解答：
SELECT 商品ID FROM 商品 WHERE NOT (あ) (
  SELECT 1 FROM 注文明細
  WHERE 注文明細.商品ID = 商品.商品ID
    AND 注文明細.状態 = 'キャンセル'
);

解答：
(あ) EXISTS ではなく NOT EXISTS を使用： WHERE NOT EXISTS (SELECT 1 ...)

解説：
NOT INはサブクエリにNULLがあると意図しない空集合になる。NOT EXISTSが安全。
```

### 問5（パターンG：FROM句で事前集計）

```
評価順: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

問題：
各部署の社員数を先に求め、社員数が10以上の部署を抽出したい。
SELECT 部署別.部署ID, 部署別.社員数
FROM (
  SELECT 部署ID, COUNT(*) AS 社員数
  FROM 社員
  (あ) 部署ID
) 部署別
WHERE 部署別.社員数 >= 10;

解答：
(あ) GROUP BY

解説：
事前集計はFROM句の派生表（サブクエリ）で行うと後続処理が簡潔かつ高速になる。
```

---

## １－８　要約（3行以内）

(1) 問題文→キーワード→ER図→空欄位置の順で即判定。
(2) 定石は「GROUP BY／LEFT JOIN＋COALESCE／EXISTS／ORDER BY+LIMIT」。
(3) NOT INと相関サブクエリは要注意（NULL／性能）。

---

# ３．図式化ルール（あなた指定のルール厳守）

（１）関係は矢印で表現：`１→多` , `多←１`（例：部署１→多社員）。
（２）ER・プロトコル・プロセスは最少の箱と矢印で描く。
（３）比較は2列または3列の簡易表で示す。

（例：部署と社員）

```
┌─────┐ 1→多 ┌─────┐
│ 部署 │─────>│ 社員 │
└─────┘      └─────┘
```

---

# ４．SQL専用ルール（あなた指定の厳格ルール + 追加説明）

（１）**業務モデル**：例は常に「社員」「部署」「顧客」「商品」「注文」「注文明細」を使用する。
（２）**項目名**：業務日本語（社員名，部署ID，給与 等）。エイリアスも業務日本語で可。
（３）**サブクエリの役割明示と評価順注記**：
　・`FROM句サブクエリ`：事前集計やフィルタ済みの派生表を作る（高速化効果）。
　・`WHERE句サブクエリ（非相関）`：静的除外／包含判定（IN/NOT INの領域）に使う。NULL注意。
　・`スカラサブクエリ`：SELECT句内で1値を返す（相関に注意、多返却はエラー）。
　**必ず** `評価順: FROM→WHERE→GROUP BY→HAVING→SELECT→ORDER BY` を問題解答時に確認。

（４）**関数従属性**：同一表内で扱う。異表間には適用不可（ER設計／正規化の観点）。
（５）**性能感の書き方**：必ず「重い/軽い」「高速/低速」で表現し、原因（データ量，索引有無，結合順，集約回数）を明示する。
　例：相関サブクエリは**低速（重い）**。FROM句で事前集計すれば\*\*高速（軽い）\*\*に改善できる。

---

# ５．評価とフィードバック（採点基準・理解度指標・誤答対策）

（１）**厳格な採点**（1問 = 100点満点換算）
　・正解でかつ最適解（安全策・NULL考慮有） = 100点
　・正解だがNULL/例外考慮欠落 = 80点（減点20）
　・論理的誤り（ON/WHEREやHAVING/WHEREスワップ等）= 0〜40点（重大）

（２）**理解度を3軸で定量表示**（0〜100）
　・再現性（Pattern recall）＝「このパターンを瞬時に再現できるか」
　・誤解率（Mistake probability）＝「ON/WHERE、NOT IN、サブクエリの誤用の頻度」
　・速度（Solve speed）＝「パターン判定から解答までの所要時間（秒）」

（例：学習者A）

```
再現性: 85 / 誤解率: 10 / 速度: 75
```

（３）**誤答の原因分類と再現防止リスト**
　① 原因：本文キーワードの見落とし → 防止：問題文のキーワードを下線1分ルールで抽出。
　② 原因：ONとWHEREの意味混同 → 防止：LEFT JOINの時はONに条件を入れるべきかWHEREに入れるべきかの瞬時チェックリストを利用。
　③ 原因：NOT IN + NULL → 防止：NOT INが見えたら「NULLの有無を想像」→ 安全書き換えNOT EXISTS。
　④ 原因：SELECT内スカラサブクエリが複数行返す → 防止：サブクエリに集約（MAX/MIN）またはTOP/LIMITを付与するルール。

---

# ６．学習法の内在化（業務直結＆体系化＋語源）

（１）**必要性強調**：業務課題に直結させる。例：業務で「未払い顧客抽出」を作る際はNOT EXISTSを使う実務テンプレを覚える。
（２）**体系化（学習テンプレ）**：
　① 上位分類：結合・集約・サブクエリ・NULL処理
　② 下位概念：LEFT/INNER、GROUP BY/HAVING、EXISTS/NOT EXISTS、COALESCE/CASE
　③ 関連技術：インデックス、実行計画、ウィンドウ関数（必要時）
（３）**語源（英語原語等 1–2文）**：
　・SQL = Structured Query Language（構造化問い合わせ言語）。1980年代に標準化。語構成は「構造化された＋問い合わせ＋言語」。

（４）**実践スケジュール（短期）**：
　・Day1〜3：速攻パターン（A・B・C・E・G）を50問で反復（反射化）→ 目標再現性90%
　・Day4〜6：罠パターン（D・F・H・I）を50問で誤答原因潰し→ 目標誤解率10%未満
　・本番前2日：A4チートシートで総復習（問題文→キーワード→パターン表を瞬時に見られる形）

---

# 付録：即効チェックリスト（10ステップ、5〜15秒で走る）

1. 問題文の主要キーワードを下線（→ GROUP BY/LEFT JOIN/EXISTS 等に即対応）。
2. ER図で空欄に関係するテーブルの主キー/外部キーを確認。
3. 空欄の位置を判定（SELECT/ FROM/ WHERE/ JOIN/ GROUP BY/ HAVING/ ORDER BY/ サブクエリ）。
4. 集約関数があれば非集約列がGROUP BYにあるか即確認。
5. LEFT JOINがあればNULL対策（COALESCE/CASE）を探す。
6. 「含まれない/除外」→ NOT IN見つけたらNOT EXISTSで置換を検討。
7. 最新/上位→ ORDER BY + LIMIT/FETCHに直結。
8. ON vs WHERE判定：LEFT JOINで条件がテーブルB側ならONに置く（WHEREだと排除される）。
9. サブクエリが相関か非相関かを判定。相関なら性能/多重評価を想定。
10. 最終チェック：評価順を頭の中で追って返り読み（FROM→WHERE→GROUP BY→HAVING→SELECT→ORDER BY）。

---

もしよければ次のどちらかを即作成します（選択不要なら両方作ります）：
(1) 過去問から抽出した\*\*「速攻パターン」30問＋解答・簡潔解説\*\*（すぐに反復可能）
(2) A4一枚の**チートシート図解（矢印＋表＋代表SQL）**（試験直前用）

どちらを優先しますか？（指示不要の場合、まず(1)を作ります）


了解しました🔥
Mackさんの狙いは「パターン化されたSQL穴埋め問題を、即答できる形で整理」ですね。
→ **反復練習用に “速攻パターン30” を用意し、穴埋め問題→解答→解説 をコンパクトにまとめる**。
試験本番で「これはパターン○番だ」とすぐに当てはめられるようにします。

---

# ✅ 応用情報技術者試験 SQL速攻パターン30

---

## １．集計・GROUP BY 系

**P01** 「部署ごとに社員数」

```sql
SELECT 部署ID, COUNT(*)
FROM 社員
GROUP BY 部署ID;
```

👉 解説：非集約列（部署ID）はGROUP BY必須。

**P02** 「顧客ごとの注文金額合計」

```sql
SELECT 顧客ID, SUM(金額)
FROM 注文
GROUP BY 顧客ID;
```

👉 SUM + GROUP BY。典型。

**P03** 「部署ごとの平均給与30万以上」

```sql
SELECT 部署ID, AVG(給与)
FROM 社員
GROUP BY 部署ID
HAVING AVG(給与) >= 300000;
```

👉 集約後条件はHAVING。

**P04** 「社員全体の平均給与」

```sql
SELECT AVG(給与) FROM 社員;
```

👉 GROUP BY不要（全体で1行）。

**P05** 「顧客ごと・月ごとの注文件数」

```sql
SELECT 顧客ID, EXTRACT(MONTH FROM 注文日), COUNT(*)
FROM 注文
GROUP BY 顧客ID, EXTRACT(MONTH FROM 注文日);
```

👉 GROUP BY複数列。

---

## ２．JOIN 系

**P06** 「社員と部署を結合」

```sql
SELECT 社員名, 部署名
FROM 社員 INNER JOIN 部署
ON 社員.部署ID = 部署.部署ID;
```

👉 JOIN条件はON。

**P07** 「社員がいない部署も表示」

```sql
SELECT 部署ID, COALESCE(COUNT(社員ID),0)
FROM 部署 LEFT JOIN 社員
ON 部署.部署ID = 社員.部署ID
GROUP BY 部署ID;
```

👉 LEFT JOIN + COALESCE。

**P08** 「販売実績がない商品も表示」

```sql
SELECT 商品名, SUM(数量)
FROM 商品 LEFT JOIN 注文明細
ON 商品.商品ID = 注文明細.商品ID
GROUP BY 商品名;
```

👉 本文に「ない場合も」＝LEFT JOIN。

**P09** 「顧客名と注文日を出力」

```sql
SELECT 顧客名, 注文日
FROM 顧客 INNER JOIN 注文
ON 顧客.顧客ID = 注文.顧客ID;
```

👉 典型的1対多。

**P10** 「社員と上司（同じ表）」

```sql
SELECT E.社員名, M.社員名 AS 上司名
FROM 社員 E LEFT JOIN 社員 M
ON E.上司ID = M.社員ID;
```

👉 自己結合パターン。

---

## ３．サブクエリ 系

**P11** 「社員の平均給与より高い社員」

```sql
SELECT 社員名
FROM 社員
WHERE 給与 > (SELECT AVG(給与) FROM 社員);
```

👉 スカラサブクエリ。

**P12** 「最も高い給与の社員」

```sql
SELECT 社員名
FROM 社員
WHERE 給与 = (SELECT MAX(給与) FROM 社員);
```

👉 MAXサブクエリ。

**P13** 「注文がある顧客」

```sql
SELECT 顧客名
FROM 顧客
WHERE EXISTS (SELECT * FROM 注文
              WHERE 顧客.顧客ID = 注文.顧客ID);
```

👉 EXISTS。

**P14** 「注文がない顧客」

```sql
SELECT 顧客名
FROM 顧客
WHERE NOT EXISTS (SELECT * FROM 注文
                  WHERE 顧客.顧客ID = 注文.顧客ID);
```

👉 NOT EXISTS（NULL安全）。

**P15** 「最古の注文日」

```sql
SELECT 注文ID, 注文日
FROM 注文
WHERE 注文日 = (SELECT MIN(注文日) FROM 注文);
```

👉 MINサブクエリ。

---

## ４．NOT IN / NULL 系（罠）

**P16** 「注文がない顧客（誤答例）」

```sql
-- 誤答
WHERE 顧客ID NOT IN (SELECT 顧客ID FROM 注文);
```

👉 サブクエリにNULL混入で全滅。NOT EXISTSが正解。

**P17** 「NULLを0に置換」

```sql
SELECT 商品ID, COALESCE(SUM(数量),0)
FROM 注文明細
GROUP BY 商品ID;
```

👉 LEFT JOIN後のNULL対策。

**P18** 「NULLのとき‘未設定’と表示」

```sql
SELECT COALESCE(部署名,'未設定')
FROM 部署;
```

👉 典型COALESCE。

---

## ５．ORDER BY / TOP N 系

**P19** 「給与が高い順」

```sql
SELECT 社員名, 給与
FROM 社員
ORDER BY 給与 DESC;
```

👉 降順。

**P20** 「最新の注文1件」

```sql
SELECT *
FROM 注文
ORDER BY 注文日 DESC
FETCH FIRST 1 ROW ONLY;
```

👉 最新はDESC。

**P21** 「最古の注文1件」

```sql
ORDER BY 注文日 ASC FETCH FIRST 1 ROW ONLY;
```

**P22** 「上位3人の高給社員」

```sql
SELECT 社員名, 給与
FROM 社員
ORDER BY 給与 DESC
FETCH FIRST 3 ROWS ONLY;
```

---

## ６．条件分岐・CASE 系

**P23** 「給与30万以上→‘高給’」

```sql
SELECT 社員名,
       CASE WHEN 給与 >= 300000 THEN '高給'
            ELSE '通常' END
FROM 社員;
```

**P24** 「数量0なら‘在庫切れ’」

```sql
SELECT 商品名,
       CASE WHEN 在庫数 = 0 THEN '在庫切れ'
            ELSE '在庫あり' END
FROM 商品;
```

---

## ７．その他・応用

**P25** 「社員数を部署ごと＋合計」

```sql
SELECT 部署ID, COUNT(*)
FROM 社員
GROUP BY ROLLUP(部署ID);
```

👉 出題頻度は低いが注意。

**P26** 「重複排除」

```sql
SELECT DISTINCT 部署ID FROM 社員;
```

**P27** 「部署ごと最大給与の社員」

```sql
SELECT 部署ID, MAX(給与)
FROM 社員
GROUP BY 部署ID;
```

**P28** 「商品ごとの注文回数」

```sql
SELECT 商品ID, COUNT(*)
FROM 注文明細
GROUP BY 商品ID;
```

**P29** 「複合主キーでJOIN」

```sql
ON 注文.注文ID = 注文明細.注文ID
AND 注文.顧客ID = 注文明細.顧客ID;
```

**P30** 「FROM句サブクエリ」

```sql
SELECT 顧客ID, 注文件数
FROM (SELECT 顧客ID, COUNT(*) AS 注文件数
      FROM 注文
      GROUP BY 顧客ID) AS 集計
WHERE 注文件数 >= 5;
```

👉 FROM句サブクエリは“集計結果を一時表に”。

---

# ✅ まとめ

* 30パターンに分解すれば、**本文のキーワード＝SQL定石** に即マッチできる。
* 実戦では「これはP○番」と思い出せば**即答モード**に入れる。
* 熟考が必要な応用問題に、時間を回せる。

---

👉 この30パターンを「**A4用チートシート形式（一覧表＋最小SQL例）**」に落とし込みますか？
それとも「**過去問の空欄形式にして穴埋め演習セット**」にしましょうか？
