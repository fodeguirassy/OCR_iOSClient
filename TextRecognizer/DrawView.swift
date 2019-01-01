import Foundation
import UIKit

class DrawView : UIView {
    
    var lines : [Line] = []
    var lastPoint : CGPoint!
    
    required init(coder aDecoder : NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = touches.first?.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newPoint = touches.first?.location(in: self)
        lines.append(Line(start: lastPoint, end: newPoint!))
        lastPoint = newPoint
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.beginPath()
        lines.forEach { line in
            context?.move(to: line.start)
            context?.addLine(to: line.end)
        }
        context?.setLineCap(.round)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineWidth(3)
        context?.strokePath()
    }
    
}

extension DrawView  {
    func toImage() -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        self.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        guard let cg = image?.cgImage else {
            return nil
        }
        
        let ciImage = CIImage.init(cgImage: cg)
        ciImage.applyingFilter("CIPhotoEffectNoir")
        //ciImage.pixelBuffer
        
        /*
        print("FromContext bitsPerComponent : \(cg.bitsPerComponent) \n BytesPerRow : \(cg.bytesPerRow) \n BitmapInfo : \(cg.bitmapInfo) \n width : \(cg.width) \n  height : \(cg.height)")
        */
    
        //print("\(UIImagePNGRepresentation(UIImage(cgImage: cg)))")
        
        UIGraphicsEndImageContext()
        return UIImage(cgImage: cg)
    
    }
    
    
    func grayscaleImage(image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)
        let grayscale = ciImage?.applyingFilter("CIColorControls",
                                                parameters: [ kCIInputSaturationKey: 0.0 ])
        
        return UIImage(ciImage: grayscale!)
    }
}
