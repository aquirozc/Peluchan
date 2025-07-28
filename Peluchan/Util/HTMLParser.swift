//
//  HTMLParser.swift
//  Peluchan
//
//  Created by Alejandro Quiroz Carmona on 27/07/25.
//

import Foundation

import SDWebImage

class HTMLParser{
    
    public static let DEV_SAMPLE_TEXT = """
    
            <!-- Encabezados -->
            <h1>Encabezado nivel 1</h1>
            <h2>Encabezado nivel 2</h2>
            <h3>Encabezado nivel 3</h3>
            <h4>Encabezado nivel 4</h4>
            <h5>Encabezado nivel 5</h5>
            <h6>Encabezado nivel 6</h6>

            <!-- Párrafos -->
            <p>Este es un párrafo de ejemplo.</p>
            <p>Otro párrafo con <strong>texto en negrita</strong> y <em>texto en cursiva</em>.</p>

            <!-- Listas -->
            <ul>
                <li>Elemento de lista desordenada 1</li>
                <li>Elemento de lista desordenada 2</li>
            </ul>

            <ol>
                <li>Elemento de lista ordenada 1</li>
                <li>Elemento de lista ordenada 2</li>
            </ol>

            <!-- Enlaces -->
            <a href="https://www.ejemplo.com">Enlace a ejemplo.com</a>

            <!-- Imágenes -->
            <img src="https://www.gstatic.com/webp/gallery/1.webp" width="200">
            <img src="https://assets.leetcode.com/users/images/2f85e2f4-aa0a-4c9b-8a9a-3e9d7c3a5d5f_1680000000.avif" width="200">

            <!-- Tablas -->
            <table border="1">
                <tr>
                    <th>Encabezado 1</th>
                    <th>Encabezado 2</th>
                </tr>
                <tr>
                    <td>Celda 1</td>
                    <td>Celda 2</td>
                </tr>
            </table>

    """
    
    func parseHTMLDocument(html : String, view : UITextView) {
        
        do {
            
            let urls = try NSRegularExpression(pattern: "src\\s*=\\s*\"([^\"]*)\"" , options: .caseInsensitive)
                            .matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
                            .map({String(html[Range($0.range(at: 1),in:html)!])})
            
            let placeholder = html.replacingOccurrences(
                of: "<img[^>]*>",
                with: "<span style='color:blue;font-weight:bold'>[Cargando imagen...]</span>",
                options: .regularExpression,
                range: nil
            )
            
            let base = NSMutableAttributedString(attributedString: try NSAttributedString(
                data: placeholder.data(using: .utf8)!,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            ))
            
            DispatchQueue.main.async {
                base.addAttribute(.font, value: view.font!, range: NSRange(location: 0, length: base.length))
                view.attributedText = base
            }
            
            for url in urls {
                
                SDWebImageManager.shared.loadImage(
                    with: URL(string: url),
                    options: [],
                    progress: nil
                ) {(image, data, error, cacheType, finished, imageUrl) in
                    
                    guard let image = image else { return }
                    
                    let attachment = NSTextAttachment()
                    attachment.image = image
                    
                    let scale = view.bounds.width / image.size.width
                    let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                    attachment.bounds = CGRect(origin: .zero, size: newSize)
                    
                    let imageString = NSAttributedString(attachment: attachment)
                
                    let placeholderText = "[Cargando imagen...]"
                    let range = (base.string as NSString).range(of: placeholderText)
                    
                    if range.location != NSNotFound {
                        base.replaceCharacters(in: range, with: imageString)
                        DispatchQueue.main.async {
                            view.attributedText = base
                        }
                    }
                    
                }
                
            }
            
        } catch {}
        
    }

}
