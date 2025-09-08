**INTERSECT vs INNER JOIN** と **EXCEPT vs LEFT JOIN + IS NULL** 

---

# １　INTERSECT と INNER JOIN の違い

| 観点       | INTERSECT（集合演算）                                             | INNER JOIN（リレーション演算）                                                                 |
| -------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| SQL句     | `sql SELECT 顧客ID FROM 顧客  INTERSECT  SELECT 顧客ID FROM 注文; ` | `sql SELECT 顧客.顧客ID, 顧客.顧客名, 注文.注文日  FROM 顧客  INNER JOIN 注文  ON 顧客.顧客ID = 注文.顧客ID; ` |
| 出力       | 顧客と注文の両方に存在する**顧客IDのみ**                                     | 顧客と注文を横に結合した**詳細データ**                                                                |
| 列数       | 1列（顧客ID）                                                    | 複数列（顧客名・注文日など）                                                                       |
| NULLの扱い  | `NULL= NULL` は一致（両方にNULLなら出力）                               | `NULL= NULL` は偽（JOIN条件ではマッチしない）                                                      |
| 試験の狙いどころ | 「共通するIDだけを出したい」のに JOIN を書いてしまう誤答が多い                         | 「共通する値を抽出したい」のに INTERSECT を使えない受験者が多い                                                |

---

# ２　EXCEPT と LEFT JOIN + IS NULL の違い

| 観点       | EXCEPT（集合演算）                                             | LEFT JOIN + IS NULL（リレーション演算）                                                                      |
| -------- | -------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| SQL句     | `sql SELECT 顧客ID FROM 顧客  EXCEPT  SELECT 顧客ID FROM 注文; ` | `sql SELECT 顧客.顧客ID, 顧客.顧客名  FROM 顧客  LEFT JOIN 注文  ON 顧客.顧客ID = 注文.顧客ID  WHERE 注文.顧客ID IS NULL; ` |
| 出力       | 顧客表にしか存在しない顧客ID                                          | 顧客表にしか存在しない顧客ID＋顧客名                                                                                |
| 列数       | 1列（顧客ID）                                                 | 複数列（顧客ID・顧客名など）                                                                                    |
| NULLの扱い  | `NULL`は一致扱い（両方がNULLなら除外されない）                             | `NULL`判定を利用（IS NULLでマッチしない顧客を抽出）                                                                   |
| 試験の狙いどころ | 「差集合」と「外部結合＋IS NULL」の等価関係を問う                             | 「EXCEPTで済むのにJOINを書いてしまう」誤答が狙われる                                                                    |

---

# ３　図式化イメージ

```
集合演算（INTERSECT / EXCEPT） → 縦方向の比較（値の一致・不一致を判定）
リレーション演算（JOIN + IS NULL） → 横方向に結合し、その後 WHEREで絞り込み
```

---

# ４　一問一答（応用編）

**Q1**：顧客表にあるが注文表にない顧客を求めたい。SQLの書き方2通りは？
**A1**：
① `SELECT 顧客ID FROM 顧客 EXCEPT SELECT 顧客ID FROM 注文;`
② `SELECT 顧客ID FROM 顧客 LEFT JOIN 注文 ON 顧客.顧客ID = 注文.顧客ID WHERE 注文.顧客ID IS NULL;`

**Q2**：INTERSECTはINNER JOINの完全な代替になり得るか？
**A2**：ならない。INTERSECTは「共通する値だけ」、JOINは「共通キーで横に結合する」。

---

