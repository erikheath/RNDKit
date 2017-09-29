//
//  RNDController.swift
//  RNDBindableObjects-ObjC
//
//  Created by Erikheath Thomas on 6/28/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

import Foundation

class Controller: NSObject, Editor, EditorRegistration, Coding {
    
    // MARK: - IB Properties
    
    /// <#Description#>
    @IBInspectable var controllerID: String? = nil
    
    // MARK: - Internal Properties
    
    /// _editors is the internal tracking array for any editor that has registered as potentially altering a value mediated by the controller.
    internal var _editors: Array<AnyObject> = []
    
    /// _declaredKeys is an array specifying the keys the controller has specified it supports.
    internal var _declaredKeys: Array<String> = []
    
    /// <#Description#>
    internal var _dependentKeyToModelKeyTable<String, String> = [:]
    
    /// <#Description#>
    internal var _modelKeyToDependentKeyTable<String, String> = [:]
    
    /// <#Description#>
    internal var _modelKeysToRefreshEachTime = []
    
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
    
    // MARK: - RNDEditingRegistration
    
    /// Editors send this message to the controller to inform it that they will begin editing a value mediated by the controller.
    ///
    /// - Parameter editor: <#editor description#>
    func objectDidBeginEditing(_ editor: AnyObject) {
        
    }
    
    /// Editors send this message to the controller to inform it that they will end editing a value mediated by the controller.
    ///
    /// - Parameter editor: <#editor description#>
    func objectDidEndEditing(_ editor: AnyObject) {
        
    }
    
    // MARK: - RNDEditor
    
    
    /// Indicates if the controller has pending edits??
    var editing: Bool {
        get {
            return self._editors.count > 1
        }
    }
    
    
    /// Requests that all registered editors commit or discard current edits and then attempts to commit the edits to the content object.
    ///
    /// - Throws: Rethrows any model object validation error.
    func commitEditing() throws {
        
    }
    
    func commitEditing(forEditor editor: Any?, didCommit didCommitSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
        
    }
    
    func discardEditing() {
        
    }
    
}

Given that the receiver has been registered with -objectDidBeginEditing: as the editor of some object, and not yet deregistered by a subsequent invocation of -objectDidEndEditing:, attempt to commit the result of the editing. When committing has either succeeded or failed, send the selected message to the specified object with the context info as the last parameter. The method selected by didCommitSelector must have the same signature as:

- (void)editor:(id)editor didCommit:(BOOL)didCommit contextInfo:(void *)contextInfo;

If an error occurs while attempting to commit, because key-value coding validation fails for example, an implementation of this method should typically send the NSView in which editing is being done a -presentError:modalForWindow:delegate:didRecoverSelector:contextInfo: message, specifying the view's containing window.
