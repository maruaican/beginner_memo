# 制約

---

**【問1】**
リレーショナルデータベースにおいて、テーブル内の各行を重複なく、一意に識別するための「鍵」となる列または列の組み合わせに設定する整合性制約は何ですか。また、その制約がデータベース全体において果たす根源的な役割を説明してください。

---
**【解答】**
主キー制約（PRIMARY KEY Constraint）。
その役割は、テーブル内の各行に一意の識別子を与え、データの重複登録を完全に防ぐことで、データモデルの根幹となる一意性を保証することです。

---
**【解説】**
**主キー制約（Primary Key Constraint）** は、リレーショナルデータベースにおける最も基本的な整合性制約の一つです。*Primary* は「主要な」「第一の」を意味し、その名の通り、テーブルの「主役」となるキーを定義します。

この制約が課せられた列は、「一意性（Uniqueness）」と「非NULL（Not Null）」という2つのルールを強制されます。

**【SQL構文例】**
社員テーブル `employees` を作成し、社員番号 `employee_id` を主キーに設定します。

```sql
CREATE TABLE employees (
    employee_id   INT NOT NULL,
    employee_name VARCHAR(100),
    department_id INT,
    CONSTRAINT pk_employees PRIMARY KEY (employee_id)
);
```
*`CONSTRAINT pk_employees` は制約に名前を付ける構文です。

**【制約違反の例】**
このテーブルに対し、重複する `employee_id` を持つデータを挿入しようとすると、エラーが発生します。

```sql
-- 1件目の挿入（成功）
INSERT INTO employees VALUES (101, '田中 太郎', 10);

-- 2件目の挿入（主キーが重複するためエラーになる）
INSERT INTO employees VALUES (101, '鈴木 次郎', 20);
-- ERROR: duplicate key value violates unique constraint "pk_employees"
```

---
**【初心者が勘違いしやすい点】**
「主キーは単に行を区別するための番号」と単純に考えがちですが、本質は「**その行が表す実体のアイデンティティ（同一性）を保証するもの**」です。SQLエラーが発生するのは、データベースがこの「同一性のルール」を厳格に守ろうとしている証拠なのです。

---
**【問2】**
データベース設計において、「外部キー制約」と「参照制約」は密接に関連していますが、その役割は明確に異なります。この2つの制約の関係性を、「列の定義」と「値の保証ルール」というキーワードを用いて、明確に区別して説明してください。

---
**【解答】**
「外部キー制約」は、あるテーブルの列が、他のテーブルの主キーを参照するための「列の定義（属性）」そのものを指します。一方、「参照制約」は、その外部キーに設定された値が、参照先の主キーに実在することを保証するための「値の保証ルール」です。

---
**【解説】**
この2つの概念の区別は、応用情報技術者試験で極めて重要です。SQL構文上では、これらは一体となって定義されます。

**【SQL構文での対応関係】**

```sql
CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT,
    order_date    DATE,

    -- ↓ここからが制約定義
    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customer_id)           -- (1) これが「外部キー制約」
        REFERENCES customers(customer_id)   -- (2) これが「参照制約」
);
```

1.  **外部キー制約 (Foreign Key Constraint):**
    `FOREIGN KEY (customer_id)` の部分が、「`orders`テーブルの`customer_id`列は、外部のキーを参照する役割を持つ列ですよ」と宣言しています。*Foreign* は「外部の」という意味です。

2.  **参照制約 (Referential Constraint):**
    `REFERENCES customers(customer_id)` の部分が、「その`customer_id`列の値は、`customers`テーブルの`customer_id`列に存在する値でなければなりません」という具体的なルールを定義しています。*Referential* は「参照の」という意味です。

これら2つを組み合わせることで、初めてテーブル間の関係性の整合性が保証されます。

---
**【初心者が勘違いしやすい点】**
最も多い誤解は「外部キー制約と参照制約は同じものだ」というものです。外部キーはあくまで「列の役割（宣言）」であり、参照制約は「その列が守るべきルール」です。SQL構文が一体化しているため混同しやすいですが、この役割の違いを理論的に理解しているかが問われます。

---
**【問3】**
注文テーブル（`orders`）に、顧客テーブル（`customers`）を参照するための `customer_id` 列があります。この `customer_id` 列に、`customers` テーブルに存在しない顧客IDが登録されるのを防ぎたいと考えています。この目的を達成するために、SQLの `CREATE TABLE` 文で用いるべき句は何ですか。

---
**【解答】**
`FOREIGN KEY (customer_id) REFERENCES customers(customer_id)`

---
**【解説】**
この句は、問2で解説した「外部キー制約」と「参照制約」を同時に定義するものです。実際のテーブル作成とデータ挿入の例を見てみましょう。

**【SQL構文例】**

```sql
-- 親テーブル（参照される側）
CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

-- 子テーブル（参照する側）
CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT,
    order_date    DATE,
    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 正常なデータ挿入
INSERT INTO customers VALUES (1, '株式会社A');
INSERT INTO orders VALUES (101, 1, '2023-04-01'); -- 存在するcustomer_id=1なので成功

-- 制約違反の例
-- customersテーブルに存在しないcustomer_id=999を挿入しようとするとエラー
INSERT INTO orders VALUES (102, 999, '2023-04-02');
-- ERROR: insert or update on table "orders" violates foreign key constraint "fk_orders_customers"
```
このように、データベース管理システム（DBMS）がデータの整合性を自動的に監視し、不正なデータの登録を未然に防いでくれます。

