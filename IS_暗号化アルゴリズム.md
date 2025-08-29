# 暗号化アルゴリズムの種類と用途（WPAを含む・全面改訂）

## １　全体像（テキスト図）

```
暗号の全体像
  ├─ アルゴリズム（方式）
  │    ├─ 共通鍵（対称）：AES（ブロック），RC4（ストリーム） など
  │    ├─ 公開鍵（非対称）：RSA，ECC（ECDH/ECDSA），DSA
  │    ├─ ハッシュ／MAC：SHA-2/SHA-3，HMAC
  │    ├─ 暗号利用モード：CBC，CTR，GCM，CCM，XTS（ディスク）
  │    └─ 鍵導出：PBKDF2 など
  │
  └─ プロトコル（利用先）
       ├─ TLS/HTTPS，IPsec，SSH
       ├─ 無線LAN：WEP → WPA（TKIP） → WPA2（AES-CCMP） → WPA3（SAE＋CCMP/GCMP）
       ├─ メール：S/MIME，PGP
       └─ ストレージ：BitLocker等（AES-XTS）
         （関係：１つのプロトコル → 多数のアルゴリズムを組合せて使用：１→多）
```

---

## １－１　定義（IPA準拠）と用語の由来

* **共通鍵暗号方式（対称鍵暗号）**
  　定義：暗号化と復号に**同一の鍵**を用いる方式。大量データの暗号化を**高速**に行う。
  　由来：symmetric「対称的」＝同じ鍵を双方で共有。

* **公開鍵暗号方式（非対称鍵暗号）**
  　定義：暗号化と復号に\*\*異なる鍵（公開鍵・秘密鍵）\*\*を用いる方式。**鍵配送・電子署名・認証**に利用。
  　由来：asymmetric「非対称」＝鍵が対になり役割が異なる。

* **ハッシュ関数／メッセージ認証コード（MAC）**
  　定義：任意長データから固定長の要約（ハッシュ）を計算。HMACは鍵付きで**改ざん検出**に利用。
  　由来：hash「刻む・混ぜる」、MACは Message Authentication Code。

* **ディジタル署名**
  　定義：送信者の**秘密鍵**で生成し、受信者が**公開鍵**で検証する**本人性・完全性・否認防止**の仕組み。
  　由来：signature「署名」。

* **鍵交換（DH/ECDH）**
  　定義：通信路を盗聴されても共有鍵を**安全に合意**する手続。
  　由来：Diffie–Hellman の提案者名。

* **暗号利用モード（CBC／CTR／GCM／CCM／XTSなど）**
  　定義：ブロック暗号を**実用に用いる運用形態**。GCM/CCMは**認証付き暗号（AEAD）**。XTSは**ディスク暗号化**向け。

* **WPA/WPA2/WPA3（無線LANの保護方式）**
  　定義：IEEE 802.11系無線LANで、暗号と認証を組み合わせた**保護フレームワーク**。
  　・WPA：TKIP（RC4）を利用。
  　・WPA2：AES-CCMPが**必須**。
  　・WPA3：**SAE**で認証、暗号は**CCMP/GCMP**（機器・モードにより）を使用。([ウィキペディア][1], [Cisco][2])

---

## １－２　技術の必要性（解決する具体的課題）

* **共通鍵**：業務データ・通信データを**高速**に秘匿したい。
* **公開鍵**：**安全な鍵配送**・**署名**・**認証**を行いたい。
* **ハッシュ／HMAC**：**改ざん検出**と**整合性**を保証したい。
* **AEAD（GCM/CCM）**：**暗号化と認証を同時**に満たしたい。
* **XTS**：ストレージの**ランダムアクセス**特性に適した暗号化を行いたい。
* **WPA系**：無線LANで**盗聴・なりすまし・辞書攻撃**を抑止したい（WPA3はPSKの弱点をSAEで緩和）。([SecureW2][3])

---

## １－３　試験の着眼点（頻出領域と解答に必要な知識）

* **速度と用途**
  　共通鍵＝**高速**（本体データ暗号化）。公開鍵＝**低速**（鍵交換・署名・証明書）。
* **アルゴリズムとプロトコルの区別**
  　AES・RSAは**アルゴリズム**、TLS・IPsec・**WPA**は**プロトコル**。混同は**誤答**。
