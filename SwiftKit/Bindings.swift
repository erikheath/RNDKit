//
//  RNDBindings.swift
//  RNDBindableObjects-ObjC
//
//  Created by Erikheath Thomas on 6/25/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

import Foundation
import CoreData


/// A set of methods that controllers can implement to enable an editor view to inform the controller when it has uncommitted changes.
/// An implementor is responsible for tracking which editors have uncommitted changes, and sending those editors commitEditing() and discardEditing() messages, as appropriate, to force the editor to submit, or discard, their values.

/// NSController provides an implementation of this informal protocol. You would implement this protocol if you wanted to provide your own controller class without subclassing NSController.
protocol EditorRegistration {
    
    /// Invoked to inform the receiver that editor has uncommitted changes that can affect the receiver.
    ///
    /// - Parameter editor: Any object that conforms to the Editor protocol
    /// - Returns: Void
    func objectDidBeginEditing(_ editor: Editor) -> Void
    
    /// Invoked to inform the receiver that editor has committed or discarded its changes.
    ///
    /// - Parameter editor: Any object that conforms to the Editor protocol
    /// - Returns: Void
    func objectDidEndEditing(_ editor: Editor) -> Void
}


/// A set of methods that controllers and UI elements can implement to manage editing.
/// The NSEditor informal protocol provides a means for requesting that the receiver commit or discard any pending edits.

/// These methods are typically invoked on user interface elements by a controller. They can also be sent to a controller in response to a user’s attempt to save a document or quit an application.

/// NSController provides an implementation of this protocol, as do the AppKit user interface elements that support binding.


protocol Editor {
    
    /// Discards any pending (uncommitted) edits, returning the editor to its last known state.
    ///
    /// - Returns: Void
    func discardEditing() -> Void
    
    /// Causes the editor to submit any pending edits to its associated model object. If the editor is also a controller, calling commitEditing will cause it to request any pending edits from any registered editors prior to submitting any pending changes to its model objects. This functionality is particularly useful when a controller and its editors will be removed from the object graph, perhaps due to a parent view controller being unloaded.
    /// Returns whether the receiver was able to commit any pending edits. A commit is denied if the receiver fails to apply the changes to the model object, perhaps due to a validation error.
    ///
    /// - Returns: Void
    /// - Throws: If the edits are not able to be committed to the model, this method throws an error
    func commitEditing() throws -> Void
    
    /// Attempts to commit any pending changes in known editors of the receiver.
    /// Provides support for the NSEditor informal protocol. This method attempts to commit pending changes in known editors. Known editors are either instances of a subclass of NSController or (more rarely) user interface controls that may contain pending edits—such as text fields—that registered with the context using objectDidBeginEditing: and have not yet unregistered using a subsequent invocation of objectDidEndEditing:.
    
    /// The receiver iterates through the array of its known editors and invokes commitEditing on each. The receiver then sends the message specified by the didCommitSelector selector to the specified delegate.
    
    /// The didCommit argument is the value returned by the editor specified by editor from the commitEditing message. The contextInfo argument is the same value specified as the contextInfo parameter—you may use this value however you wish.
    
    /// If an error occurs while attempting to commit, for example if key-value coding validation fails, your implementation of this method should typically send the view in which editing is being performed a presentError:modalForWindow:delegate:didRecoverSelector:contextInfo: message, specifying the view's containing window.
    
    /// You may find this method useful in some situations (typically if you are using Cocoa Bindings) when you want to ensure that pending changes are applied before a change in user interface state. For example, you may need to ensure that changes pending in a text field are applied before a window is closed. See also commitEditing() which performs a similar function but which allows you to handle any errors directly, although it provides no information beyond simple success/failure.
    ///
    /// - Parameters:
    
    ///   - delegate: An object that can serve as the receiver's delegate. It should implement the method specified by didCommitSelector.
    
    ///   - didCommitSelector: A selector that is invoked on delegate. The method specified by the selector must have the same signature as the following method:
    
    /// (void)editor:(id)editor didCommit:(BOOL)didCommit contextInfo:(void  *)contextInfo
    
    ///   - contextInfo: Contextual information that is sent as the contextInfo argument to delegate when didCommitSelector is invoked.
    func commitEditing(withDelegate delegate: EditorDelegate, contextInfo: Any?) -> Void
    