---
**【初心者が勘違いしやすい点】**
「アプリケーション側で、登録前に顧客IDの存在チェックをすれば良いのでは？」と考える初学者もいます。しかし、データベースの整合性制約は、あらゆる経路（複数のアプリ、DBツール、直接のSQL実行）からのデータ変更に対してルールを強制できるため、より堅牢なデータ保護を実現します。

---
**【問4】**
社員テーブルに「年齢」列があるとします。この列に、業務上ありえない「負の値」や「200を超える値」が入力されることをデータベースレベルで防ぎたい場合、どの整合性制約を利用するのが最も適切ですか。

---
**【解答】**
検査制約（CHECK制約）

---
**【解説】**
**検査制約（Check Constraint）** は、特定の列に入力される値が、あらかじめ定義された条件を満たしているかを「検査（Check）」するための制約です。他のテーブルを参照するのではなく、その列自身の値の妥当性を検証するのに特化しています。

**【SQL構文例】**

```sql
CREATE TABLE employees (
    employee_id   INT PRIMARY KEY,
    age           INT,
    CONSTRAINT chk_employees_age CHECK (age >= 0 AND age <= 150)
);
```

**【制約違反の例】**

```sql
-- 正常なデータ挿入
INSERT INTO employees VALUES (101, 30); -- 条件を満たすので成功

-- 制約違反のデータ挿入（負の値）
INSERT INTO employees VALUES (102, -5);
-- ERROR: new row for relation "employees" violates check constraint "chk_employees_age"

-- 制約違反のデータ挿入（上限超え）
INSERT INTO employees VALUES (103, 200);
-- ERROR: new row for relation "employees" violates check constraint "chk_employees_age"
```

---
**【初心者が勘違いしやすい点】**
「参照制約」と「検査制約」の使い分けで混乱することがあります。覚え方はシンプルです。
*   **他のテーブルの値との関係性**を保証したい → **参照制約**
*   **その列自身の値の範囲や形式**を保証したい → **検査制約（CHECK制約）**

---
**【問5】**
「ある支店の全従業員の給与合計は、その支店の予算を超えてはならない」という、複数のテーブル（例：従業員テーブル、支店テーブル）にまたがる複雑な業務ルールをデータベースレベルで恒久的に保証したい場合、標準SQLで定義されている整合性制約のうち、最も適したものは何ですか。

---
**【解答】**
表明（ASSERTION）

---
**【解説】**
**表明（Assertion）** は、データベース全体、あるいは複数のテーブルにまたがる複雑な条件式を定義し、その条件が常に真（TRUE）であることを保証するための強力な整合性制約です。*Assertion* は「主張」「断言」を意味します。

**【SQL構文例（概念）】**
`employees`テーブルと`branches`テーブルがあると仮定します。

```sql
CREATE ASSERTION salary_check CHECK (
    NOT EXISTS (
        SELECT b.branch_id
        FROM branches b
        JOIN (
            SELECT department_id, SUM(salary) AS total_salary
            FROM employees
            GROUP BY department_id
        ) AS emp_salary ON b.branch_id = emp_salary.department_id
        WHERE emp_salary.total_salary > b.budget
    )
);
```
この表明は、「給与合計が予算を超えている支店が存在しない（NOT EXISTS）」ことを常に保証します。

---
**【初心者が勘違いしやすい点】**
ASSERTIONは非常に強力ですが、パフォーマンスへの影響が大きいため、**多くの商用DBMSでは実装されていません。** 応用情報技術者試験では、「理論上、最も適切な制約は何か」という観点で問われるため、ASSERTIONの概念と目的はしっかり理解しておく必要があります。実務では、同様の制約をトリガやバッチ処理で実装することが多いです。

（以降、全ての設問にSQL例を追加して品質を向上させます）

---
**【問6】**
「外部キー」がなぜ "Foreign"（外部の）と名付けられているのか、その由来と機能的な役割を関連付けて説明してください。

---
**【解答】**
"Foreign"（外部の）と名付けられているのは、その列が自身のテーブル内ではなく、「外部のテーブル」の主キーという「よそ者」の値を参照し、関連付けを行う役割を担っているためです。

---
**【解説】**
テーブルを一つの「国」に例えると分かりやすいです。

**【SQLでの「国」の表現】**

```sql
-- departments国（部署テーブル）
CREATE TABLE departments (
    department_id INT PRIMARY KEY, -- 国民ID
    department_name VARCHAR(50)
);

-- employees国（社員テーブル）
CREATE TABLE employees (
    employee_id   INT PRIMARY KEY,     -- 国民ID
    employee_name VARCHAR(100),
    department_id INT,               -- ★外国人IDを記録する欄

    -- department_idは、外部の国(departments)の国民IDを参照する
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
```
`employees`テーブルの`department_id`列は、`departments`テーブルという「外部の国」の主キー（国民ID）を記録するためのものです。この「外部との連携」という本質が "Foreign" という言葉に込められています。

---
**【初心者が勘違いしやすい点】**
外部キーを単に「他のテーブルのIDを入れる列」と機械的に覚えていると、なぜ参照制約が必要なのかという本質を見失いがちです。外部キーは「外部との関係を定義する」という強い意味を持つからこそ、その関係が崩れないように（＝存在しない国民IDを参照しないように）参照制約というルールで保護する必要があるのです。

