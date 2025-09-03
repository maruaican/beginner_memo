代表例（正答例・誤答例）
要件: 「商品在庫」項目がNULLの場合、「在庫なし」と表示する。
正答例①（COALESCE）
```sql
SELECT 商品名, COALESCE(商品在庫, '在庫なし') AS 在庫状況
FROM 商品表;
解説: 商品在庫がNULLの場合、'在庫なし'に置換されます。商品在庫が非NULLの場合は、その値がそのまま返されます。この要件に最も適した簡潔な記述です。
```
```sql
正答例②（ＣＡＳＥ）
SQL

SELECT 商品名, CASE WHEN 商品在庫 IS NULL THEN '在庫なし' ELSE 商品在庫 END AS 在庫状況
FROM 商品表;
```
解説: 商品在庫 IS NULLという条件に合致した場合に'在庫なし'が返されます。その他の場合（ELSE）は商品在庫の値がそのまま返されます。ＣＯＡＳＣＥと同様の結果を得られますが、より冗長な記述となります。

誤答例（ＣＡＳＥ）
```sql
SELECT 商品名, CASE 商品在庫 WHEN NULL THEN '在庫なし' ELSE 商品在庫 END AS 在庫状況
FROM 商品表;
```
解説: SQLでは= NULLやWHEN NULLではなく、IS NULLまたはIS NOT NULLを使用する必要があります。単純な=演算子はNULLに対しては真偽を返さないため、この式は期待どおりに動作しません。