    /// A Boolean value indicating if any editors are registered with the controller.
    var editing: Bool { get }
}

protocol EditorDelegate {
    func editor(_ editor: Editor, didCommit committed: Bool, contextInfo: Any?) -> Void
}


/// A set of methods that an object can implement to register default placeholders to be displayed for a binding, when no other placeholder is specified.
///Individual placeholder values can be specified for each of the marker objects (described in Selection Markers), as well as when the property is nil.

/// Placeholders are used when a property of an instance of the receiving class is accessed through a key value coding compliant method, and returns nil or a specialized marker.
protocol Placeholder {
    
    /// Sets placeholder as the default placeholder for the binding, when a key value coding compliant property of an instance of the receiving class returns the value specified by marker, and no other placeholder has been specified.
    /// The marker can be nil or one of the constants described in Selection Markers.
    ///
    /// - Parameters:
    ///   - placeholder: <#placeholder description#>
    ///   - marker: <#marker description#>
    ///   - binding: <#binding description#>
    static func setDefaultPlaceholder(_ placeholder: Any?, forMarker marker: BindingMarker, withBinding binding: BindingName)
    
    /// Returns an object that will be used as the placeholder for the binding, when a key value coding compliant property of an instance of the receiving class returns the value specified by marker, and no other placeholder has been specified.
    /// The marker can be nil or one of the constants described in Selection Markers.
    ///
    /// - Parameters:
    ///   - marker: <#marker description#>
    ///   - binding: <#binding description#>
    /// - Returns: <#return value description#>
    static func defaultPlaceholder(forMarker marker: BindingMarker, withBinding binding: BindingName) -> Any?
}



/// A set of methods that you can use to create and remove bindings between view objects and controllers, or between controllers and model objects.
/// The NSKeyValueBindingCreation informal protocol also provides a means for a view subclass to advertise the bindings that it exposes. The protocol is implemented by NSObject and its methods can be overridden by view and controller subclasses.

/// When a new binding is created it relates the receiver’s binding (for example, a property of the view object) to a property of the observable object specified by a key path. When the value of the specified property of the observable object changes, the receiver is notified using the key-value observing mechanism. A binding also specifies binding options that can further customize how the observing and the observed objects interact.

/// Bindings are considered to be a property of the object which is bound, and all information related to bindings should be owned by the object. All standard bindings on AppKit objects (views, cells, table columns, controllers) unbind their bindings automatically when they are deallocated, but if you create key-value bindings for other kind of objects, you need to make sure that you remove those bindings before deallocation (observed objects have weak references to their observers, so controllers/model objects might continue referencing and messaging the objects that were bound to them).

/// Bindings between objects are typically established in Interface Builder using the Bindings inspector. However, there are times it must be done programmatically, such as when establishing a binding between objects in different nib files.

/// NSView subclasses can expose additional key-value-coding/key-value-observing compliant properties as bindings by calling the class method exposeBinding(_:) for each of the properties. This is typically done in the class’s initialize method. By exposing the bindings that an object supports and creating an Interface Builder palette, you can make instances of your own classes bindable in Interface Builder.
protocol KeyValueBindingCreation {
    
    
    /// bindings specified here will be exposed automatically in -exposedBindings (unless implementations explicitly filter them out, for example in subclasses)
    ///
    /// - Parameter Binding: <#Binding description#>
    static func exposeBinding(_ Binding: BindingName)
    
    /// for a new key exposed through this method, the default implementation simply falls back to key-value coding
    var exposedBindings: [BindingName] { get }
    
    /// optional - mostly for matching transformers
    ///
    /// - Parameter Binding: <#Binding description#>
    func valueClassForBinding(_ Binding: BindingName) -> AnyClass? // This may need to be updated to Any to account for non-class types
    