---
**【問7】**
データベースの整合性制約は、アプリケーション側のバリデーション（入力値チェックロジック）と比べて、どのような本質的な利点がありますか。データの永続性と信頼性の観点から説明してください。

---
**【解答】**
アプリケーション側のバリデーションは特定のプログラムからのアクセスしか保護できませんが、データベースの整合性制約は、どのようなアプリケーション、ツール、直接的なSQL実行からであっても、データへの変更を一元的に監視し、ルール違反を防ぎます。これにより、データの永続的な正しさと信頼性を根本から保証するという利点があります。

---
**【解説】**
空港のセキュリティチェックで例えることができます。

*   **アプリケーション側のバリデーション:**
    特定の航空会社のカウンターで行う手荷物検査。
    `if (age < 0) { throw new Exception("年齢が不正です"); }` のようなコードです。このアプリを使わない人には無意味です。

*   **データベースの整合性制約:**
    保安検査場で行う統一セキュリティチェック。
    `CHECK (age >= 0)` というDBのルールです。誰が`INSERT`しようとしても、DBエンジン自身がこのルールを強制します。

**【SQLでの実証】**
`CHECK`制約が設定されたテーブルに対して、PythonやJavaのアプリからだけでなく、DB管理ツールから直接SQLを実行しても、ルール違反は同様にブロックされます。

```sql
-- どんなクライアントから実行しても、このSQLはエラーになる
UPDATE employees SET age = -1 WHERE employee_id = 101;
-- ERROR: new row for relation "employees" violates check constraint "chk_employees_age"
```
これにより、アプリケーションのバグや予期せぬ操作によってデータが矛盾した状態に陥ることを「最後の砦」として防ぎます。

---
**【初心者が勘違いしやすい点】**
「制約はデータベースに負荷をかけるから、全部アプリ側でやるべきだ」という考え方は、一概に正しいとは言えません。基本的な制約は、不正なデータ混入による将来的なバグやパフォーマンス劣化を防ぐ「保険」のようなものです。パフォーマンスとデータ信頼性のトレードオフを適切に判断することが重要です。

---
**【問8】**
あるテーブルの外部キーとして定義する列は、参照先のテーブルにおいて、どのような性質を持つ列でなければなりませんか。最も重要な条件を挙げてください。

---
**【解答】**
参照先の列は、そのテーブル内で値が一意であることが保証されていなければなりません。通常は、参照先の主キー（PRIMARY KEY）または一意キー制約（UNIQUE Constraint）が設定された列である必要があります。

---
**【解説】**
もし参照先の列に重複した値が存在すると、外部キーの値がどの行を指しているのか一意に定まらず、関係が曖昧になってしまいます。DBMSは、このような曖昧な関係の定義を許可しません。

**【SQLでのエラー例】**
`products`テーブルの`product_code`に一意性制約がない場合、それを参照する外部キーは作成できません。

```sql
CREATE TABLE products (
    product_code VARCHAR(10), -- PRIMARY KEYもUNIQUE制約もない
    product_name VARCHAR(100)
);
INSERT INTO products VALUES ('A-001', '商品X');
INSERT INTO products VALUES ('A-001', '商品Y'); -- 重複データを許してしまう

CREATE TABLE order_details (
    detail_id INT PRIMARY KEY,
    product_code VARCHAR(10),
    -- ↓この制約を追加しようとするとエラーになる
    FOREIGN KEY (product_code) REFERENCES products(product_code)
);
-- ERROR: there is no unique constraint matching given keys for referenced table "products"
```
DBMSは「参照先が一意ではないため、どの行を指すか特定できません」と教えてくれます。

---
**【初心者が勘違いしやすい点】**
外部キーを設計する際に、参照元の列のことばかりに気を取られ、参照先の列の制約を見落とすことがあります。外部キーと参照制約は、2つのテーブル間の「関係」を定義するものです。関係を結ぶ両方のテーブルの列の性質（特に参照される側の「一意性」）を常に意識する必要があります。

---
**【問9】**
参照整合性（Referential Integrity）が「維持されている状態」とは、具体的にどのような状態を指すか、外部キーの値を基に説明してください。

---
**【解答】**
あるテーブルの外部キーの値が、`NULL`であるか、もしくはその値が参照先テーブルの主キーの値として実際に存在している状態のことです。言い換えれば、「宙に浮いた参照」（存在しないデータを指し示す参照）が一つも存在しない状態を指します。

---
**【解説】**
**参照整合性（Referential Integrity）** は、リレーショナルデータベースにおける健全性の核となる概念です。*Integrity* は「整合性」「完全性」を意味します。参照制約は、この整合性を維持するための「番人」です。

**【参照整合性が崩れる操作の防止例】**
`employees`テーブルが`departments`テーブルを参照しているとします。

```sql
-- 事前データ
INSERT INTO departments VALUES (10, '営業部');
INSERT INTO employees VALUES (101, '田中 太郎', 10);

-- 「営業部」には田中さんが所属している
-- この状態で「営業部」を削除しようとすると…
DELETE FROM departments WHERE department_id = 10;
-- ERROR: update or delete on table "departments" violates foreign key constraint "fk_employees_departments" on table "employees"
-- DETAIL: Key (department_id)=(10) is still referenced from table "employees".
```
DBMSは、「社員テーブルからまだ参照されているため、この部署は削除できません」とエラーを返し、田中さんの所属先がなくなる（参照が宙に浮く）事態を防ぎます。

