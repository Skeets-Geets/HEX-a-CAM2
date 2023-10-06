import UIKit
import ImageIO

extension UIImage {

    class func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        var images: [UIImage] = []
        var totalDuration: Double = 0

        let frameCount = CGImageSourceGetCount(source)
        for i in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil),
               let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
               let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
               let frameDuration = gifInfo[kCGImagePropertyGIFDelayTime as String] as? Double {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
                totalDuration += frameDuration
            }
        }
        return UIImage.animatedImage(with: images, duration: totalDuration)
    }
}

