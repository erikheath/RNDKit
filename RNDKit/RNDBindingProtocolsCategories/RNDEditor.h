//
//  RNDEditor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDEditorDelegate.h"


// methods implemented by controllers, CoreData's managed object contexts, and user interface elements
@protocol RNDEditor <NSObject>

- (void)discardBoundEdit;    // forces changing to end (reverts back to the original value)
- (BOOL)commitBoundEdit;    // returns whether end editing was successful (while trying to apply changes to a model object, there might be validation problems or so that prevent the operation from being successful


/* Given that the receiver has been registered with -objectDidBeginEditing: as the editor of some object, and not yet deregistered by a subsequent invocation of -objectDidEndEditing:, attempt to commit the result of the editing. When committing has either succeeded or failed, send the selected message to the specified object with the context info as the last parameter. The method selected by didCommitSelector must have the same signature as:
 
 - (void)editor:(id)editor didCommit:(BOOL)didCommit contextInfo:(void *)contextInfo error:(NSError **)error;
 
 If an error occurs while attempting to commit, because key-value coding validation fails for example, an implementation of this method should typically send the NSView in which editing is being done a -presentError:modalForWindow:delegate:didRecoverSelector:contextInfo: message, specifying the view's containing window.
 */
- (void)commitBoundEditWithDelegate:(nullable id<RNDEditorDelegate>)delegate contextInfo:(nullable void *)contextInfo;


/* During autosaving, commit editing may fail, due to a pending edit.  Rather than interrupt the user with an unexpected alert, this method provides the caller with the option to either present the error or fail silently, leaving the pending edit in place and the user's editing uninterrupted.  This method attempts to commit editing, but if there is a failure the error is returned to the caller to be presented or ignored as appropriate.  If an error occurs while attempting to commit, an implementation of this method should return NO as well as the generated error by reference.  Returns YES if commit is successful.
 
 If you have enabled autosaving in your application, and your application has custom objects that implement or override the NSEditor protocol, you must also implement this method in those NSEditors.
 */
- (BOOL)commitBoundEditAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