    /// Bindings are considered to be a property of the object which is bound (the object the following two methods are sent to) and all information related to bindings should be retained by the object; all standard bindings on AppKit objects (views, cells, table columns, controllers) unbind their bindings automatically when they are released, but if you create key-value bindings for other kind of objects, you need to make sure that you remove those bindings when you release them (observed objects don't retain their observers, so controllers/model objects might continue referencing and messaging the objects that was bound to them).
    /// placeholders and value transformers are specified in options dictionary
    ///
    /// - Parameters:
    ///   - Binding: <#Binding description#>
    ///   - observable: <#observable description#>
    ///   - keyPath: <#keyPath description#>
    ///   - options: <#options description#>
    func bind(_ binding: BindingName, to observable: AnyObject, withKeyPath keyPath: String, options: [BindingOption : Any]?)
    
    /// Returns an array of NSAttributeDescriptions that describe the options for aBinding. The descriptions are used by Interface Builder to build the options editor UI of the bindings inspector. Each binding may have multiple options. The options and attribute descriptions have 3 properties in common:
    
    /// - The option "name" is derived from the attribute description name.
    
    /// - The type of UI built for the option is based on the attribute type.
    
    /// - The default value shown in the options editor comes from the attribute description's defaultValue.
    ///
    /// - Parameter Binding: <#Binding description#>
    func optionDescriptionsForBinding(_ binding: BindingName) -> [NSAttributeDescription]
    
    /// Returns a dictionary with information about a binding or nil if the binding is not bound (this is mostly for use by subclasses which want to analyze the existing bindings of an object) - the dictionary contains three key/value pairs: RNDObservedObjectKey: object bound, RNDObservedKeyPathKey: key path bound, RNDOptionsKey: dictionary with the options and their values for the bindings.
    ///
    /// - Parameter Binding: <#Binding description#>
    func infoForBinding(_ binding: BindingName) -> [BindingInfoKey : Any]?
    
    /// <#Description#>
    ///
    /// - Parameter Binding: <#Binding description#>
    func unbind(_ binding: BindingName)
}