* **無線LANの年代順と中身**
  　WEP（RC4） → WPA（TKIP/RC4） → **WPA2（AES-CCMP）** → **WPA3（SAE＋CCMP/GCMP）**。([ウィキペディア][4], [Cisco][2])
* **AEADの理解**
  　GCM/CCMは「**暗号＋改ざん検出**」を同時提供。CBC単体は改ざん検出を**提供しない**。
* **試験作成者が狙う誤解（誰が何を狙うか）**
  　（１）試験作成者は、受験者が\*\*「RSAで大量データを暗号化」**と誤解する点を狙う。
  　（２）試験作成者は、受験者が**「WPA＝AES」\*\*と短絡し、\*\*WPA（TKIP）とWPA2（AES-CCMP）\*\*を取り違える点を狙う。([ウィキペディア][5])

---

## １－４　体系マップ（分類・関係・比較表）

### （Ａ）アルゴリズムの分類

| 区分         | 代表アルゴリズム               | 主な用途                | 処理特性         |
| ---------- | ---------------------- | ------------------- | ------------ |
| 共通鍵（ブロック）  | **AES**                | データ本体，VPN，ディスク（XTS） | **高速**       |
| 共通鍵（ストリーム） | **RC4**（現在は非推奨）        | 旧WEP/WPA            | 高速（設計上の弱点あり） |
| 公開鍵（暗号・署名） | **RSA**，**ECC（ECDSA）** | 鍵配送，署名，証明書          | **低速**       |
| 鍵共有        | **DH／ECDH**            | 共有鍵合意               | 中速           |
| ハッシュ／MAC   | **SHA-2/3**，**HMAC**   | 改ざん検出               | 高速           |
| AEADモード    | **GCM**，**CCM**        | 暗号＋認証（TLS, WPA2/3）  | 高速           |
| ディスク向け     | **XTS**                | ストレージ暗号化            | 高速           |

### （Ｂ）プロトコル → 内部で主に使うアルゴリズムの対応

| プロトコル           | 認証／鍵交換                                   | 機密性・完全性（例）                    | 要点                                                 |
| --------------- | ---------------------------------------- | ----------------------------- | -------------------------------------------------- |
| **TLS 1.2/1.3** | ECDHE＋証明書（RSA/ECDSA）                     | AES-**GCM**／ChaCha20-Poly1305 | 本体は共通鍵，証明は公開鍵                                      |
| **IPsec（ESP）**  | IKEv2（DH/ECDH）                           | AES-CBC／AES-GCM＋HMAC          | ネットワーク層保護                                          |
| **SSH**         | ECDH                                     | AES-CTR/GCM＋MAC               | 管理系通信                                              |
| **WEP**         | 共有鍵                                      | **RC4**＋CRC-32                | 脆弱（非推奨） ([ウィキペディア][4])                             |
| **WPA**         | PSK or 802.1X/EAP                        | **TKIP（RC4）**                 | WEPの暫定改良 ([ウィキペディア][5])                            |
| **WPA2**        | PSK or 802.1X/EAP                        | **AES-CCMP**（必須）              | 802.11i準拠 ([ウィキペディア][1])                           |
| **WPA3**        | **SAE**（Personal），802.1X/EAP（Enterprise） | **CCMP/GCMP**                 | オフライン辞書攻撃に強化 ([NetAlly CyberScope][6], [Cisco][2]) |
| **S/MIME／PGP**  | 署名（RSA/ECDSA）                            | AES等＋HMAC                     | メール保護                                              |
| **ディスク暗号**      | －                                        | **AES-XTS**                   | ランダムI/O向き                                          |

---

## １－５　代表例（正答例・誤答例）

* **正答例**
  ① 大量データの暗号化には**AES**などの共通鍵を用いる。
  ② **WPA2**の暗号は**AES-CCMP**である。([ウィキペディア][1])
  ③ **WPA3-Personal**の認証は**SAE**である。([NetAlly CyberScope][6])

* **誤答例**
  ① 「RSAは高速なので本体データ暗号化に使う」→ **誤り**（公開鍵は低速、用途は鍵交換・署名）。
  ② 「WPA＝AES」→ **誤り**（WPAは**TKIP/RC4**、AES-CCMPは**WPA2**）。([ウィキペディア][5])
  ③ 「WEPはAESを使う」→ **誤り**（WEPは**RC4**）。([ウィキペディア][4])

---

## １－６　よくある誤解と対処

