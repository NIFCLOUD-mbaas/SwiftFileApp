//
//  ViewController.swift
//  SwiftFileApp
//
//  Created by Natsumo Ikeda on 2016/05/30.
//  Copyright 2019 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
//

import UIKit
import NCMB

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = "カメラで写真を撮りましょう！"
    }
    
    // 「カメラ」ボタン押下時の処理
    @IBAction func cameraStart(sender: AnyObject) {
        
        // カメラが利用可能か確認する
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            cameraPicker.sourceType = UIImagePickerController.SourceType.camera
            cameraPicker.allowsEditing = true
            self.present(cameraPicker, animated: true, completion: nil)
        } else {
            print("エラーが発生しました")
            self.label.text = "エラーが発生しました"
        }
    }
    
    // 撮影が終了したときに呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage:UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            cameraView.contentMode = .scaleAspectFit
            cameraView.image = pickedImage
            self.label.text = "撮った写真をクラウドに保存しよう！"
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("キャンセルされました")
        self.label.text = "キャンセルされました"
        
    }
    
    // 「mobile backendに保存」ボタン押下時の処理
    @IBAction func saveImage(sender: AnyObject) {
        let image: UIImage! = cameraView.image
        // 画像がnilのとき
        if image == nil {
            print("画像がありません")
            self.label.text = "画像がありません"
            
            return
        }
        
        // 画像をリサイズする
        let imageW : Int = Int(image.size.width*0.2)
        let imageH : Int = Int(image.size.height*0.2)
        let resizeImage = resize(image: image, width: imageW, height: imageH)
        
        // ファイル名を決めるアラートを表示
        let alert = UIAlertController(title: "保存します", message: "ファイル名を指定してください", preferredStyle: .alert)
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField: UITextField!) -> Void in
        }
        // アラートのOK押下時の処理
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) -> Void in
            // 入力したテキストをファイル名に指定
            let fileName = alert.textFields![0].text! + ".png"

            // ACL設定（読み書き可）
            var acl = NCMBACL.empty
            acl.put(key: NCMBACL.ACL_PUBLIC, readable: true, writable: true)
            // 画像をNSDataに変換
            let pngData = NSData(data: resizeImage.pngData()!)
            let file = NCMBFile.init(fileName: fileName, acl: acl)
            file.saveInBackground(data: pngData as Data, callback: { result in
                switch result {
                case .success:
                    // 保存成功時の処理
                    print("保存に成功しました")
                    DispatchQueue.main.async {
                        self.label.text = "保存に成功しました"
//                        self.label.text = "保存中：100％"
                    }
                case let .failure(error):
                    // 保存失敗時の処理
                    print("保存に失敗しました。エラーコード：\(error)")
                    DispatchQueue.main.async {
                        self.label.text = "保存に失敗しました：\(error)"
                    }
                }
            })
        })
        
        // アラートのCancel押下時の処理
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) -> Void in
            print("保存がキャンセルされました")
            self.label.text = "保存がキャンセルされました"
            
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    // 画像をリサイズする処理
    func resize (image: UIImage, width: Int, height: Int) -> UIImage {
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let resizeImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage()}
        UIGraphicsEndImageContext()
        
        return resizeImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

