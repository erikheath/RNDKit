//
//  RNDObjectController.swift
//  RNDBindableObjects-ObjC
//
//  Created by Erikheath Thomas on 6/28/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

import Foundation
import CoreData

class ObjectController: Controller {
    
    private var _objectClass: AnyClass = NSMutableDictionary.self // This is essentially null_resetable backing ivar
    
    @IBOutlet var content: NSObject? = nil
    @IBInspectable var contentBinding: Bool = false
    @IBInspectable var contentControllerID: String? = nil
    @IBInspectable var contentKeyPath: String? = nil
    @IBInspectable var contentValueTransformer: String? = nil
    
    @IBOutlet var managedObjectContext: NSManagedObjectContext? = nil
    @IBInspectable var managedObjectContextBinding: Bool = false
    @IBInspectable var managedObjectContextControllerID: String? = nil
    @IBInspectable var managedObjectContextKeyPath: String? = nil
    @IBInspectable var managedObjectContextValueTransformer: String? = nil
    
    @IBInspectable var mode: String? = nil
    
    @IBInspectable var className: String! {
        set(newClassName) {
            guard let cClassName = newClassName?.cString(using: .init(rawValue: 8)) else {
                // Reset to default type
                self.objectClass = nil
                return
            }
            self.objectClass = objc_getClass(cClassName) as? AnyClass ?? nil
        }
        get {
            
            return String(cString: object_getClassName(self.objectClass))
        }
    }
    
    var objectClass: AnyClass! {
        set(newClassType) {
            guard let _ = newClassType else {
                // Reset to default
                self._objectClass = NSMutableDictionary.self
                return
            }
            
            // Confirm this is an objc object registered with the runtime
            guard object_getClassName(newClassType) != nil
                else {
                    return // TODO: Throw Error?
            }
            self._objectClass = newClassType
        }
        get {
            return self._objectClass
        }
    }
    
    init(with content:NSObject?) { // Typed as Generic with constraints
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Adds the object as the content object.
    ///
    /// - Parameter object: An instance of NSObject or one of its subclasses
    @IBAction func add(object:NSObject) -> Void {
        self.content = object
    }
    
    @IBAction func fetch() -> Void {
        
    }
    
    /// Removes the content object.
    ///
    /// - Parameter object: if the object is the controller's current content object, the object will be removed.
    @IBAction func remove(object:NSObject) -> Void {
        if (self.content?.isEqual(object))! {
            self.content = nil
        }
    }
}
