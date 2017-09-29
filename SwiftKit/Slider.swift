//
//  RNDSlider.swift
//  RNDBindableObjects-ObjC
//
//  Created by Erikheath Thomas on 6/28/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

import UIKit
import CoreData

class Slider: UISlider {
    
    // MARK: Slider Bindings
    @IBInspectable var valueBinding:Bool = false
    @IBInspectable var valueControllerID: String? = nil
    @IBInspectable var valueKeyPath: String? = nil
    @IBInspectable var valueValueTransformer: String? = nil
    
    @IBInspectable var minValueBinding:Bool = false
    @IBInspectable var minValueControllerID: String? = nil
    @IBInspectable var minValueKeyPath: String? = nil
    @IBInspectable var minValueVaueTransformer: String? = nil
    
    @IBInspectable var maxValueBinding:Bool = false
    @IBInspectable var maxValueControllerID: String? = nil
    @IBInspectable var maxValueKeyPath: String? = nil
    @IBInspectable var maxValueValueTransformer: String? = nil

    @IBInspectable var minTrackTintBinding: Bool = false
    @IBInspectable var minTrackTintControllerID: String? = nil
    @IBInspectable var minTrackTintKeyPath: String? = nil
    @IBInspectable var minTrackValueTransformer: String? = nil
    
    @IBInspectable var maxTrackTintBinding: Bool = false
    @IBInspectable var maxTrackTintControllerID: String? = nil
    @IBInspectable var maxTrackTintKeyPath: String? = nil
    @IBInspectable var maxTrackTintValueTransformer: String? = nil
    
    @IBInspectable var thumbTintBinding: Bool = false
    @IBInspectable var thumbTintControllerID: String? = nil
    @IBInspectable var thumbTintKeyPath: String? = nil
    @IBInspectable var thumbTintValueTransformer: String? = nil
    
    @IBInspectable var continuousUpdatesBinding: Bool = false
    @IBInspectable var continuousUpdatesControllerID: String? = nil
    @IBInspectable var continuousUpdatesKeyPath: String? = nil
    @IBInspectable var continuousUpdatesValueTransformer: String? = nil

    // MARK: Control Bindings
    @IBInspectable var selectedBinding: Bool = false
    @IBInspectable var selectedControllerID: String? = nil
    @IBInspectable var selectedKeyPath: String? = nil
    @IBInspectable var selectedValueTransformer: String? = nil
    
    @IBInspectable var enabledBinding: Bool = false
    @IBInspectable var enabledControllerID: String? = nil
    @IBInspectable var enabledKeyPath: String? = nil
    @IBInspectable var enabledValueTransformer: String? = nil
    
    @IBInspectable var highlightedBinding: Bool = false
    @IBInspectable var highlightedControllerID: String? = nil
    @IBInspectable var highlightedKeyPath: String? = nil
    @IBInspectable var highlightedValueTransformer: String? = nil


    // MARK: View Bindings
    @IBInspectable var hiddenBinding: Bool = false
    @IBInspectable var hiddenControllerID: String? = nil
    @IBInspectable var hiddenKeyPath: String? = nil
    @IBInspectable var hiddenValueTransformer: String? = nil

    
    @IBOutlet var objectControllers: Array<RNDController>? = nil
    
    // MARK: RND Key-Value Binding Creation
//    static func exposeBinding(_ binding: BindingName) {
//        <#code#>
//    }
//    
//    var exposedBindings: [BindingName] {
//        <#code#>
//    }
//    
//    func valueClassForBinding(_ binding: BindingName) -> AnyClass? {
//        <#code#>
//    }
//    
//    func bind(_ binding: BindingName, to observable: Any, withKeyPath keyPath: String, options: [BindingOption : Any]?) {
//        <#code#>
//    }
//    
//    func optionDescriptionsForBinding(_ binding: BindingName) -> [NSAttributeDescription] {
//        <#code#>
//    }
//    
//    func infoForBinding(_ binding: BindingName) -> [BindingInfoKey : Any]? {
//        <#code#>
//    }
//    
//    func unbind(_ binding: BindingName) {
//        <#code#>
//    }
    
    // MARK: - RNDEditor
    
    internal var _editingStatus: Bool = false
    /// Indicates if the slider is editing its value. This will only happen as the result of an attempt to change the slider value. Editing begins with a touchDown event and continues until a touchUpInside event is received.
    var editing: Bool {
        get {
            
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