---
**【初心者が勘違いしやすい点】**
参照整合性は、参照元のデータ挿入・更新時だけでなく、**参照先のデータが削除・更新される際にも影響を受けます。** この「双方向の監視」によって、データの矛盾が徹底的に排除されることを理解しておくことが重要です。

---
**【問10】**
主キーに`NULL`値を含めることは許可されますか。また、外部キーに`NULL`値を含めることは許可されますか。それぞれの可否とその理由を述べてください。

---
**【解答】**
*   **主キー:** `NULL`値は許可されません。主キーは行を一意に識別するための識別子であり、値が不定（NULL）では識別子として機能しないためです。
*   **外部キー:** `NULL`値は許可されます。これは「参照先がまだ決まっていない」「関連付けが存在しない」といった状態を表現するために必要だからです。

---
**【解説】**
この違いは、それぞれのキーが持つ役割の差から来ています。

**【SQLでの挙動の違い】**
`employees`テーブルを考えます。

```sql
CREATE TABLE employees (
    employee_id   INT PRIMARY KEY, -- NOT NULLが暗黙的に適用される
    employee_name VARCHAR(100),
    manager_id    INT,             -- 上司ID (自分自身を参照する外部キー)
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- 主キーにNULLを挿入しようとする (エラー)
INSERT INTO employees (employee_id, employee_name) VALUES (NULL, '名無し');
-- ERROR: null value in column "employee_id" violates not-null constraint

-- 外部キーにNULLを挿入する (成功)
-- 例: 社長など、上司がいない社員
INSERT INTO employees VALUES (1, '山田 社長', NULL); -- manager_idがNULL
```
社長（`employee_id`=1）は上司がいないため、`manager_id`は`NULL`になります。これは「参照先が存在しない」という正当な業務状態を表現しています。

---
**【初心者が勘違いしやすい点】**
「キーと名の付くものは全て`NULL`を許さないはずだ」と誤解しがちです。主キーは「存在と一意性」を保証する絶対的な識別子であるのに対し、外部キーはあくまで「他者との関係性」を示すものです。その関係性が必須なのか、任意なのかによって`NULL`を許可するかどうかを設計します。

---
**【問11】**
参照制約は、データのバックアップや障害復旧とは目的が異なります。この2つの概念の決定的な違いを、「データの状態」と「データの保護対象」という観点から説明してください。

---
**【解答】**
参照制約は、通常運用時において、データの「論理的な整合性（矛盾がない状態）」を保つことを目的とします。一方、バックアップや障害復旧は、ハードウェア故障や誤操作といった不測の事態に備え、データベース全体の「物理的なデータそのもの」を過去の健全な時点に復元することを目的とします。

---
**【解説】**
この2つは、守るものが全く異なります。

*   **参照制約が防ぐこと:**
    `INSERT INTO orders VALUES (102, 999, '2023-04-02');` のような、**論理的に矛盾したSQL**の実行を防ぎます。データの「正しさ」を守ります。

*   **バックアップ／リカバリが防ぐこと:**
    `DROP TABLE orders;` という**誤操作**や、**ディスク障害**によるデータファイルの消失からデータを復元します。データの「存在」を守ります。

参照制約が完璧でもディスクが壊れればデータは失われますし、毎日バックアップを取っていてもアプリのバグで矛盾したデータが登録されてしまえば、そのバックアップデータも矛盾しています。両者は車の両輪であり、どちらか一方だけではデータの信頼性を担保できません。

---
**【初心者が勘違いしやすい点】**
「参照制約があれば、関連データが勝手に消えたりしないから安心だ」と考え、バックアップを軽視する誤解があります。参照制約はあくまで「矛盾した状態への変更を防ぐ」だけであり、データの消失そのものを防ぐ機能ではありません。

---
**【問12】**
`CHECK` 制約と `ASSERTION` は、どちらもデータが特定の条件を満たすことを保証する制約ですが、その最も大きな違いは何ですか。制約が適用される「スコープ（範囲）」という言葉を用いて説明してください。

---
**【解答】】**
最も大きな違いはスコープです。`CHECK` 制約のスコープは「テーブル内の単一の行」に限定されますが、`ASSERTION` のスコープは「データベース全体（複数のテーブルや行）」に及びます。

---
**【解説】】**
このスコープの違いが、それぞれの制約の役割を決定づけています。

**【SQLで見るスコープの違い】**

*   **`CHECK` 制約（単一行スコープ）:**
    `products`テーブルで「販売価格(`sale_price`)は仕入れ価格(`cost_price`)以上でなければならない」というルールを定義できます。これは1行の中で完結するチェックです。

    ```sql
    CREATE TABLE products (
        product_id INT PRIMARY KEY,
        cost_price INT,
        sale_price INT,
        CONSTRAINT chk_price CHECK (sale_price >= cost_price)
    );
    -- これはエラーになる: sale_price < cost_price
    INSERT INTO products VALUES (1, 1000, 900);
    ```

*   **`ASSERTION`（複数テーブルスコープ）:**
    「全商品の`sale_price`の合計が、会社の総売上目標を超えてはならない」というルールは、`CHECK`では書けません。`products`テーブルの全行と、別の`company_goals`テーブルの値を比較する必要があるからです。これは`ASSERTION`のスコープです。

