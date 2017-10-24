//
//  ViewController.swift
//  Userdefaults
//
//  Created by macbookUser on 23/10/17.
//  Copyright © 2017 macbookUser. All rights reserved.
//

import UIKit

fileprivate enum AlertController {
    static func make(title: String, message: String) -> UIAlertController {
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        controller.addAction(action)
        controller.addAction(cancel)
        return controller
    }
}

fileprivate protocol Storage {
    associatedtype T
    func create(_ object: T, with key: String)
    func readObject(with key: String) -> T?
    func update(object: T,with key: String)
    func deleteObject(with key: String)
}

fileprivate class UserDefaultsStorage: Storage {
    
    enum Keys: String {
        case emoji = "emojis"
    }
    
    func create(_ object: [Emoji], with key: String) {
        UserDefaults.standard.set(object, forKey: key)
    }
    
    func readObject(with key: String) -> [Emoji]? {
        guard let object = UserDefaults.standard.object(forKey: key) as? [Emoji] else {
            return nil
        }
        return object
    }
    
    func update(object: [Emoji],with key: String) {
        UserDefaults.standard.set(object, forKey: key)
    }
    
    func deleteObject(with key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

typealias Emoji = [String: String]
enum EmojiKey: String {
    case name
    case description
}

class ViewController: UIViewController {

    @IBOutlet weak var emojiTextField: UITextField!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var descripionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        emojiTextField.delegate = self
    }
    
    fileprivate let storage = UserDefaultsStorage()
    private var emojisEnMemoria = [Emoji]()
    fileprivate var displayedEmoji: Emoji? {
        didSet {
            fill(with: displayedEmoji)
        }
    }
    
    @IBAction func guardarEmoji(_ sender: UIButton) {
        
        guard let emojiTextFieldIsEmpty = emojiTextField.text?.isEmpty,
              let descripcionTextFieldIsEmpty = descripcionTextField.text?.isEmpty,
              emojiTextFieldIsEmpty == false,
              descripcionTextFieldIsEmpty == false,
              let emojiText = emojiTextField.text,
              let descripcionText = descripcionTextField.text else {
                
            let controller = AlertController.make(title: "Faltaron datos", message:"Ingresa todos los campos")
            self.present(controller, animated: true, completion: nil)
                
            return
        }

        var result: [Emoji] = []
        let nuevoEmoji: Emoji = [EmojiKey.name.rawValue: emojiText, EmojiKey.description.rawValue: descripcionText]
        if let arregloDeEmojis = storage.readObject(with: UserDefaultsStorage.Keys.emoji.rawValue) {
            result.append(contentsOf: arregloDeEmojis)
            result.append(nuevoEmoji)
        }
        else {
            result = [nuevoEmoji]
        }

        storage.create(result, with: UserDefaultsStorage.Keys.emoji.rawValue)
    }
    
    @IBAction func obtenerEmojis(_ sender: UIButton) {
        guard let savedEmojis = storage.readObject(with: UserDefaultsStorage.Keys.emoji.rawValue) else {
            print("No se pudo obtener el arreglo de emojis")
            return
        }
        emojisEnMemoria = savedEmojis
        displayedEmoji = emojisEnMemoria.first
    }
    
    @IBAction func anterior(_ sender: UIButton) {
        guard let displayedEmoji = displayedEmoji else { return }
        let optionalIndex = emojisEnMemoria.index { $0 == displayedEmoji }
        guard let index = optionalIndex else { return }
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return }
        self.displayedEmoji = emojisEnMemoria[previousIndex]
    }
    
    @IBAction func siguiente(_ sender: UIButton) {
        guard let displayedEmoji = displayedEmoji else { return }
        let optionalIndex = emojisEnMemoria.index { $0 == displayedEmoji }
        guard let index = optionalIndex else { return }
        let nextIndex = index + 1
        guard nextIndex < emojisEnMemoria.count else { return }
        self.displayedEmoji = emojisEnMemoria[nextIndex]
    }
    
    private func fill(with emoji: Emoji?) {
        emojiLabel.text = emoji?[EmojiKey.name.rawValue]
        descripionLabel.text = emoji?[EmojiKey.description.rawValue]
    }
    
    @IBAction func borrar(_ sender: UIButton) {
        storage.deleteObject(with: UserDefaultsStorage.Keys.emoji.rawValue)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emojiTextField.resignFirstResponder()
        return true
    }
}

