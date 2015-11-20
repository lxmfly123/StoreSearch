//
//  LandscapeViewController.m
//  StoreSearch
//
//  Created by FLY.lxm on 11/17/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import "LandscapeViewController.h"
#import "SearchResult.h"
#import <AFNetworking/UIButton+AFNetworking.h>

@interface LandscapeViewController () <UIScrollViewDelegate>

@end

@implementation LandscapeViewController
{
    BOOL _isFirstTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LandscapeBackground"]];
    self.scrollView.contentSize = CGSizeMake(1000, self.scrollView.bounds.size.height);
    self.pageControl.numberOfPages = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        _isFirstTime = YES;
    }
    return self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (_isFirstTime) {
        _isFirstTime =  NO;
        [self titleButtons];
    }
}

- (void)dealloc {    
    for (UIButton *button in self.scrollView.subviews) {
        if ([button isMemberOfClass:[UIButton class]]) {
            [button cancelImageRequestOperationForState:UIControlStateNormal];
        }
    }
}

#pragma mark - Logic

- (void)downloadImageForSearchResult:(SearchResult *)searchResult andPlaceOnButton:(UIButton *)button {
    NSURL *url = [NSURL URLWithString:searchResult.artworkURL100];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    __weak UIButton *weakButton = button;
    [button setImageForState:UIControlStateNormal 
              withURLRequest:request 
            placeholderImage:nil 
                     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) { 
                         UIImage *unscaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:image.imageOrientation];
                         [weakButton setImage:unscaledImage forState:UIControlStateNormal];
                     } 
                     failure:^(NSError * _Nonnull error) {
                         NSLog(@"error: %@", error);
                     }
     ];
}

- (void)titleButtons {
    int columnsPerPage = 5;
    CGFloat itemWidth = 96;
    CGFloat x = 0;
    CGFloat extraSpace = 0;
    
    CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
    if (scrollViewWidth > 480) {
        columnsPerPage = 6;
        itemWidth = 94.0f;
        x = 2.0f;
        extraSpace = 4.0f;
    }
    
    const CGFloat itemHeight = 88;
    const CGFloat buttonWidth = 82.0f;
    const CGFloat buttonHeight = 82.0f;
    const CGFloat marginHorz = (itemWidth - buttonWidth)/2.0f;
    const CGFloat marginVert = (itemHeight - buttonHeight)/2.0f;
    
    int index = 0;
    int row = 0;
    int column = 0;
    
    for (SearchResult *searchResult in self.searchResults) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"LandscapeButton"] forState:UIControlStateNormal];
        [self downloadImageForSearchResult:searchResult andPlaceOnButton:button];
        button.frame = CGRectMake(x + marginHorz, 20.0f + row*itemHeight + marginVert, buttonWidth, buttonHeight);
//        [button setImage:[UIImage imageNamed:@"CloseButton"] forState:UIControlStateNormal];
        [self.scrollView addSubview:button];
        
        index++;
        row++;
        
        if (row == 3) {
            row = 0;
            column++;
            x += itemWidth;
            
           
            if (column == columnsPerPage) {
                column = 0;
                x += extraSpace;
            }
        }
    }
    
    int tilesPerPage = columnsPerPage * 3;
    int numPages = ceilf([self.searchResults count] / (float)tilesPerPage); 
    self.scrollView.contentSize = CGSizeMake(numPages * scrollViewWidth, self.scrollView.bounds.size.height);
    self.pageControl.numberOfPages = numPages;
    self.pageControl.currentPage = 0;
}

#pragma mark - IBAction

- (IBAction)pageChanged:(UIPageControl *)sender {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.contentOffset = CGPointMake(sender.currentPage * self.scrollView.bounds.size.width, 0);
    } completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = self.scrollView.bounds.size.width;
    int currentPage = (scrollView.contentOffset.x + width / 2) / width;
    self.pageControl.currentPage = currentPage;
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    CGFloat width = self.scrollView.bounds.size.width;
//    int currentPage = (scrollView.contentOffset.x + width / 2) / width;
//    NSLog(@"%f", scrollView.contentOffset.x);
//    self.pageControl.currentPage = currentPage;
//    
//    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        scrollView.contentOffset = CGPointMake(self.pageControl.currentPage * scrollView.bounds.size.width, 0);
//    } 
//                     completion:nil];
//}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//    [coordinator t];
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