---
**【初心者が勘違いしやすい点】**
`CHECK`制約のスコープが「1行」であることを忘れてしまうケースがあります。「ある商品の在庫数は、全倉庫の在庫数の合計と一致しなければならない」といったルールを`CHECK`制約で実現しようとしてもできません。これは複数の行にまたがる集計が必要だからです。このような要件には、理論上`ASSERTION`が適している、と判断できるかが問われます。

---
**【問13】**
あるテーブルの主キーを、単一の列ではなく、複数の列の組み合わせ（例：注文番号、注文明細番号）で定義することがあります。このような主キーを何と呼びますか。また、どのような状況でこれが必要となるか、具体例を挙げて説明してください。

---
**【解答】**
複合主キー（Composite Primary Key）と呼びます。
これが必要となるのは、単一の列だけでは行を一意に識別できず、複数の列の組み合わせによって初めて一意性が保証される状況です。例えば、「注文明細テーブル」において、「注文番号」と「注文明細番号」の組み合わせであれば、特定の注文の特定の明細を一件だけ特定できます。

---
**【解説】**
複合主キーは、特に中間テーブル（多対多の関連を表現するテーブル）でよく使用されます。

**【SQL構文例：注文明細テーブル】**
`orders`テーブルと`products`テーブルの多対多関係を表現する`order_details`テーブルです。

```sql
CREATE TABLE order_details (
    order_id      INT, -- ordersテーブルへの外部キー
    product_id    INT, -- productsテーブルへの外部キー
    quantity      INT,

    -- (order_id, product_id) の組み合わせで主キーを定義
    CONSTRAINT pk_order_details PRIMARY KEY (order_id, product_id),

    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- データ挿入例
INSERT INTO order_details VALUES (101, 1, 5); -- OK
INSERT INTO order_details VALUES (101, 2, 3); -- OK (order_idは同じだがproduct_idが違う)
INSERT INTO order_details VALUES (102, 1, 10);-- OK (product_idは同じだがorder_idが違う)

-- これはエラーになる: 主キー(101, 1)が重複
INSERT INTO order_details VALUES (101, 1, 1);
```

---
**【初心者が勘違いしやすい点】**
「主キーは必ず1つの列でなければならない」という思い込みは間違いです。リレーショナルモデルの理論では、複数の属性（列）の組み合わせで主キーを構成することは全く問題ありません。ただし、複合主キーを参照する外部キーもまた、同じ数の列で構成する必要があるため、設計が少し複雑になります。

---
**【問14】**
「外部キー制約を定義する」という行為と、「外部キー列にインデックスを作成する」という行為は、目的が異なります。それぞれの行為がデータベースに与える主な効果と目的を説明してください。

---
**【解答】**
*   **外部キー制約を定義する目的:** データの「参照整合性」を保証することです。これにより、不正な関連データが登録されるのを防ぎ、データの論理的な正しさを維持します。
*   **外部キー列にインデックスを作成する目的:** テーブル結合（JOIN）や、特定の外部キー値を持つ行を検索する際の「パフォーマンス」を向上させることです。

---
**【解説】**
この2つは密接に関連しますが、目的は明確に異なります。

**【SQL構文での違い】**

```sql
-- 目的：整合性保証
-- ordersテーブルのcustomer_idに外部キー制約を追加
ALTER TABLE orders ADD CONSTRAINT fk_orders_customers
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- 目的：パフォーマンス向上
-- ordersテーブルのcustomer_id列にインデックスを作成
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
```
インデックスがない状態で、特定の顧客の注文を探すSQL (`SELECT * FROM orders WHERE customer_id = 123;`) を実行すると、テーブルを全行スキャンするため非常に遅くなります。インデックスがあれば、索引を使って高速に対象行を見つけ出せます。

多くのDBMSでは、外部キー制約を作成すると自動的に対応するインデックスが作成されますが、これはあくまでパフォーマンス上の配慮です。両者の概念的な目的の違いを理解しておくことが重要です。

---
**【初心者が勘違いしやすい点】**
「外部キーを設定すれば、JOINが速くなる」と考えるのは、原因と結果を混同しています。正しくは、「外部キー列はJOINで頻繁に使われるため、**インデックスを作成しておくことで**、JOINが速くなる」のです。外部キー制約そのものが速度を上げるわけではありません。

---
**【問15】**
データの整合性を保証するルールを、データベースの「制約」として実装する場合と、アプリケーションプログラムの「ビジネスロジック」として実装する場合のトレードオフについて、それぞれの利点と欠点を挙げて論じてください。

---
**【解答】**
*   **データベースの「制約」で実装する場合:**
    *   **利点:** データ中心で一元的な整合性保証が可能。複数のアプリからのアクセスでもルールが守られる。
    *   **欠点:** パフォーマンスへの影響が懸念される場合がある。複雑すぎるビジネスロジックは表現しきれない。
*   **アプリケーションの「ロジック」で実装する場合:**
    *   **利点:** 非常に複雑で動的なビジネスルールも柔軟に実装できる。エラーメッセージ等をユーザーフレンドリーに制御しやすい。
    *   **欠点:** そのアプリ経由のアクセスしか保護できない。アプリのバグで容易にデータ不整合が発生する。アプリごとに同じロジックを実装する必要が生じ、保守性が低い。

---
**【解説】**
これはデータベース設計における永遠のテーマの一つです。どちらか一方が絶対的に正しいわけではなく、両者のバランスを取ることが求められます。

