//
//  RNDBindings.swift
//  RNDBindableObjects-ObjC
//
//  Created by Erikheath Thomas on 6/25/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

import Foundation
import CoreData

protocol EditorRegistration {
    func objectDidBeginEditing(_ editor: AnyObject) -> Void
    func objectDidEndEditing(_ editor: AnyObject) -> Void
}

protocol Editor {
    func discardEditing() -> Void
    func commitEditing() throws -> Void
    func commitEditing(withDelegate delegate: Any?, didCommit didCommitSelector: Selector?, contextInfo: UnsafeMutableRawPointer?)
    var editing: Bool { get }
}

protocol Placeholder {
    
}

protocol KeyValueBindingCreation {
    static func exposeBinding(_ Binding: BindingName)
    var exposedBindings: [BindingName] { get }
    func valueClassForBinding(_ Binding: BindingName) -> AnyClass? // This may need to be updated to Any to account for non-class types
    func bind(_ Binding: BindingName, to observable: Any, withKeyPath keyPath: String, options: [BindingOption : Any]?)
    func optionDescriptionsForBinding(_ Binding: BindingName) -> [NSAttributeDescription]
    func infoForBinding(_ Binding: BindingName) -> [BindingInfoKey : Any]?
    func unbind(_ Binding: BindingName)
}

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

// keys for the returned dictionary of -infoForBinding:
enum BindingInfoKey: String {
    case observedObject = "RNDObservedObjectKey"
    case observedKeyPath = "RNDObservedKeyPathKey"
    case options = "RNDOptionsKey"
}

enum BindingMarker {
    case multipleValues = "RNDMultipleValuesBindingMarker"
    case noSelection = "RNDNoSelectionBindingMarker"
    case notApplicable = "RNDNotApplicableBindingMarker"
}


