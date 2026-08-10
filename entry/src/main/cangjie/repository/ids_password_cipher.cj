package ohos_app_cangjie_entry.repository

import kit.CryptoArchitectureKit.*
import std.collection.*

// Xidian IDS encrypts a prefixed UTF-8 password with AES-128-CBC and PKCS#7.
// The salt is supplied by the live login form and is never persisted.
public class IDSPasswordCipher {
    static let prefix: String = "xidianscriptsxduxidianscriptsxduxidianscriptsxduxidianscriptsxdu"
    static let ivText: String = "xidianscriptsxdu"
    static let base64Alphabet: Array<String> = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
        "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f",
        "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
        "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"
    ]
    static let captchaAlphabet: Array<String> = [
        "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "M", "N", "P", "Q", "R", "S", "T", "W", "X", "Y", "Z",
        "a", "b", "c", "d", "e", "f", "h", "i", "j", "k", "m", "n", "p", "r", "s", "t", "w", "x", "y", "z", "2", "3", "4", "5", "6", "7", "8"
    ]

    // IDS 2.0 associates the slider challenge with a 128-bit browser
    // fingerprint registered before the CAPTCHA is opened.
    public static func generateBrowserFingerprint(): String {
        let bytes = createRandom().generateRandom(16).data
        let hex: Array<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
        var result = ""
        for (value in bytes) {
            let number = Int64(value)
            result += hex[number / 16] + hex[number % 16]
        }
        return result
    }
    public static func encrypt(password: String, salt: String): String {
        let keyBytes = salt.toArray()
        if (keyBytes.size != 16) { throw Exception("IDS pwdEncryptSalt must be exactly 16 UTF-8 bytes") }
        return IDSPasswordCipher.encryptCbc(IDSPasswordCipher.prefix + password, keyBytes, IDSPasswordCipher.ivText.toArray())
    }

    // The IDS slider protocol prepends a random 64-byte nonce and uses the final
    // 16 random bytes as its IV, matching the upstream mobile implementation.
    public static func encryptCaptchaPayload(payload: String, keyBytes: Array<UInt8>): String {
        if (keyBytes.size != 16) { throw Exception("IDS slider AES key must be 16 bytes") }
        let random = createRandom().generateRandom(80).data
        var nonce = ""
        var index: Int64 = 0
        while (index < 64) {
            nonce += IDSPasswordCipher.captchaAlphabet[Int64(random[index]) % IDSPasswordCipher.captchaAlphabet.size]
            index += 1
        }
        var ivText = ""
        index = 64
        while (index < 80) { ivText += IDSPasswordCipher.captchaAlphabet[Int64(random[index]) % IDSPasswordCipher.captchaAlphabet.size]; index += 1 }
        return IDSPasswordCipher.encryptCbc(nonce + payload, keyBytes, ivText.toArray())
    }

    static func encryptCbc(plain: String, keyBytes: Array<UInt8>, ivBytes: Array<UInt8>): String {
        let keyFactory = createSymKeyGenerator("AES128")
        let key = keyFactory.convertKey(DataBlob(keyBytes))
        let cipher = createCipher("AES128|CBC|PKCS7")
        let params = IvParamsSpec("IvParamsSpec", DataBlob(ivBytes))
        cipher.initialize(CryptoMode.EncryptMode, key, params)
        return IDSPasswordCipher.toBase64(cipher.doFinal(DataBlob(plain.toArray())).data)
    }

    public static func toBase64(data: Array<UInt8>): String {
        var output = ""
        var index: Int64 = 0
        while (index < data.size) {
            let a = Int64(data[index])
            var b: Int64 = 0
            var c: Int64 = 0
            let hasB = index + 1 < data.size
            let hasC = index + 2 < data.size
            if (hasB) { b = Int64(data[index + 1]) }
            if (hasC) { c = Int64(data[index + 2]) }
            output += IDSPasswordCipher.base64Alphabet[a / 4]
            output += IDSPasswordCipher.base64Alphabet[(a % 4) * 16 + b / 16]
            if (hasB) { output += IDSPasswordCipher.base64Alphabet[(b % 16) * 4 + c / 64] } else { output += "=" }
            if (hasC) { output += IDSPasswordCipher.base64Alphabet[c % 64] } else { output += "=" }
            index += 3
        }
        return output
    }

    public static func decodeBase64(text: String): Array<UInt8> {
        let output = ArrayList<UInt8>()
        let input = text.toArray()
        var quartet = ArrayList<Int64>()
        for (byte in input) {
            let value = IDSPasswordCipher.base64Value(Int64(byte))
            if (value >= 0 || Int64(byte) == 61) {
                quartet.add(value)
                if (quartet.size == 4) {
                    let a = quartet[0]
                    let b = quartet[1]
                    let c = quartet[2]
                    let d = quartet[3]
                    if (a < 0 || b < 0) { throw Exception("Invalid base64 data") }
                    output.add(UInt8(a * 4 + b / 16))
                    if (c >= 0) { output.add(UInt8((b % 16) * 16 + c / 4)) }
                    if (d >= 0 && c >= 0) { output.add(UInt8((c % 4) * 64 + d)) }
                    quartet.clear()
                }
            }
        }
        if (quartet.size != 0) { throw Exception("Invalid base64 length") }
        return output.toArray()
    }

    static func base64Value(byte: Int64): Int64 {
        if (byte >= 65 && byte <= 90) { return byte - 65 }
        if (byte >= 97 && byte <= 122) { return byte - 71 }
        if (byte >= 48 && byte <= 57) { return byte + 4 }
        if (byte == 43) { return 62 }
        if (byte == 47) { return 63 }
        return -1
    }
}