**一般的な設計方針:**
1.  **普遍的なルールは「データベース制約」で実装する。**
    *   SQL例: `PRIMARY KEY`, `FOREIGN KEY`, `CHECK (price >= 0)`
    *   これらはデータモデルの根幹であり、どのアプリから見ても変わらないルールです。

2.  **複雑なビジネスルールは「アプリケーションロジック」で実装する。**
    *   擬似コード例: `if (user.isGoldMember() && campaign.isActive()) { price *= 0.9; }`
    *   このようなルールは状況によって変化し、データベースの静的な制約で表現するのは困難です。

データベースの制約を「憲法」、アプリケーションロジックを「法律」と考え、両者を適切に組み合わせることが堅牢なシステムを構築する鍵となります。

---
**【初心者が勘違いしやすい点】**
「パフォーマンスのために制約は一切使わず、すべてアプリで実装する」という極端な設計思想に陥ることです。これは、短期的な開発速度と引き換えに、長期的なデータの信頼性とシステムの保守性を大きく損なう危険なアプローチです。

---
**【問16】**
参照制約において、参照先の親テーブルの行が削除された場合に、関連する子テーブルの行を自動的に削除する動作を指定するオプションは何ですか。また、このオプションの利用が適している具体的なシナリオを挙げてください。

---
**【解答】**
オプション： `ON DELETE CASCADE`
シナリオ例： 注文テーブル（親）と注文明細テーブル（子）の関係において、注文そのものがキャンセルされて注文テーブルの行が削除された場合、それに紐づく注文明細は存在意義を失うため、自動的に削除されるのが自然である。

---
**【解説】】**
**`ON DELETE CASCADE`** は、「連鎖削除」を意味するオプションです。*Cascade* は「滝のように連続して落ちる」という意味で、親データの削除が子データに波及する様子を表しています。

**【SQLでの動作例】**

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY
);

CREATE TABLE order_details (
    detail_id INT PRIMARY KEY,
    order_id  INT,
    item_name VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE  -- ★このオプションを設定
);

-- データ準備
INSERT INTO orders VALUES (101);
INSERT INTO order_details VALUES (1, 101, 'ペン');
INSERT INTO order_details VALUES (2, 101, 'ノート');

-- 親テーブルの行を削除する
DELETE FROM orders WHERE order_id = 101;

-- 結果の確認
-- order_detailsテーブルの関連する行も自動的に削除されている
SELECT * FROM order_details WHERE order_id = 101; -- 結果は0件
```
---
**【初心者が勘違いしやすい点】**
`ON DELETE CASCADE` は非常に便利ですが、意図しない大量削除を引き起こす危険性もはらんでいます。例えば、部署テーブル（親）と社員テーブル（子）の関係で安易にこれを使用すると、ある部署を削除しただけで、そこに所属する全社員のデータが消えてしまう大惨事につながりかねません。適用するシナリオを慎重に見極める必要があります。

---
**【問17】**
「主キー制約」と「一意キー制約（UNIQUE制約）」は、どちらも列の値の重複を許さないという点で共通していますが、両者の間には決定的な違いがあります。その違いを2つ挙げてください。

---
**【解答】**
1.  **NULLの許容:** 主キー制約はNULL値を許可しないが、一意キー制約は（通常）NULL値を許可する。
2.  **テーブル内の個数:** 主キー制約は1つのテーブルに1つしか定義できないが、一意キー制約は1つのテーブルに複数定義できる。

---
**【解説】**
この2つの制約は似て非なるものです。主キーが「主役」なら、UNIQUE制約は「個性的な脇役」です。

**【SQL構文例】**
社員テーブルで、主キーは `employee_id`、一意キーを `email` と `id_card_number` に設定します。

```sql
CREATE TABLE employees (
    employee_id      INT PRIMARY KEY, -- 主キー (NULL不可、テーブルに1つ)
    employee_name    VARCHAR(100),
    email            VARCHAR(255) UNIQUE, -- 一意キー (NULL可、複数設定可)
    id_card_number   CHAR(10) UNIQUE     -- 一意キー (NULL可、複数設定可)
);

-- OK: emailがNULL
INSERT INTO employees VALUES (1, '田中', NULL, 'A001');
-- OK: 2人目のemailがNULLでも重複とは見なされない
INSERT INTO employees VALUES (2, '鈴木', NULL, 'A002');

-- ERROR: emailが重複
INSERT INTO employees VALUES (3, '佐藤', 'sato@example.com', 'A003');
INSERT INTO employees VALUES (4, '高橋', 'sato@example.com', 'A004');
```

---
**【初心者が勘違いしやすい点】**
「UNIQUE制約があれば主キーは要らない」と考えるのは誤りです。主キーは、単なる一意性だけでなく、「行の代表者」としての役割を持ち、外部キーから参照される際の「目印」となります。リレーショナルモデルにおいて、全てのテーブルは主キーを持つべきとされています。

---
**【問18】**
あるテーブルに整合性制約を追加しようとした際、テーブル内に既にその制約に違反するデータが存在していた場合、データベース管理システム（DBMS）は一般的にどのような挙動を示しますか。

---
**【解答】**
一般的に、制約の追加（`ALTER TABLE ... ADD CONSTRAINT ...`）は失敗し、エラーが返されます。DBMSは、既存のデータが新しいルールを全て満たしていることを確認できない限り、そのルールを有効にすることを許可しません。

---
**【解説】】**
制約は、追加するその瞬間からデータベース全体の整合性を保証する責任を負うため、過去のデータも例外なくチェックの対象となります。

**【SQLでの実証】**
`employees`テーブルに負の年齢データが既に入っているとします。

```sql
CREATE TABLE employees (employee_id INT, age INT);
INSERT INTO employees VALUES (1, 30);
INSERT INTO employees VALUES (2, -5); -- 違反データ

