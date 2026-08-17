package ohos_app_cangjie_entry.repository.auth

// 会话持久化加密边界，避免账号凭据和 Cookie 以明文写入本地存储。

import kit.CryptoArchitectureKit.*
import kit.UniversalKeystoreKit.*
import std.collection.*

// Keeps the AES key inside HUKS. Preferences only receives a random nonce and
// authenticated ciphertext, never the Ehall cookie header in plaintext.
// 加解密失败必须由调用方视为不可恢复会话，不能降级为明文存储。
public class SecureSessionCipher {
    static let keyAlias: String = "xdyou.ehall.session.v1"
    static let associatedData: Array<UInt8> = "XDYou:EhallSession:v1".toArray()
    static let version: String = "huks-gcm-v1"

    public static func encrypt(plainText: String): String {
        if (plainText == "") { throw Exception("Refusing to encrypt an empty session") }
        SecureSessionCipher.ensureKey()
        let nonce = createRandom().generateRandom(12).data
        let options = HuksOptions(
            properties: SecureSessionCipher.cryptProperties(true, nonce, []),
            inData: plainText.toArray()
        )
        let handle = initSession(SecureSessionCipher.keyAlias, options).handle
        let cipherText = finishSession(handle, options).getOrThrow()
        return SecureSessionCipher.version + ":" + IDSPasswordCipher.toBase64(nonce) + ":" + IDSPasswordCipher.toBase64(cipherText)
    }

    public static func decrypt(payload: String): String {
        let parts = payload.split(":")
        if (parts.size != 3 || parts[0] != SecureSessionCipher.version) {
            throw Exception("Unsupported secure session payload")
        }
        let nonce = IDSPasswordCipher.decodeBase64(parts[1])
        let cipherText = IDSPasswordCipher.decodeBase64(parts[2])
        if (nonce.size != 12 || cipherText.size <= 16) { throw Exception("Invalid secure session payload") }
        if (!hasKeyItem(SecureSessionCipher.keyAlias, HuksOptions())) {
            throw Exception("Secure session key is unavailable")
        }
        let options = HuksOptions(
            properties: SecureSessionCipher.cryptProperties(false, nonce, cipherText),
            inData: cipherText.slice(0, cipherText.size - 16)
        )
        let handle = initSession(SecureSessionCipher.keyAlias, options).handle
        let plainText = finishSession(handle, options).getOrThrow()
        return String.fromUtf8(plainText)
    }

    public static func deleteKey(): Unit {
        if (hasKeyItem(SecureSessionCipher.keyAlias, HuksOptions())) {
            deleteKeyItem(SecureSessionCipher.keyAlias, HuksOptions())
        }
    }

    static func ensureKey(): Unit {
        if (hasKeyItem(SecureSessionCipher.keyAlias, HuksOptions())) { return }
        let properties: Array<HuksParam> = [
            HuksParam(HuksTag.HUKS_TAG_ALGORITHM, HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
            HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128)),
            HuksParam(
                HuksTag.HUKS_TAG_PURPOSE,
                HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT)
            )
        ]
        generateKeyItem(SecureSessionCipher.keyAlias, HuksOptions(properties: properties, inData: Bytes()))
    }

    static func cryptProperties(encrypting: Bool, nonce: Array<UInt8>, cipherText: Array<UInt8>): Array<HuksParam> {
        let properties = ArrayList<HuksParam>()
        properties.add(HuksParam(HuksTag.HUKS_TAG_ALGORITHM, HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)))
        properties.add(HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128)))
        properties.add(HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(if (encrypting) { HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT } else { HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT })
        ))
        properties.add(HuksParam(HuksTag.HUKS_TAG_PADDING, HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_NONE)))
        properties.add(HuksParam(HuksTag.HUKS_TAG_BLOCK_MODE, HuksParamValue.Uint32Value(HuksCipherMode.HUKS_MODE_GCM)))
        properties.add(HuksParam(HuksTag.HUKS_TAG_NONCE, HuksParamValue.BytesValue(nonce)))
        properties.add(HuksParam(HuksTag.HUKS_TAG_ASSOCIATED_DATA, HuksParamValue.BytesValue(SecureSessionCipher.associatedData)))
        if (!encrypting) {
            properties.add(HuksParam(
                HuksTag.HUKS_TAG_AE_TAG,
                HuksParamValue.BytesValue(cipherText.slice(cipherText.size - 16, 16))
            ))
        }
        return properties.toArray()
    }
}
