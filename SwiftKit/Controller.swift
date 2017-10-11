//
//  RNDController.swift
//  RNDBindableObjects-ObjC
//
//  Created by Erikheath Thomas on 6/28/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

import Foundation

class Controller: NSObject, Editor, EditorRegistration, EditorDelegate, NSCoding {
    
    // MARK: - IB Properties
    
    /// <#Description#>
    @IBInspectable var controllerID: String? = nil
    
    // MARK: - Internal Properties
    
    /// _editors is the internal tracking array for any editor that has registered as potentially altering a value mediated by the controller.
    internal var editors: Array<Editor> = []
    
    /// _declaredKeys is an array specifying the keys the controller has specified it supports.
    internal var declaredKeys: Array<String> = []
    
    /// <#Description#>
    internal var dependentKeyToModelKeyTable:Dictionary<String, String> = [:]
    
    /// <#Description#>
    internal var modelKeyToDependentKeyTable:Dictionary<String, String> = [:]
    
    /// <#Description#>
    internal var modelKeysToRefreshEachTime:Array<String> = []
    
    // MARK: - Object Lifecycle
    
    /// <#Description#>
    override init() {
        super.init()
    }
    
    // NSCoding
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    // MARK: - RND Editor Registration
    
    /// Editors send this message to the controller to inform it that they will begin editing a value mediated by the controller. The controller maintains a list of editors that have uncommitted changes, and coordinates change tracking among them.
    ///
    /// - Parameter editor: An object, typically a view, that conforms to the editor protocol.
    func editorDidBeginEditing(_ editor: Editor) {
        editors.append(editor)
    }
    
    /// Editors send this message to the controller to inform it that they will end editing a value mediated by the controller.
    ///
    /// - Parameter editor: An object, typically a view, that conforms to the editor protocol and was previously registered as an editor.
    func editorDidEndEditing(_ editor: Editor) {
        editors.index { (currentEditor) -> Bool in
            return currentEditor == editor
        }
    }
    
    // MARK: - RND Editor
    func discardEditing() -> Void {
        
    }

    func commitEditing() throws -> Void {
        
    }

    func commitEditing(withDelegate delegate: EditorDelegate, contextInfo: Any?) -> Void {
        
    }
    
    
    // MARK: - RND Editor Delegate
    func editor(_ editor: Editor, didCommit committed: Bool, contextInfo: Any?) -> Void {
        
    }

    
    /// Indicates if the controller has pending edits??
    var editing: Bool {
        get {
            return self._editors.count > 1
        }
    }
    
}