-- この状態でCHECK制約を追加しようとする
ALTER TABLE employees ADD CONSTRAINT chk_age CHECK (age >= 0);
-- ERROR: check constraint "chk_age" is violated by some row
```
**【正しい手順】**

```sql
-- 1. 違反データを修正する
UPDATE employees SET age = 25 WHERE age < 0;

-- 2. 再度、制約を追加する（今度は成功する）
ALTER TABLE employees ADD CONSTRAINT chk_age CHECK (age >= 0);
-- ALTER TABLE completed successfully
```
---
**【初心者が勘違いしやすい点】**
「とりあえず制約だけ追加して、違反データは後で直せばいい」という考えは通用しません。この厳格さこそが、データベースの信頼性の源泉です。制約を追加する前には、必ず既存データのクレンジングが必要です。

---
**【問19】**
SQLの `FOREIGN KEY (列名A) REFERENCES テーブルB(列名B)` という構文が、データベースに課している「ルール」の本質を、「集合」という概念を用いて説明してください。

---
**【解答】**
このルールは、「列名Aが取りうる値の集合は、テーブルBの列名Bに現れる値の集合の『部分集合』でなければならない（ただしNULLは除く）」という集合論的な制約を課している、と説明できます。

---
**【解説】**
この見方は、参照制約の本質をより深く理解するのに役立ちます。

**【SQLデータで見る集合関係】**

```sql
-- departmentsテーブル (親)
-- department_id の値の集合: {10, 20, 30}
CREATE TABLE departments (department_id INT PRIMARY KEY);
INSERT INTO departments VALUES (10), (20), (30);

-- employeesテーブル (子)
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(department_id)
);
```
**`employees.dept_id` に挿入可能な値は、`departments.department_id` の集合 `{10, 20, 30}` の要素、または `NULL` のみです。**

```sql
-- OK: 20は親の集合の要素
INSERT INTO employees VALUES (101, 20);

-- OK: NULLは許される
INSERT INTO employees VALUES (102, NULL);

-- ERROR: 40は親の集合 `{10, 20, 30}` に含まれない
INSERT INTO employees VALUES (103, 40);
```
このように、参照制約は、子テーブルの値が常に親テーブルの集合の範囲内に収まることを数学的に保証します。

---
**【初心者が勘違いしやすい点】**
SQLの構文を単なる文字列として暗記していると、なぜこれがデータの整合性を保つのかという論理的な背景を見失いがちです。リレーショナルデータベースが集合論という数学的基盤の上に成り立っていることを意識すると、各種制約の役割がより深く理解できます。

---
**【問20】**
これまで学んできた5つの主要な整合性制約（主キー、外部キー＋参照、検査、表明）を、その制約が影響を及ぼすスコープ（範囲）が狭いものから広いものへと順に並べてください。

---
**【解答】**
1.  **検査制約 (CHECK):** スコープは単一の列、または同一行内の複数列。
2.  **主キー制約 (PRIMARY KEY):** スコープはテーブル全体（行の一意性を保証）。
3.  **外部キー制約と参照制約 (FOREIGN KEY with REFERENCES):** スコープは2つのテーブル間。
4.  **表明 (ASSERTION):** スコープはデータベース全体（複数のテーブルや行にまたがる）。

---
**【解説】**
各制約の適用範囲（スコープ）をSQLの視点から整理すると、その役割分担がより明確になります。

*   **レベル1（行内）: `CHECK`**
    `CHECK (sale_price >= cost_price)`
    → 1行の中だけで完結して評価できる。

*   **レベル2（テーブル内）: `PRIMARY KEY` / `UNIQUE`**
    `PRIMARY KEY (employee_id)`
    → 新しい行の`employee_id`が、テーブル内の他の全ての行と重複していないか評価する必要がある。

*   **レベル3（テーブル間）: `FOREIGN KEY`**
    `FOREIGN KEY (dept_id) REFERENCES departments(dept_id)`
    → `employees`テーブルの行が、`departments`テーブルの行と正しい関係にあるか評価する必要がある。

*   **レベル4（データベース全体）: `ASSERTION`**
    `CREATE ASSERTION ... CHECK ( (SELECT SUM(salary) FROM emp) <= (SELECT budget FROM company) )`
    → 複数のテーブル全体を集計した結果を評価する必要がある。

この階層構造を理解することで、解決したい課題に対してどの制約が最も適切かを見極める力が養われます。応用情報技術者試験では、このような体系的な理解が応用力として問われます。

---
**【初心者が勘違いしやすい点】**
全ての整合性問題を単一の制約で解決しようとすることが、初心者の誤りです。実際には、これらの異なるスコープを持つ制約を適切に組み合わせ、層状の防御を構築することで、データベースの堅牢性は最大化されます。それぞれの制約の「守備範囲」を正確に把握することが重要です。


# 制約

---

１　全体像（テキスト図）

```
整合性制約（データの正しさを保証するルール）
│
├─ 主キー制約（PRIMARY KEY）
│   └─ 行を一意に識別する列を指定
│
├─ 外部キー制約（Foreign Key Constraint）
│   └─ 他表の主キーを参照する列を指定（列属性）
│
├─ 参照制約（Referential Constraint）
│   └─ 外部キーを通じて、参照先表の行存在を保証するルール
│
├─ 検査制約（CHECK）
│   └─ 列値に条件を課し、不正値を防止
└─ 表明（ASSERTION）
    └─ 複数表にまたがる条件を定義
