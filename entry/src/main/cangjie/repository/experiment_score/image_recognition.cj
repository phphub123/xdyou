package ohos_app_cangjie_entry.repository.experiment_score

import kit.ImageKit.*
import std.collection.*
import ohos_app_cangjie_entry.model.xidian_ids.*

// Source parity: hashes the RGB bytes of opaque pixels in the score service's
// 50x20 image with unsigned 32-bit FNV-1a. No OCR or inferred score is used.
public class ImageRecognitionService {
    static let scoreHashes: HashMap<String, UInt64> = ImageRecognitionService.makeHashes()

    static func makeHashes(): HashMap<String, UInt64> {
        let values = HashMap<String, UInt64>()
        values["0"] = 3531432063; values["10"] = 2759386880
        values["4"] = 314909311; values["5"] = 3417863369
        values["5.5"] = 1879675493; values["6"] = 1633340036
        values["6.5"] = 406889604; values["7"] = 923381590
        values["7.5"] = 3679241944; values["8"] = 957817480
        values["8.5"] = 4210302206; values["9"] = 3501829210
        values["9.5"] = 4187815228; values["已上传"] = 4077928038
        values["未上传"] = 843703430
        return values
    }

    public func recognize(bytes: Array<UInt8>, rawUrl: String): RecognitionResult {
        let hash = this.pixelFNV1A(bytes)
        for ((label, expected) in ImageRecognitionService.scoreHashes) {
            if (hash == expected) { return RecognitionResult(label, true, rawUrl) }
        }
        return RecognitionResult("", false, rawUrl)
    }

    public func pixelFNV1A(bytes: Array<UInt8>): UInt64 {
        let source = createImageSource(bytes)
        let pixelMap = source.createPixelMap(options: DecodingOptions(desiredPixelFormat: PixelMapFormat.Rgba8888))
        let info = pixelMap.getImageInfo()
        if (info.size.width < 50 || info.size.height < 20) {
            pixelMap.release(); source.release()
            throw Exception("实验成绩图片尺寸小于 50x20。")
        }
        let pixels = Array<UInt8>(Int64(pixelMap.getPixelBytesNumber()), repeat: 0)
        pixelMap.readPixelsToBuffer(pixels)
        let width = Int64(info.size.width)
        var hash: UInt64 = 0x811C9DC5
        var y: Int64 = 0
        while (y < 20) {
            var x: Int64 = 0
            while (x < 50) {
                let index = (y * width + x) * 4
                if (pixels[index + 3] == 255) {
                    hash = ((hash ^ UInt64(pixels[index])) * 0x01000193) & 0xFFFFFFFF
                    hash = ((hash ^ UInt64(pixels[index + 1])) * 0x01000193) & 0xFFFFFFFF
                    hash = ((hash ^ UInt64(pixels[index + 2])) * 0x01000193) & 0xFFFFFFFF
                }
                x += 1
            }
            y += 1
        }
        pixelMap.release(); source.release()
        return hash
    }
}
