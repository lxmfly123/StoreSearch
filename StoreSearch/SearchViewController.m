//
//  SearchViewController.m
//  StoreSearch
//
//  Created by FLY.lxm on 11/10/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"
#import "DetailViewController.h"
#import "LandscapeViewController.h"
#import "Search.h"
#import <AFNetworking/AFNetworking.h>

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedContol;

@property (nonatomic, strong) Search *search;

@end

@implementation SearchViewController
{
    Search *_search;
    
    LandscapeViewController *_landscapeViewController;
    UIStatusBarStyle _statusBarStyle;
    DetailViewController *_detailViewController;
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
//        _queue = [NSOperationQueue new];
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.cornerRadius = 10;
    _statusBarStyle = UIStatusBarStyleDefault;
    
    [self.searchBar becomeFirstResponder];
    
    self.tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    self.tableView.rowHeight = 80;
    
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:@"NothingFoundCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    cellNib = [UINib nibWithNibName:@"LoadingCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logic

- (void)performSearch {
    _search = [[Search alloc] init];
    
    [_search performSearchForText:self.searchBar.text 
                         category:self.segmentedContol.selectedSegmentIndex 
                       completion:^(BOOL success) {
                           if (!success) {
                               [self showNetworkError];
                           }
                           [_landscapeViewController searchResultsReceived]; 
                           [self.tableView reloadData];
                       }
     ];
    
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}



- (void)showNetworkError {
    NSString *title = NSLocalizedString(@"Error", @"Network Error Message Title");
    NSString *message = NSLocalizedString(@"There is a error in your network.", @"Network Error Message.");
    NSString *okButton = NSLocalizedString(@"OK", @"OK Button Text");
    UIAlertController *alert =[UIAlertController alertControllerWithTitle:title 
                                                                  message:message  
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAlert = [UIAlertAction actionWithTitle:okButton style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
}





// This method is for iOS less than iOS 8.
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self hideLandscapeViewWithDuration:duration];
    } else {
        [self showLandscapeViewWithDuration:duration];
    }

}

- (UIInterfaceOrientation)orientationFromTransform:(CGAffineTransform)transform {
    // This method comes from [here](http://blog.inferis.org/blog/2015/04/27/ios8-and-interfaceorientation/)
    
    CGFloat angle = atan2f(transform.b, transform.a);
    NSInteger multiplier = (NSInteger)roundf(angle / M_PI_2);
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (multiplier < 0) {
        // clockwise rotation
        while (multiplier++ < 0) {
            switch (orientation) {
                case UIInterfaceOrientationPortrait:
                    orientation = UIInterfaceOrientationLandscapeLeft;
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    orientation = UIInterfaceOrientationPortraitUpsideDown;
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    orientation = UIInterfaceOrientationLandscapeRight;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    orientation = UIInterfaceOrientationPortrait;
                    break;
                default:
                    break;
            }
        }
    } else if (multiplier > 0) {
        // counter-clockwise rotation
        while (multiplier-- > 0) {
            switch (orientation) {
                case UIInterfaceOrientationPortrait:
                    orientation = UIInterfaceOrientationLandscapeRight;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    orientation = UIInterfaceOrientationPortraitUpsideDown;
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    orientation = UIInterfaceOrientationLandscapeLeft;
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    orientation = UIInterfaceOrientationPortrait;
                    break;
                default:
                    break;
            }
        }
    }
    
    return orientation;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (UIInterfaceOrientationIsPortrait([self orientationFromTransform:[coordinator targetTransform]])) {
        [self hideLandscapeViewWithDuration:0.3];
    } else {
        [self showLandscapeViewWithDuration:0.3];
    }
}

- (void)hideLandscapeViewWithDuration:(NSTimeInterval)duration {
    if (_landscapeViewController) {
        [self.searchBar becomeFirstResponder];
        [_landscapeViewController willMoveToParentViewController:nil];
        
        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha = 0;
            _statusBarStyle = UIStatusBarStyleDefault;
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
            [_landscapeViewController.view removeFromSuperview];
            [_landscapeViewController removeFromParentViewController];
            _landscapeViewController = nil;
        }];
    }
}

- (void)showLandscapeViewWithDuration:(NSTimeInterval)duration {
    if (!_landscapeViewController) {
        [_detailViewController dismissFromParentViewController];
        [self.searchBar resignFirstResponder];
        
        _landscapeViewController = [[LandscapeViewController alloc] initWithNibName:@"LandscapeViewController" bundle:nil];
        _landscapeViewController.view.frame = self.view.bounds;
        _landscapeViewController.view.alpha = 0;
//        _landscapeViewController.searchResults = _searchResults;
        _landscapeViewController.search = _search;
        
        [self.view addSubview:_landscapeViewController.view];
        [self addChildViewController:_landscapeViewController];
        
        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha = 1;
            _statusBarStyle = UIStatusBarStyleLightContent;
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
            [_landscapeViewController didMoveToParentViewController:self];
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


#pragma mark - IBAction

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    if (_search) {
        [self performSearch];
    }
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];
    
    _detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    _detailViewController.searchResult = (SearchResult *)_search.searchResults[indexPath.row];
    [_detailViewController presentInParentViewController:self];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([_search.searchResults count] > 0) {
        return indexPath;
    }
    return nil; 
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_search) {
        return 0;
    } else if (_search.isLoading) {
        return 1;
    } else if ([_search.searchResults count] == 0) {
        return 1;
    } else {
        return [_search.searchResults count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_search.isLoading) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];
        
        return cell;
    }
    
    if ([_search.searchResults count] == 0) {
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier];
    } else {
        SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
        SearchResult *searchResult = (SearchResult *)_search.searchResults[indexPath.row];
        [cell configureForSearchResult:searchResult];
        return cell;
    }
}

#pragma mark - SearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self performSearch];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