/// Values that specify a binding for certain methods.
/// The following values are used to specify a binding to bind(_:to:withKeyPath:options:), infoForBinding(_:), unbind(_:) and valueClassForBinding(_:). See Cocoa Bindings Reference for more information.
///
/// - alignment: <#alignment description#>
/// - alternateImage: <#alternateImage description#>
/// - alternateTitle: <#alternateTitle description#>
/// - animate: <#animate description#>
/// - animationDelay: <#animationDelay description#>
/// - argument: <#argument description#>
/// - attributedString: <#attributedString description#>
/// - contentArray: <#contentArray description#>
/// - contentArrayForMultipleSelection: <#contentArrayForMultipleSelection description#>
/// - content: <#content description#>
/// - contentDictionary: <#contentDictionary description#>
/// - contentHeight: <#contentHeight description#>
/// - contentObject: <#contentObject description#>
/// - contentObjects: <#contentObjects description#>
/// - contentSet: <#contentSet description#>
/// - contentValues: <#contentValues description#>
/// - contentWidth: <#contentWidth description#>
/// - criticalValue: <#criticalValue description#>
/// - data: <#data description#>
/// - displayPatternTitle: <#displayPatternTitle description#>
/// - displayPatternValue: <#displayPatternValue description#>
/// - documentEdited: <#documentEdited description#>
/// - doubleClickArgument: <#doubleClickArgument description#>
/// - doubleClickTarget: <#doubleClickTarget description#>
/// - editable: <#editable description#>
/// - enabled: <#enabled description#>
/// - excludedKeys: <#excludedKeys description#>
/// - filterPredicate: <#filterPredicate description#>
/// - font: <#font description#>
/// - fontBold: <#fontBold description#>
/// - fontFamilyName: <#fontFamilyName description#>
/// - fontItalic: <#fontItalic description#>
/// - fontName: <#fontName description#>
/// - fontSize: <#fontSize description#>
/// - headerTitle: <#headerTitle description#>
/// - hidden: <#hidden description#>
/// - image: <#image description#>
/// - includedKeys: <#includedKeys description#>
/// - initialKey: <#initialKey description#>
/// - initialValue: <#initialValue description#>
/// - isIndeterminate: <#isIndeterminate description#>
/// - label: <#label description#>
/// - localizedKeyDictionary: <#localizedKeyDictionary description#>
/// - managedObjectContext: <#managedObjectContext description#>
/// - maximumRecents: <#maximumRecents description#>
/// - maxValue: <#maxValue description#>
/// - maxWidth: <#maxWidth description#>
/// - minValue: <#minValue description#>
/// - minWidth: <#minWidth description#>
/// - mixedStateImage: <#mixedStateImage description#>
/// - offStateImage: <#offStateImage description#>
/// - onStateImage: <#onStateImage description#>
/// - positioningRect: <#positioningRect description#>
/// - predicate: <#predicate description#>
/// - recentSearches: <#recentSearches description#>
/// - representedFilename: <#representedFilename description#>
/// - rowHeight: <#rowHeight description#>
/// - selectedIdentifier: <#selectedIdentifier description#>
/// - selectedIndex: <#selectedIndex description#>
/// - selectedLabel: <#selectedLabel description#>
/// - selectedObject: <#selectedObject description#>
/// - selectedObjects: <#selectedObjects description#>
/// - selectedTag: <#selectedTag description#>
/// - selectedValue: <#selectedValue description#>
/// - selectedValues: <#selectedValues description#>
/// - selectionIndexes: <#selectionIndexes description#>
/// - selectionIndexPaths: <#selectionIndexPaths description#>
/// - sortDescriptors: <#sortDescriptors description#>
/// - target: <#target description#>
/// - textColor: <#textColor description#>
/// - title: <#title description#>
/// - toolTip: <#toolTip description#>
/// - transparent: <#transparent description#>
/// - value: <#value description#>
/// - valuePath: <#valuePath description#>
/// - valueURL: <#valueURL description#>
/// - visible: <#visible description#>
/// - warningValue: <#warningValue description#>
/// - width: <#width description#>
enum BindingName: String {
    case alignment = "RNDAlignment"
    case alternateImage = "RNDAlternateImage"
    case alternateTitle = "RNDAlternateTitle"
    case animate = "RNDAnimate"
    case animationDelay = "RNDAnimationDelay"
    case argument = "RNDArgument"
    case attributedString = "RNDAttributedString"
    case contentArray = "RNDContentArray"
    case contentArrayForMultipleSelection = "RNDContentArrayForMultipleSelection"
    case content = "RNDContent"
    case contentDictionary = "RNDContentDictionary"
    case contentHeight = "RNDContentHeight"
    case contentObject = "RNDContentObject"
    case contentObjects = "RNDContentObjects"
    case contentSet = "RNDContentSet"
    case contentValues = "RNDContentValues"
    case contentWidth = "RNDContentWidth"
    case criticalValue = "RNDCriticalValue"
    case data = "RNDData"
    case displayPatternTitle = "RNDDisplayPatternTitle"
    case displayPatternValue = "RNDDisplayPatternValue"
    case documentEdited = "RNDDocumentEdited"
    case doubleClickArgument = "RNDDoubleClickArgument"
    case doubleClickTarget = "RNDDoubleClickTarget"
    case editable = "RNDEditable"
    case enabled = "RNDEnabled"
    case excludedKeys = "RNDExcludedKeys"
    case filterPredicate = "RNDFilterPredicate"
    case font = "RNDFont"
    case fontBold = "RNDFontBold"
    case fontFamilyName = "RNDFontFamilyName"
    case fontItalic = "RNDFontItalic"
    case fontName = "RNDFontName"
    case fontSize = "RNDFontSize"
    case headerTitle = "RNDHeaderTitle"
    case hidden = "RNDHidden"
    case image = "RNDImage"
    case includedKeys = "RNDIncludedKeys"
    case initialKey = "RNDInitialKey"
    case initialValue = "RNDInitialValue"
    case isIndeterminate = "RNDIsIndeterminate"
    case label = "RNDLabel"
    case localizedKeyDictionary = "RNDLocalizedKeyDictionary"
    case managedObjectContext = "RNDManagedObjectContext"
    case maximumRecents = "RNDMaximumRecents"
    case maxValue = "RNDMaxValue"
    case maxWidth = "RNDMaxWidth"
    case minValue = "RNDMinValue"
    case minWidth = "RNDMinWidth"
    case mixedStateImage = "RNDMixedStateImage"
    case offStateImage = "RNDOffStateImage"
    case onStateImage = "RNDOnStateImage"
    case positioningRect = "RNDPositioningRect"
    case predicate = "RNDPredicate"
    case recentSearches = "RNDRecentSearches"
    case representedFilename = "RNDRepresentedFilename"
    case rowHeight = "RNDRowHeight"
    case selectedIdentifier = "RNDSelectedIdentifier"
    case selectedIndex = "RNDSelectedIndex"
    case selectedLabel = "RNDSelectedLabel"
    case selectedObject = "RNDSelectedObject"
    case selectedObjects = "RNDSelectedObjects"
    case selectedTag = "RNDSelectedTag"
    case selectedValue = "RNDSelectedValue"
    case selectedValues = "RNDSelectedValues"
    case selectionIndexes = "RNDSelectionIndexes"
    case selectionIndexPaths = "RNDSelectionIndexPaths"
    case sortDescriptors = "RNDSortDescriptors"
    case target = "RNDTarget"
    case textColor = "RNDTextColor"
    case title = "RNDTitle"
    case toolTip = "RNDToolTip"
    case transparent = "RNDTransparent"
    case value = "RNDValue"
    case valuePath = "RNDValuePath"
    case valueURL = "RNDValueURL"
    case visible = "RNDVisible"
    case warningValue = "RNDWarningValue"
    case width = "RNDWidth"

}