* **誤解１**：「アルゴリズム名＝プロトコル名」
  **対処**：AES/RSAは**部品**，WPA/TLSは**枠組み**と区別する。

* **誤解２**：「CBCは暗号化だけで十分」
  **対処**：**改ざん検出**を別途（HMAC等）で付与。AEAD（GCM/CCM）なら同時に満たす。

* **誤解３**：「WPA2でもPSKなら弱い」
  **対処**：**弱いパスフレーズ**は**辞書攻撃**に弱い。長く複雑にする。WPA3-Personalは**SAE**で耐性が向上。([SecureW2][3])

---

## １－７　一問一答（5問：問題→回答→解説）

**問１**
TLSで**本体データ**の暗号化に主として使う方式はどれか。
**回答**：共通鍵暗号（例：AES-GCM）。
**解説**：公開鍵は主に鍵交換・署名。データ本体は**共通鍵で高速**に暗号化する。

**問２**
無線LANの**WPA2**で必須の暗号はどれか。
**回答**：AES-**CCMP**。
**解説**：WPA2は802.11i準拠でCCMPが**必須**。WPA（無印）は**TKIP/RC4**。([ウィキペディア][1])
（紛らわしい誤答例：「WPA2＝TKIP」）

**問３**
**WPA3-Personal**の認証方式として正しいものはどれか。
**回答**：**SAE**（パスワード認証の改良型）。
**解説**：PSKの代替で、オフライン辞書攻撃への耐性が向上。([NetAlly CyberScope][6], [SecureW2][3])
（紛らわしい誤答例：「PSK」）

**問４**
**WEP**が用いる暗号アルゴリズムはどれか。
**回答**：**RC4**。
**解説**：WEPはRC4＋CRC-32であり、設計上の脆弱性が知られる。([ウィキペディア][4])
（紛らわしい誤答例：「AES」）

**問５**
**RSA**の主用途として最も適切なものはどれか。
**回答**：**鍵配送（鍵カプセル化）や電子署名**。
**解説**：RSAは**低速**であり、大量データの暗号化には適さない。データ本体はAES等を使う。

---

## １－８　要約（3行以内）

* 暗号は「共通鍵・公開鍵・ハッシュ/MAC・利用モード」で構成され、**プロトコル**がそれらを組み合わせる。
* 無線LANは「WEP（RC4）→WPA（TKIP）→**WPA2（AES-CCMP）→WPA3（SAE＋CCMP/GCMP）**」の順に強化。
* 試験は**用途の対応**と**アルゴリズム／プロトコルの区別**、**AEADの理解**を問う。

---

※出典（要点のみ）：
802.11iとCCMP必須・WPA2の位置づけ（IEEE 802.11i/WPA2）([ウィキペディア][1])／WEPはRC4（設計の弱さ）([ウィキペディア][4])／WPAはTKIP（RC4）・WPA2はCCMP（AES）([ウィキペディア][5])／WPA3はSAE採用・辞書攻撃耐性強化、暗号にCCMP/GCMPが用いられること ([NetAlly CyberScope][6], [Cisco][2])

必要な要素（WPAを含む）を網羅して再構成しました。次は「AEAD（GCM/CCM）とCBC＋HMACの比較」を掘り下げると、設問対応力がさらに上がります。

[1]: https://en.wikipedia.org/wiki/IEEE_802.11i-2004?utm_source=chatgpt.com "IEEE 802.11i-2004"
[2]: https://www.cisco.com/c/en/us/td/docs/wireless/controller/ewc/17-15/config-guide/ewc_cg_17_15/m_wpa3_security_enhancements.pdf?utm_source=chatgpt.com "[PDF] WPA3 Security Enhancements for Access Points - Cisco"
[3]: https://www.securew2.com/blog/wpa3-vs-wpa2?utm_source=chatgpt.com "WPA3 vs WPA2: What's the Difference? - SecureW2"
[4]: https://en.wikipedia.org/wiki/Wired_Equivalent_Privacy?utm_source=chatgpt.com "Wired Equivalent Privacy - Wikipedia"
[5]: https://en.wikipedia.org/wiki/Wi-Fi_Protected_Access?utm_source=chatgpt.com "Wi-Fi Protected Access"
[6]: https://cyberscope.netally.com/blog/what-wireless-security-types-are-there-cyberscope-explains?utm_source=chatgpt.com "What wireless security types are there? - CyberScope - NetAlly"
