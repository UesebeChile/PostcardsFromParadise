//
//  ViewController.swift
//  Postcards From Paradise
//
//  Created by Cristian Torres on 7/6/18.
//  Copyright © 2018 Uesebe. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController:   UIViewController,
                        UICollectionViewDataSource,
                        UICollectionViewDelegate,
                        UICollectionViewDragDelegate,
                        UIDropInteractionDelegate,
                        UIDragInteractionDelegate {
    
    

    @IBOutlet weak var postcardImageView: UIImageView!
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    var colors = [UIColor]()
    
    var image : UIImage?
    
    var topText = "Bienvenido a iOS 11"
    var bottomText = "El mejor curso lanzado por Cristian hasta la fecha con UeSeBe"
    
    var topFontName     = "Avenir Next"
    var bottomFontName  = "Baskerville"
    
    var topFontColor    = UIColor.white
    var bottomFontColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            self.colors += [.black, .gray, .white, .red, .orange, .yellow, .green, .cyan, .blue, .purple, .brown, .magenta]
        
        for hue in 0...11{
            for sat in 1...12{
                let color = UIColor(hue: CGFloat(hue)/12, saturation: CGFloat(sat)/12, brightness: 1, alpha: 1)
                self.colors.append(color)
            }
        }
        self.colorCollectionView.dragDelegate = self
        
        self.postcardImageView.isUserInteractionEnabled = true
        let dropInteraction = UIDropInteraction(delegate: self)
        self.postcardImageView.addInteraction(dropInteraction)
        let dragInteraction = UIDragInteraction(delegate: self)
        self.postcardImageView.addInteraction(dragInteraction)
        
        self.title = "Postales deslde el paraiso"
        splitViewController?.view.backgroundColor = UIColor.lightGray
        
        renderPostcard()
        
    }
    
    //MARK: Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        
        let color = self.colors[indexPath.row]
        cell.backgroundColor = color
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func renderPostcard(){
        // 1 . Definir la zona de dibujo rectangular para trabajar. 3000x2400
        let drawRect = CGRect(x: 0, y: 0, width: 3000, height: 2400)
        
        // 2 . Crear dos rectángulos para los dos textos de la postal
        let topRect = CGRect(x: 300, y: 200, width: 2400, height: 800)
        let bottomRect = CGRect(x: 300, y: 1800, width: 2400, height: 600)
        
        // 3 . A partir de los nombres de las fuentes, crear los dos objetos UIFont
        //     Dejaremos una fuente por defecto (Avenir Next) por si algo falla
        let topFont = UIFont(name: self.topFontName, size: 250) ?? UIFont.systemFont(ofSize: 240)
        let bottomFont = UIFont(name: self.bottomFontName, size: 120) ?? UIFont.systemFont(ofSize: 80)
        
        // 4 . NSMutableParagraphStyle para centrar el texto de loa etiqueta
        let centered = NSMutableParagraphStyle()
        centered.alignment = .center
        
        // 5 . Definir la estructura de la etiqueta como el color y la fuente (NSAttributedStringKey)
        let topAttributes : [NSAttributedString.Key : Any] =
            [
                .foregroundColor    : topFontColor,
                .font               : topFont,
                .paragraphStyle     : centered
            ]
        let bottomAttributes : [NSAttributedString.Key : Any] =
            [
                .foregroundColor    : bottomFontColor,
                .font               : bottomFont,
                .paragraphStyle     : centered
            ]
        
        // 6 . Indicar la renderización de la imagen (UIGraphicsImageRenderer)
        let renderer = UIGraphicsImageRenderer(size: drawRect.size)
        
        self.postcardImageView.image = renderer.image(actions: { (context) in
            
            // 6.1 Renderizar la zona con fondo gris
            UIColor.lightGray.set()
            context.fill(drawRect)
            
            // 6.2 Pintaremos la imagen seleccionada del usuario (si hay alguna) empezando por el borde superior izquierdo
            self.image?.draw(at: CGPoint(x: 0, y: 0))
            
            // 6.3 Pintar las dos etiquetas de texto con los parñametros configurados en 5
            self.topText.draw(in: topRect, withAttributes: topAttributes)
            self.bottomText.draw(in: bottomRect, withAttributes: bottomAttributes)
            
        })
    }
    
    //    MARK: UICollectionViewDragDelegate
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let color = self.colors[indexPath.row]
        let itemProvider = NSItemProvider(object: color)
        let item = UIDragItem(itemProvider: itemProvider)
        
        return [item]
    }
    
    //    MARK: IUDropInteractionDelegate
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        let dropLocation = session.location(in: self.postcardImageView)
        
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String]){
            //  Se ejecutará si lo que hemos soltado es un String
            session.loadObjects(ofClass: NSString.self, completion: { items in
                guard let fontName = items.first as? String else {return}
                
                if dropLocation.y < self.postcardImageView.bounds.midY
                {
                    self.topFontName = fontName
                } else {
                    self.bottomFontName = fontName
                }
                
                self.renderPostcard()
            })
        } else if session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]){
            //Se ejecutará si lo que hemos soltado es una imagen
            session.loadObjects(ofClass: UIImage.self, completion:
                { items in
                    guard let image = items.first as? UIImage else { return }
                    self.image = self.resizeImage(image: image, targetSize: CGSize(width: 3000, height: 2400))
                    self.renderPostcard()
                }
            )
        
        } else {
            //Se ejecutará si lo que hemos soltado es un color
            session.loadObjects(ofClass: UIColor.self, completion: { items in
                guard let color = items.first as? UIColor else {return}
                
                if dropLocation.y < self.postcardImageView.bounds.midY{
                    self.topFontColor = color
                } else {
                    self.bottomFontColor = color
                }
                
                self.renderPostcard()
        
            })
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let originalSize = image.size
        
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        
        let targetRatio = max(widthRatio, heightRatio)
        
        let newSize = CGSize(width: originalSize.width * targetRatio,
                             height: originalSize.height * targetRatio)
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let  newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
    
    
    //    MARK: UIDragInteractionDelegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = self.postcardImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        return [item]
    }
    
    
    //    MARK: Gesture Recognizer
    
    
    @IBAction func changeText(_ sender: UITapGestureRecognizer) {
        
        // 1 . Encontrar la localización del tap dentro de la postal
        let tapLocation = sender.location(in: self.postcardImageView)
        
        // 2 . Decidir si el usuario tiene que cambiar la etiqueta superior o inferior
        let changeTop = (tapLocation.y < self.postcardImageView.bounds.midY) ? true : false
        
        // 3 . Crear un objeto UIALertController con un textfield adicional para que el usuario escriba el texto
        let alert = UIAlertController(title: "Cambiar texto", message: "Escribe el nuevo texto", preferredStyle: .alert)
        alert.addTextField {textfield in
            
            textfield.placeholder = "¿Qué quieres poner aquí?"
            
            if changeTop {
                textfield.text = self.topText
            } else {
                textfield.text = self.bottomText
            }
        }
        
        // 4 . Añadir acción 'Cambiar texto' que cambie el texto pertinentemente y llame al métodos renderPostcard()
        let changeAction = UIAlertAction(title: "Cambiar Texto", style: .default) { _ in
            guard let newText = alert.textFields?[0].text else { return }
            
            if changeTop {
                self.topText = newText
            } else {
                self.bottomText = newText
            }
            
            self.renderPostcard()
        }
        
        // 5 . Añadir opción 'Cancelar' que pare el proceso
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        // 6 . Mostrar la alert controller
        alert.addAction(changeAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)


    }
}

