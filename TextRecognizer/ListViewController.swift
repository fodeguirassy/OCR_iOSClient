//
//  ListViewController.swift
//  TextRecognizer
//
//  Created by Fodé Guirassy on 30/12/2018.
//  Copyright © 2018 Fodé Guirassy. All rights reserved.
//

import UIKit
import CoreML

class ListViewController: UIViewController {
    
    var images = [String]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
      
        self.collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyCell")
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        
        do {
            let items = try fm.contentsOfDirectory(atPath: path)
            items.forEach { it in
                if(it.contains("png")) {
                    images.append(it)
                    print("\(it)")
                }
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
        
        
        self.navigationController?.navigationItem.setRightBarButton(UIBarButtonItem(title: "Back", style: .plain, target: self, action: "#"), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ListViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let img = images[indexPath.row]
        
        do {
            let data = UIImage(named: img)?.toPixels()
            let ml = try MLMultiArray(shape: [100,100], dataType: MLMultiArrayDataType.double)
            for (index, el) in (data?.enumerated())! {
                ml[index] = NSNumber(floatLiteral: el)
            }
            let pred = try handWritten().prediction(input: ml).classLabel
            print("\(pred)")
            
            self.showToast(controller: self, message: "\(pred)", seconds: 3)
            
            
        } catch {
            
        }
        
    }
    
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}

extension ListViewController : UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! CollectionViewCell
        guard let img = UIImage(named: images[indexPath.row]) else {
            return cell
        }
        
        cell.imgView.image = img
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

