//
//  2014 Magna cum laude. PD
//

#import "UICollectionViewController+KeyboardMgmt.h"

@implementation UICollectionViewController (KeyboardManagement)

- (void)startKeyboardAutoAdjusting
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)stopKeyboardAutoAdjusting
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification*)aNotification
{
	CGRect kbdFrame = [aNotification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect adjustedFrame = [self.view convertRect:kbdFrame fromView:self.view.window];

    UIEdgeInsets contentInset = self.collectionView.contentInset;
    contentInset.bottom = adjustedFrame.size.height;
    self.collectionView.contentInset = contentInset;
    self.collectionView.scrollIndicatorInsets = contentInset;

    // Scroll the currently selected cell, if needed, so it remains visible
    UICollectionViewCell *activeCell = [self.collectionView cellForItemAtIndexPath:self.collectionView.indexPathsForSelectedItems.lastObject];
    if (activeCell)
    {
        CGRect aRect = self.view.frame;
        aRect.size.height -= adjustedFrame.size.height;
        if (!CGRectContainsPoint(aRect, activeCell.frame.origin) )
        {
            [self.collectionView scrollRectToVisible:activeCell.frame animated:YES];
        }
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    contentInset.bottom = 0.0;
    self.collectionView.contentInset = contentInset;
    self.collectionView.scrollIndicatorInsets = contentInset;
}

@end
