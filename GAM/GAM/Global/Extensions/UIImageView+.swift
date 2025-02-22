//
//  UIImageView+.swift
//  GAM
//
//  Created by Jungbin on 2023/06/30.
//

import UIKit

extension UIImageView {
    
    /// 그냥 컬러만 있는 Image를 ImageView에 넣어 주는 메서드
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
    
    /// URL을 통해 이미지를 불러오는 메서드 + 캐싱
    func setImageUrl(_ imageURL: String) {
        let imageURL = Environment.IMAGE_BASE_URL + imageURL
        let cacheKey = NSString(string: imageURL)
        
        /// 해당 Key에 캐시 이미지가 저장되어 있으면 이미지 사용
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        if let requestURL = URL(string: imageURL) {
            let request = URLRequest(url: requestURL)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data,
                   let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300,
                   let image = UIImage(data: data) {
                    
                    /// 다운받은 이미지를 캐시에 저장
                    ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                    
                    DispatchQueue.main.async {
                        self.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.image = .defaultImage
                    }
                }
            }.resume()
        }
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        if let currentImage = self.image {
            let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/currentImage.size.width * currentImage.size.height)))))
            imageView.image = currentImage
            UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, currentImage.scale)
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            imageView.layer.render(in: context)
            guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            UIGraphicsEndImageContext()
            return result
        } else {
            return nil
        }
    }
}
