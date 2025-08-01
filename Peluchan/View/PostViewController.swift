//
//  PostViewController.swift
//  Peluchan
//
//  Created by Alejandro Quiroz Carmona on 27/07/25.
//

import Foundation
import UIKit
import SDWebImage

class PostViewController : UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var spin : UIActivityIndicatorView?
    @IBOutlet weak var body : UITextView?
    
    // MARK: Fields
    
    var id : String?
    var i : Int = 0;
    
    // MARK: Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if let id = id {
            
            let url = "https://www.peluchan.net/api/post/get?author=1&rate=1&_id=\(id)&relacionados=8&see=1&comments=1"
            
            URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
                do {
                    let post = try JSONDecoder().decode(PostResponse.self, from: data!)
                    var content = post.data.post.body?.content ?? HTMLParser.DEV_SAMPLE_TEXT
                    content = content.replacingOccurrences(of: "s2://posts/", with: "https://media.peluchan.net/cdn/posts/")
                    HTMLParser.parseHTMLDocument(html: content,view: self.body!)
                    DispatchQueue.main.async {
                        self.hideLoadingIndicator()
                    }
                } catch {}
            }.resume()
            
        }
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let body = body else { return }
        
        let content = NSMutableAttributedString(attributedString: body.attributedText)
        
        content.enumerateAttribute(
            .attachment,
            in: NSRange(location: 0, length: content.length),
            options: []
        ) { (value, range, stop) in
            if let attachment = value as? NSTextAttachment{
                let scale = body.bounds.width / attachment.bounds.width
                let size = CGSize(width: body.bounds.width, height: attachment.bounds.height * scale)
                
                let newAttachment = NSTextAttachment()
                newAttachment.image = attachment.image
                newAttachment.bounds = CGRect(origin: .zero, size: size)
                
                content.removeAttribute(.attachment, range: range)
                content.addAttribute(.attachment, value: newAttachment, range: range)
            }
        }
        
        body.attributedText = content
    }

    
    // MARK: Progress Indicator
    
    func showLoadingIndicator(){
        body?.isHidden = true
        spin?.isHidden = false
    }
    
    func hideLoadingIndicator(){
        body?.isHidden = false
        spin?.isHidden = true
    }
    
}