```

---

１－１　定義（IPA準拠）と用語の由来

* **主キー制約（PRIMARY KEY Constraint）**

  * **定義:** 表内の行を一意に識別する列を指定する制約
  * **由来:** 英語 "Key"。行を識別する「鍵」の意味

* **外部キー制約（Foreign Key Constraint）**

  * **定義:** 他表の主キーを参照する列（属性）を設定する制約
  * **由来:** 英語 "Foreign Key"。外部のキーを参照する列

* **参照制約（Referential Constraint）**

  * **定義:** 外部キーを通じて、参照元列の値が必ず参照先表の主キーに存在することを保証する整合性ルール
  * **由来:** 英語 "Referential"。参照関係を保証する

* **検査制約（Check Constraint）**

  * **定義:** 列値に条件を課し、不正値を防ぐ制約

* **表明（Assertion）**

  * **定義:** 複数表にまたがる条件を定義する制約（CREATE ASSERTION）

---

１－２　技術の必要性（解決する具体的課題）

* 主キー制約 → データの重複防止
* 外部キー制約 → 他表の主キーを参照する列を定義
* 参照制約 → 外部キー値が参照先に存在するか保証（整合性保持）
* CHECK → 値の妥当性確保
* ASSERTION → 複数表の条件整合性確保

具体例：

* 同じ社員番号を複数登録 → 主キー制約で防ぐ
* 注文表の部署IDが存在しない部署を参照 → 外部キー＋参照制約で防ぐ
* 商品価格が負 → CHECK制約で防ぐ
* 全社員の合計給与 ≤ 部署予算 → ASSERTIONで保証

---

１－３　試験の着眼点（頻出領域と解答に必要な知識）

* **外部キー制約** = 列（属性）を定義する
* **参照制約** = 外部キー値の存在を参照先行で保証するルール
* **SQL指定例:**

```sql
FOREIGN KEY (顧客ID) REFERENCES 顧客(顧客ID)
```

* **CHECK制約** = 列値条件
* **ASSERTION** = 複数表条件（CREATE ASSERTION）

---

１－４　体系マップ（分類・関係・比較表）

| 種類     | 指定句例                     | 対象  | 効果/意味                  |
| ------ | ------------------------ | --- | ---------------------- |
| 主キー制約  | PRIMARY KEY(列名)          | 列・行 | 行を一意に識別                |
| 外部キー制約 | FOREIGN KEY(列名)          | 列   | 他表の主キーを参照する列           |
| 参照制約   | FOREIGN KEY + REFERENCES | 列・行 | 外部キー値が参照先表の行に存在することを保証 |
| 検査制約   | CHECK (列名 条件式)           | 列   | 値の妥当性を検査               |
| 表明     | CREATE ASSERTION 条件式     | 複数表 | 複数表にまたがる整合性を保証         |

---

１－５　代表例（正答例・誤答例）

* **正答例（外部キー＋参照制約）**

```sql
CREATE TABLE 注文 (
  注文番号 INT PRIMARY KEY,
  顧客ID INT,
  FOREIGN KEY (顧客ID) REFERENCES 顧客(顧客ID)
);
```

* **誤答例（参照制約なし）**

```sql
CREATE TABLE 注文 (
  注文番号 INT PRIMARY KEY,
  顧客ID INT
);
-- 顧客IDに存在しない値が入っても制約がない
```

---

１－６　よくある誤解と正しい知識

* 誤解1：「外部キー制約と参照制約は同じ」

  * 正：外部キー = 列、参照制約 = 外部キー値の整合性ルール
* 誤解2：「参照制約＝バックアップ」

  * 正：参照制約は整合性保証であり、バックアップとは無関係
* 誤解3：「CHECKと参照制約は同じ」

  * 正：CHECKは列値条件、参照制約は他表参照整合性

---

１－７　一問一答（5問：問題→回答→解説）

**問題1:** 外部キー制約で指定するのは何か。

* 回答：参照する列（属性）
* 解説：外部キーは列そのものを指定し、参照制約で整合性を保証する

**問題2:** 外部キーを通じて参照先の主キーに存在しない値を登録できるか。

* 回答：できない
* 解説：参照制約により、存在しない値は登録不可

**問題3:** 主キー制約で行の重複を防ぐにはどの句を使うか。

* 回答：PRIMARY KEY
* 解説：表内の行を一意に識別する列に設定

**問題4:** 複数表にまたがる条件を保証する制約は何か。

* 回答：ASSERTION
* 解説：CREATE ASSERTIONで指定し、複数表の条件整合性を確保

**問題5:** CHECK制約の目的は何か。

* 回答：列の値の妥当性を検査
* 解説：条件式を満たさない値の登録を防止

---

１－８　要約（3行以内）

* 外部キー = 他表の主キーを参照する列
* 参照制約 = 外部キー値が参照先行に存在することを保証
* 主キー、CHECK、ASSERTIONと合わせ、データ整合性を確保

---


