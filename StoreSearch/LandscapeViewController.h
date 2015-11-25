//
//  LandscapeViewController.h
//  StoreSearch
//
//  Created by FLY.lxm on 11/17/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Search;

@interface LandscapeViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) Search *search;


- (void)searchResultsReceived;

@end
