//
//  RNDBindings.swift
//  RNDBindableObjects-ObjC
//
//  Created by Erikheath Thomas on 6/25/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

import Foundation
import CoreData


/// <#Description#>
protocol EditorRegistration {
    
    /// <#Description#>
    ///
    /// - Parameter editor: <#editor description#>
    /// - Returns: <#return value description#>
    func objectDidBeginEditing(_ editor: AnyObject) -> Void
    
    /// <#Description#>
    ///
    /// - Parameter editor: <#editor description#>
    /// - Returns: <#return value description#>
    func objectDidEndEditing(_ editor: AnyObject) -> Void
}


/// <#Description#>
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
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - delegate: <#delegate description#>
    ///   - didCommitSelector: <#didCommitSelector description#>
    ///   - contextInfo: <#contextInfo description#>
    func commitEditing(withDelegate delegate: Any?, didCommit didCommitSelector: Selector?, contextInfo: UnsafeMutableRawPointer?)
    
    /// <#Description#>
    var editing: Bool { get }
}


/// <#Description#>
protocol Placeholder {
    
}



/// <#Description#>
protocol KeyValueBindingCreation {
    
    
    /// <#Description#>
    ///
    /// - Parameter Binding: <#Binding description#>
    static func exposeBinding(_ Binding: BindingName)
    
    /// <#Description#>
    var exposedBindings: [BindingName] { get }
    
    /// <#Description#>
    ///
    /// - Parameter Binding: <#Binding description#>
    func valueClassForBinding(_ Binding: BindingName) -> AnyClass? // This may need to be updated to Any to account for non-class types
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - Binding: <#Binding description#>
    ///   - observable: <#observable description#>
    ///   - keyPath: <#keyPath description#>
    ///   - options: <#options description#>
    func bind(_ Binding: BindingName, to observable: Any, withKeyPath keyPath: String, options: [BindingOption : Any]?)
    
    /// <#Description#>
    ///
    /// - Parameter Binding: <#Binding description#>
    func optionDescriptionsForBinding(_ Binding: BindingName) -> [NSAttributeDescription]
    
    /// <#Description#>
    ///
    /// - Parameter Binding: <#Binding description#>
    func infoForBinding(_ Binding: BindingName) -> [BindingInfoKey : Any]?
    
    /// <#Description#>
    ///
    /// - Parameter Binding: <#Binding description#>
    func unbind(_ Binding: BindingName)
}


/// <#Description#>
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


/// <#Description#>
///
/// - allowsEditingMultipleValuesSelection: <#allowsEditingMultipleValuesSelection description#>
/// - allowsNullArgument: <#allowsNullArgument description#>
/// - alwaysPresentsApplicationModalAlerts: <#alwaysPresentsApplicationModalAlerts description#>
/// - conditionallySetsEditable: <#conditionallySetsEditable description#>
/// - conditionallySetsEnabled: <#conditionallySetsEnabled description#>
/// - conditionallySetsHidden: <#conditionallySetsHidden description#>
/// - continuouslyUpdatesValue: <#continuouslyUpdatesValue description#>
/// - createsSortDescriptor: <#createsSortDescriptor description#>
/// - deletesObjectsOnRemove: <#deletesObjectsOnRemove description#>
/// - displayName: <#displayName description#>
/// - displayPattern: <#displayPattern description#>
/// - contentPlacementTag: <#contentPlacementTag description#>
/// - handlesContentAsCompoundValue: <#handlesContentAsCompoundValue description#>
/// - insertsNullPlaceholder: <#insertsNullPlaceholder description#>
/// - invokesSeparatelyWithArrayObjects: <#invokesSeparatelyWithArrayObjects description#>
/// - multipleValuesPlaceholder: <#multipleValuesPlaceholder description#>
/// - noSelectionPlaceholder: <#noSelectionPlaceholder description#>
/// - notApplicablePlaceholder: <#notApplicablePlaceholder description#>
/// - nullPlaceholder: <#nullPlaceholder description#>
/// - raisesForNotApplicableKeys: <#raisesForNotApplicableKeys description#>
/// - predicateFormat: <#predicateFormat description#>
/// - selectorName: <#selectorName description#>
/// - selectsAllWhenSettingContent: <#selectsAllWhenSettingContent description#>
/// - validatesImmediately: <#validatesImmediately description#>
/// - valueTransformerName: <#valueTransformerName description#>
/// - valueTransformer: <#valueTransformer description#>
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


/// <#Description#>
///
/// - multipleValues: <#multipleValues description#>
/// - noSelection: <#noSelection description#>
/// - notApplicable: <#notApplicable description#>
enum BindingMarker: String {
    case multipleValues = "RNDMultipleValuesBindingMarker"
    case noSelection = "RNDNoSelectionBindingMarker"
    case notApplicable = "RNDNotApplicableBindingMarker"
}


