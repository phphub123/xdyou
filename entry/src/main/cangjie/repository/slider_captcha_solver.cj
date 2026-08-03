package ohos_app_cangjie_entry.repository

import kit.ImageKit.*
import std.random.*
import std.math.*

class DecodedCaptchaImage {
    let width: Int64
    let height: Int64
    let pixels: Array<UInt8>
    init(width: Int64, height: Int64, pixels: Array<UInt8>) {
        this.width = width
        this.height = height
        this.pixels = pixels
    }
}

// Mirrors the Flutter client's invisible NCC solver. The manual slider remains
// only as a fallback after the automatic attempts are exhausted.
public class SliderCaptchaAutoSolver {
    static let trackRandom = Random()
    public static func solveMove(captcha: SliderCaptcha): Int64 {
        let puzzle = SliderCaptchaAutoSolver.decode(captcha.bigImage)
        let encodedPiece = IDSPasswordCipher.decodeBase64(captcha.smallImage)
        if (encodedPiece.size <= 16) { throw Exception("IDS slider piece is shorter than its AES key") }
        let pieceImage = Array<UInt8>(encodedPiece.size - 16, { index => encodedPiece[index] })
        let piece = SliderCaptchaAutoSolver.decodeBytes(pieceImage)
        if (puzzle.width <= piece.width || puzzle.height < piece.height) {
            throw Exception("IDS slider image dimensions are invalid")
        }

        var xLeft = piece.width
        var yTop = piece.height
        var xRight: Int64 = 0
        var yBottom: Int64 = 0
        var y: Int64 = 0
        while (y < piece.height) {
            var x: Int64 = 0
            while (x < piece.width) {
                if (SliderCaptchaAutoSolver.alpha(piece, x, y) == 255) {
                    if (x < xLeft) { xLeft = x }
                    if (x > xRight) { xRight = x }
                    if (y < yTop) { yTop = y }
                    if (y > yBottom) { yBottom = y }
                }
                x += 1
            }
            y += 1
        }
        if (xLeft > xRight || yTop > yBottom) { throw Exception("IDS slider piece has no opaque pixels") }

        let border: Int64 = 24
        if (xLeft + border <= xRight - border && yTop + border <= yBottom - border) {
            xLeft += border
            xRight -= border
            yTop += border
            yBottom -= border
        }
        let windowWidth = xRight - xLeft + 1
        let windowHeight = yBottom - yTop + 1
        let area = windowWidth * windowHeight
        var templateMean = 0.0
        y = yTop
        while (y <= yBottom) {
            var x = xLeft
            while (x <= xRight) {
                templateMean += SliderCaptchaAutoSolver.luminance(piece, x, y)
                x += 1
            }
            y += 1
        }
        templateMean /= Float64(area)
        let template = Array<Float64>(area, repeat: 0.0)
        var templateIndex: Int64 = 0
        y = yTop
        while (y <= yBottom) {
            var x = xLeft
            while (x <= xRight) {
                template[templateIndex] = SliderCaptchaAutoSolver.luminance(piece, x, y) - templateMean
                templateIndex += 1
                x += 1
            }
            y += 1
        }

        let lastOffset = puzzle.width - piece.width
        var bestOffset: Int64 = 0
        var bestScore = -1000000000000.0
        var offset: Int64 = 0
        while (offset <= lastOffset) {
            var windowMean = 0.0
            y = yTop
            while (y <= yBottom) {
                var x = xLeft
                while (x <= xRight) {
                    windowMean += SliderCaptchaAutoSolver.luminance(puzzle, offset + x, y)
                    x += 1
                }
                y += 1
            }
            windowMean /= Float64(area)
            var numerator = 0.0
            var denominator = 0.000001
            templateIndex = 0
            y = yTop
            while (y <= yBottom) {
                var x = xLeft
                while (x <= xRight) {
                    let normalized = SliderCaptchaAutoSolver.luminance(puzzle, offset + x, y) - windowMean
                    numerator += normalized * template[templateIndex]
                    denominator += normalized * normalized
                    templateIndex += 1
                    x += 1
                }
                y += 1
            }
            let score = numerator / denominator
            if (score > bestScore) { bestScore = score; bestOffset = offset }
            offset += 1
        }
        let move = Int64(round(Float64(bestOffset) * 280.0 / Float64(puzzle.width)))
        return move
    }

    public static func tracks(move: Int64): (String, Int64) {
        let safeMove = if (move < 1) { 1 } else if (move > 280) { 280 } else { move }
        let random = SliderCaptchaAutoSolver.trackRandom
        let count = 10 + random.nextInt64(5)
        let normalization = 1.0 / (1.0 + exp(-7.0 * (1.0 - 0.42)))
        var result = "[{\"a\":0,\"b\":0,\"c\":0}"
        var previous: Int64 = 0
        var vertical: Int64 = 0
        var index: Int64 = 0
        var lastTime: Int64 = 300
        while (index < count) {
            let ratio = Float64(index) / Float64(count)
            let sigmoid = (1.0 / (1.0 + exp(-7.0 * (ratio - 0.42)))) / normalization
            let candidate = Int64(round(Float64(safeMove) * sigmoid))
            var horizontal = if (candidate <= previous) { previous + 1 } else { candidate }
            if (horizontal >= safeMove) { horizontal = safeMove - 1 }
            let direction = random.nextFloat64()
            if (direction < 0.65) { vertical -= 1 } else if (direction < 0.80) { vertical += 1 }
            if (vertical < -10) { vertical = -10 } else if (vertical > 10) { vertical = 10 }
            lastTime = 300 + random.nextInt64(201)
            result += ",{\"a\":${horizontal},\"b\":${vertical},\"c\":${lastTime}}"
            previous = horizontal
            index += 1
        }
        lastTime = 300 + random.nextInt64(201)
        return (result + ",{\"a\":${safeMove},\"b\":${vertical},\"c\":${lastTime}}]", lastTime)
    }

    static func decode(encoded: String): DecodedCaptchaImage {
        return SliderCaptchaAutoSolver.decodeBytes(IDSPasswordCipher.decodeBase64(encoded))
    }

    static func decodeBytes(bytes: Array<UInt8>): DecodedCaptchaImage {
        let source = createImageSource(bytes)
        let pixelMap = source.createPixelMap(options: DecodingOptions(desiredPixelFormat: PixelMapFormat.Rgba8888))
        let info = pixelMap.getImageInfo()
        let pixels = Array<UInt8>(Int64(pixelMap.getPixelBytesNumber()), repeat: 0)
        pixelMap.readPixelsToBuffer(pixels)
        let result = DecodedCaptchaImage(Int64(info.size.width), Int64(info.size.height), pixels)
        pixelMap.release()
        source.release()
        return result
    }

    static func luminance(image: DecodedCaptchaImage, x: Int64, y: Int64): Float64 {
        let index = (y * image.width + x) * 4
        return Float64(image.pixels[index]) * 0.299 + Float64(image.pixels[index + 1]) * 0.587 + Float64(image.pixels[index + 2]) * 0.114
    }

    static func alpha(image: DecodedCaptchaImage, x: Int64, y: Int64): Int64 {
        return Int64(image.pixels[(y * image.width + x) * 4 + 3])
    }
}
