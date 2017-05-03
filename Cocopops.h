//
//  2017 Magna cum laude. PD
//

#import "bezier.h"
#import "choose.h"
#import "search.h"

#ifdef __OBJC__

#import "NSArray+Choose.h"
#import "NSArray+CreateByBlock.h"
#import "NSArray+Cycle.h"
#import "NSArray+Deduplicate.h"
#import "NSArray+DeepCopy.h"
#import "NSArray+DeriveArray.h"
#import "NSArray+FilterByBlock.h"
#import "NSArray+IndexPathTraversal.h"
#import "NSArray+Patchworks.h"
#import "NSArray+PointerArray.h"
#import "NSArray+RemoveObject.h"
#import "NSArray+ReplaceObject.h"
#import "NSArray+Shuffle.h"
#import "NSArray+Subarrays.h"
#import "NSArray+SubstituteNil.h"
#import "NSData+RandomData.h"
#import "NSData+ZLibCompression.h"
#import "NSDictionary+CollectionValues.h"
#import "NSDictionary+IgnoreNil.h"
#import "NSDictionary+ProxyDictionary.h"
#import "NSDictionary+ValueArray.h"
#import "NSFileManager+DirectorySize.h"
#import "NSIndexSet+Arrays.h"
#import "NSObject+AddSyntheticProperty.h"
#import "NSObject+SwizzleMethods.h"
#import "NSSet+DeriveSet.h"
#import "NSSet+Intersection.h"
#import "NSSet+RemoveObject.h"

#endif // __OBJC__

#if TARGET_OS_IPHONE

#import "DispatchBarButtonItem.h"
#import "DispatchTableViewController.h"
#import "InAppPurchaseController.h"
#import "LinedSectionsFlowLayout.h"
#import "PopoverNavigationController.h"
#import "SlideshowImageView.h"
#import "StackedFlowLayout.h"
#import "TwoDimensionalLayout.h"
#import "UIApplication+GetFirstResponder.h"
#import "UICollectionView+PinchToZoom.h"
#import "UICollectionView+SupplementaryTracking.h"
#import "UIDevice+MachineProperties.h"
#import "UIImageView+PDFSupport.h"

#endif // TARGET_OS_IPHONE

#if TARGET_OS_IOS

#import "UIApplication+KeyboardFrame.h"
#import "UICollectionViewController+KeyboardMgmt.h"
#import "UIPopoverController+UniversalSupport.h"

#import "AdBannerViewController.h"
#import "CollapsibleTableSectionHeaderView.h"
#import "DispatchActionSheet.h"
#import "DispatchAlertView.h"
#import "DispatchPickerView.h"
#import "GestureDrivenTabController.h"
#import "InputAccessoryToolbar.h"
#import "UserDefaultsSwitch.h"

#elif TARGET_OS_TV

#import "TVPickerView.h"

#endif // TARGET_OS_IOS / TARGET_OS_TV
