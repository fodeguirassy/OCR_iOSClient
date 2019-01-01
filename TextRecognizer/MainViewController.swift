import UIKit
import CoreML
import Foundation


class MainViewController: UIViewController {
    
    var lastPoint : CGPoint = CGPoint.zero
    let penWidth = 10.0
    
    @IBOutlet weak var onlineMode: UISwitch!
    
    @IBOutlet weak var touchAddModel: UIButton!
    
    
    @IBAction func touchAddModel(_ sender: Any) {
        var label = ""
        
        let alertController = UIAlertController(title: "Label", message: "Entrez un Label", preferredStyle: .alert)
        alertController.addTextField { txtField in
            txtField.placeholder = "un Label"
        }
        
        let alertAction = UIAlertAction(title: "Soumettre", style: .default, handler: { alert in
            label = (alertController.textFields?.first?.text)!
            
            print("\(label)")
            
            
            let currentImage = UIImagePNGRepresentation(self.drawView.toImage()!)
             let img = UIImage(data: currentImage!)
            self.testImageView.image = img
             let imgData = img?.noir.toPixelArray()
             
             let url = URL(string: "http://0.0.0.0:5000/add")
             var request = URLRequest(url: url!)
             request.httpMethod = "POST"
             request.setValue("application/json", forHTTPHeaderField: "Content-Type")
             
             let requestData = AddRequestBody(aLabel: label, aData: imgData!)
             
             let jsonData = try! JSONEncoder().encode(requestData)
            
             request.httpBody = jsonData
             
             let task = URLSession.shared.dataTask(with: request) {(data, response, error ) in
             
             if data != nil {
                 var str = String(data: data!, encoding: String.Encoding.utf8)
                 print("\(str)")
             }
             }
             
             task.resume()
        })
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func goToList(_ sender: Any) {
       self.goToList()
    }
    
    @IBOutlet weak var testImageView: UIImageView!
    @IBOutlet weak var drawView: DrawView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
          
            testImageView.image = UIImage(named: "test.png")
            let data = UIImage(named: "test.png")?.toPixels()
            let ml = try MLMultiArray(shape: [100,100], dataType: MLMultiArrayDataType.double)
            for (index, el) in (data?.enumerated())! {
                ml[index] = NSNumber(floatLiteral: el)
            }
            let pred = try handWritten().prediction(input: ml).classLabel
            print("\(pred)")
            
        } catch {
            
        }
    }
    
    @objc func goToList() {
        self.navigationController?.pushViewController(ListViewController(), animated: true)
    }
    
    @IBOutlet weak var touchSubmit: UIButton!
    
    @IBAction func touchSubmit(_ sender: Any) {
        
        if self.onlineMode.isOn {
            
            let currentImage = UIImagePNGRepresentation(self.drawView.toImage()!)
            let img = UIImage(data: currentImage!)
            self.testImageView.image = img
            let imgData = img?.noir.toPixelArray()
            
            let url = URL(string: "http://0.0.0.0:5000/predict")
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            let jsonData = try! JSONEncoder().encode(PredictRequestBody(aData: imgData!))
            
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) {(data, response, error ) in
                
                if data != nil {
                    var str = String(data: data!, encoding: String.Encoding.utf8)
                    print("\(str)")
                }
            }
            
            task.resume()
            
        } else {
            //OFFLINE
            do {
                /*
                let currentImage = UIImagePNGRepresentation(drawView.toImage()!)
                let img = UIImage(data: currentImage!)
                
                testImageView.image = img
                
                let data = img?.noir.toPixelArray()
                
                let ml = try MLMultiArray(shape: [100,100], dataType: MLMultiArrayDataType.double)
                for (index, el) in (data?.enumerated())! {
                    ml[index] = NSNumber(floatLiteral: el)
                }
                
                let pred = try handWritten().prediction(input: ml).classLabel
                print("\(pred)")
                */
            } catch {
                
            }
        }
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = UIImagePNGRepresentation(image) else {
            return false
        }
    
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("fileName.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    @IBAction func touchRemove(_ sender: Any) {
        drawView.lines = []
        drawView.setNeedsDisplay()
    }
    
    @IBOutlet weak var touchRemove: UIButton!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UIImage {
    func toPixels() -> [Double] {
        
        guard let cg = cgImage else {
            return [Double]()
        }
        
        /*
        print("Original bitsPerComponent : \(cg.bitsPerComponent) \n BytesPerRow : \(cg.bytesPerRow) \n BitmapInfo : \(cg.bitmapInfo) \n width : \(cg.width) \n  height : \(cg.height)")
        */
        
        let totalBytes = (self.cgImage?.height)! * (self.cgImage?.bytesPerRow)!
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        var intensities = [UInt8](repeating: 0, count: totalBytes)
        
        let contextRef = CGContext(data: &intensities, width: (self.cgImage?.width)!,
                                   height: (self.cgImage?.height)!, bitsPerComponent: (self.cgImage?.bitsPerComponent)!,
                                   bytesPerRow: (self.cgImage?.bytesPerRow)!,
                                   space : colorSpace, bitmapInfo: 0)
        
        contextRef?.draw(self.cgImage!, in: CGRect.init(x: 0.0, y: 0.0, width: CGFloat((self.cgImage?.width)!), height: CGFloat((self.cgImage?.height)!)))
        
        
        let doubleArray = intensities.map {
            Double($0)
        }
        
        return doubleArray
    }
    
    func toPixelArray() -> [Double] {
        
        let totalBytes = 100 * 100
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        var intensities = [UInt8](repeating: 0, count: totalBytes)
        
        guard let cgI = cgImage else { return [Double]() }
        
        let contextRef = CGContext(data: &intensities, width: 100,
                                   height: 100, bitsPerComponent: 8,
                                   bytesPerRow: 100,
                                   space : colorSpace, bitmapInfo: 0)
        
        contextRef?.draw(cgI, in: CGRect.init(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        
        let doubleArray = intensities.map {
            Double($0)
        }
        print("\(doubleArray)")
        
        return doubleArray
    }
    
    var noir: UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")!
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let output = currentFilter.outputImage!
        let cgImage = context.createCGImage(output, from: output.extent)!
        let processedImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        
        return processedImage
    }
    
    
    var colors: [UIColor]? {
        
        var colors = [UIColor]()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let totalBytes = (self.cgImage?.height)! * (self.cgImage?.bytesPerRow)!

        
        guard let cgImage = cgImage else {
            return nil
        }
        
        let width = Int(size.width)
        let height = Int(size.height)
        
        
        var rawData = [UInt8](repeating: 0, count: totalBytes)
        let bytesPerRow = self.cgImage?.bytesPerRow
        let bytesPerComponent = 8
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        let context = CGContext(data: &rawData,
                                width: width,
                                height: height,
                                bitsPerComponent: bytesPerComponent,
                                bytesPerRow: bytesPerRow!,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo)
        
        let drawingRect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        
        context?.draw(cgImage, in: CGRect.init(x: CGFloat(0), y: CGFloat(0), width: CGFloat(cgImage.width), height: CGFloat(cgImage.height)))
        
        print("\(rawData)")
        return colors
    }
    
}
