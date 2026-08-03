# Phase A skill and documentation usage

| Skill/source | Command/reference | Adopted conclusion |
| --- | --- | --- |
| harmonyos-cangjie-dev | Complete `SKILL.md` | Incremental pure-Cangjie vertical-slice workflow and evidence gates. |
| cangjie-project-bootstrap | Complete audit instructions | Kept the existing project and both ABI targets; no re-scaffold. |
| cangjie-harmonyos-knowledge | `cjdocs.py doctor`; query `ArkUI Button TextInput state onClick` | Both returned `OperationalError: unable to open database file`; raw packaged docs were used, and no failed query was treated as a result. |
| Packaged NetworkKit docs | `API/NetworkKit/cj-apis-net-http.md`; `Guide/network/cj-http-request.md` | Response headers, cookies, redirect status codes, string response handling, and timeouts used for IDS. |
| Packaged UniversalKeystoreKit docs | `API/UniversalKeystoreKit/cj-apis-security_huks.md`; `Guide/security/UniversalKeystoreKit/cj-huks-encryption-decryption.md` | AES-GCM HUKS key generation, session init/finish, AE tag, random nonce, key existence, and key deletion. |
| Packaged CryptoArchitectureKit docs | `API/CryptoArchitectureKit/cj-apis-crypto.md`; `Guide/security/CryptoArchitectureKit/cj-crypto-generate-random-number.md` | `createRandom().generateRandom(12)` supplies a cryptographically secure GCM nonce. |
| SDK declaration probe | `ohos.arkui.component.text_input.cj.d` and compiler probe | Pure-Cangjie TextInput has no password type member in this SDK; implemented a visual mask and documented the accessibility-tree limitation. |
| cangjie-core-reference | Complete `SKILL.md` | Used `ArrayList<HuksParam>` after the compiler rejected Array concatenation. |
| harmonyos-build-run-diagnose | Hvigor, `ui_capture.py`, `hilog_capture.py` | Completed build/install/launch/component-tree/hilog closure. |
| harmonyos-evolution | Complete `SKILL.md` | Recorded only verified conclusions and kept valid-login items externally blocked. |