/// Values that are used as keys in the options dictionary passed to the bind(_:to:withKeyPath:options:) method.
/// These keys are also used in the dictionary returned as the options value of infoForBinding(_:). See the Cocoa Bindings Reference for more information.
///
/// - allowsEditingMultipleValuesSelection: An NSNumber object containing a Boolean value that determines if the binding allows editing when the value represents a multiple selection.
/// - allowsNullArgument: An NSNumber object containing a Boolean value that determines if the argument bindings allows passing argument values of nil.
/// - alwaysPresentsApplicationModalAlerts: A number containing a Boolean value that determines if validation and error alert panels displayed as a result of this binding are displayed as application modal alerts.
/// - conditionallySetsEditable: An NSNumber object containing a Boolean value that determines if the editable state of the user interface item is automatically configured based on the controller's selection.
/// - conditionallySetsEnabled: An NSNumber object containing a Boolean value that determines if the enabled state of the user interface item is automatically configured based on the controller's selection.
/// - conditionallySetsHidden: An NSNumber object containing a Boolean value that determines if the hidden state of the user interface item is automatically configured based on the controller's selection.
/// - continuouslyUpdatesValue: An NSNumber object containing a Boolean value that determines whether the value of the binding is updated as edits are made to the user interface item or is updated only when the user interface item resigns as the responder.
/// - createsSortDescriptor: An NSNumber object containing a Boolean value that determines if a sort descriptor is created for a table column.
/// - deletesObjectsOnRemove: An NSNumber object containing a Boolean value that determines if an object is deleted from the managed context immediately upon being removed from a relationship.
/// - displayName: An NSString object containing a human readable string to be displayed for a predicate.
/// - displayPattern: An NSString object that specifies a format string used to construct the final value of a string.
/// - contentPlacementTag: A number that specifies the tag id of the popup menu item to replace with the content of the array.
/// - handlesContentAsCompoundValue: An NSNumber object containing a Boolean value that determines if the content is treated as a compound value.
/// - insertsNullPlaceholder: An NSNumber object containing a Boolean value that determines if an additional item which represents nil is inserted into a matrix or pop-up menu before the items in the content array.
/// - invokesSeparatelyWithArrayObjects: An NSNumber object containing a Boolean value that determines whether the specified selector is invoked with the array as the argument or is invoked repeatedly with each array item as an argument.
/// - multipleValuesPlaceholder: An object that is used as a placeholder when the key path of the bound controller returns the NSMultipleValuesMarker marker for a binding.
/// - noSelectionPlaceholder: An object that is used as a placeholder when the key path of the bound controller returns the NSNoSelectionMarker marker for a binding.
/// - notApplicablePlaceholder: An object that is used as a placeholder when the key path of the bound controller returns the NSNotApplicableMarker marker for a binding.
/// - nullPlaceholder: An object that is used as a placeholder when the key path of the bound controller returns nil for a binding.
/// - raisesForNotApplicableKeys: An NSNumber object containing a Boolean value that specifies if an exception is raised when the binding is bound to a key that is not applicable—for example when an object is not key-value coding compliant for a key.
/// - predicateFormat: An NSString object containing the predicate pattern string for the predicate bindings. Use $value to refer to the value in the search field.
/// - selectorName: An NSString object that specifies the method selector invoked by the target binding when the user interface item is clicked.
/// - selectsAllWhenSettingContent: An NSNumber object containing a Boolean value that specifies if all the items in the array controller are selected when the content is set.
/// - validatesImmediately: An NSNumber object containing a Boolean value that determines if the contents of the binding are validated immediately.
/// - valueTransformerName: The value for this key is an identifier of a registered NSValueTransformer instance that is applied to the bound value.
/// - valueTransformer: An NSValueTransformer instance that is applied to the bound value.
enum BindingOption: String {
    case allowsEditingMultipleValuesSelection = "RNDAllowsEditingMultipleValuesSelectionBindingOption"
    case allowsNullArgument = "RNDAllowsNullArgumentBindingOption"
    case alwaysPresentsApplicationModalAlerts = "RNDAlwaysPresentsApplicationModalAlertsBindingOption"
    case conditionallySetsEditable = "RNDConditionallySetsEditableBindingOption"
    case conditionallySetsEnabled = "RNDConditionallySetsEnabledBindingOption"
    case conditionallySetsHidden = "RNDConditionallySetsHiddenBindingOption"
    case continuouslyUpdatesValue = "RNDContinuouslyUpdatesValueBindingOption"
    case createsSortDescriptor = "RNDCreatesSortDescriptorBindingOption"
    case deletesObjectsOnRemove = "DeletesObjectsOnRemoveBindingOption"
    case displayName = "RNDDisplayNameBindingOption"
    case displayPattern = "RNDDisplayPatternBindingOption"
    case contentPlacementTag = "RNDContentPlacementTagBindingOption"
    case handlesContentAsCompoundValue = "RNDHandlesContentAsCompoundValueBindingOption"
    case insertsNullPlaceholder = "RNDInsertsNullPlaceholderBindingOption"
    case invokesSeparatelyWithArrayObjects = "RNDInvokesSeparatelyWithArrayObjectsBindingOption"
    case multipleValuesPlaceholder = "RNDMultipleValuesPlaceholderBindingOption"
    case noSelectionPlaceholder = "RNDNoSelectionPlaceholderBindingOption"
    case notApplicablePlaceholder = "RNDNotApplicablePlaceholderBindingOption"
    case nullPlaceholder = "RNDNullPlaceholderBindingOption"
    case raisesForNotApplicableKeys = "RNDRaisesForNotApplicableKeysBindingOption"
    case predicateFormat = "RNDPredicateFormatBindingOption"
    case selectorName = "RNDSelectorNameBindingOption"
    case selectsAllWhenSettingContent = "RNDSelectsAllWhenSettingContentBindingOption"
    case validatesImmediately = "RNDValidatesImmediatelyBindingOption"
    case valueTransformerName = "RNDValueTransformerNameBindingOption"
    case valueTransformer = "RNDValueTransformerBindingOption"
}


/// Keys used by the informational dictionary returned by the KeyValueCreation protocol infoForBinding method.
///
/// - observedObject: Key for the object observed by the binding.
/// - observedKeyPath: Key for the observed object's property key path that is tracked for changes by the binding.
/// - options: Key for the array of BindingOptions applied to the binding.
enum BindingInfoKey: String {
    case observedObject = "RNDObservedObjectKey"
    case observedKeyPath = "RNDObservedKeyPathKey"
    case options = "RNDOptionsKey"
    
    
}


/// The following constants are used to describe special cases for a controller’s selection.
///
/// - multipleValues: This marker indicates that a key’s value contains multiple values that differ.
/// - noSelection: This marker indicates that the controller’s selection is currently empty.
/// - notApplicable: This marker indicates that an object is not key-value coding compliant for the requested key.
enum BindingMarker: String {
    case multipleValues = "RNDMultipleValuesBindingMarker"
    case noSelection = "RNDNoSelectionBindingMarker"
    case notApplicable = "RNDNotApplicableBindingMarker"
    case nilValue = "RNDNilValue"
}


