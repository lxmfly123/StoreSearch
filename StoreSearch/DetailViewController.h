//
//  DetailViewController.h
//  StoreSearch
//
//  Created by FLY.lxm on 11/13/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;

@interface DetailViewController : UIViewController

@property (nonatomic, strong) SearchResult *searchResult;

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewController;

@end
