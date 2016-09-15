//
//  DetailViewController.m
//  StoreSearch
//
//  Created by FLY.lxm on 11/13/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import "DetailViewController.h"
#import "SearchResult.h"
#import "GradientView.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface DetailViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIView *popupView;
@property (nonatomic, weak) IBOutlet UIImageView *artworkImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *kindLabel;
@property (nonatomic, weak) IBOutlet UILabel *genreLabel;
@property (nonatomic, weak) IBOutlet UIButton *priceButton;

@property (strong, nonatomic) UIPopoverPresentationController *masterPopoverController;

@end

@implementation DetailViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
//        self.view.frame = [UIScreen mainScreen].bounds;
//    }
//    return self;
//}

//- (void)willMoveToParentViewController:(UIViewController *)parent {
//    [super willMoveToParentViewController:parent];
//    if (parent) {
//        [self setLabelsWithSearchResult:self.searchResult];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.artworkImageView.layer.cornerRadius = 5;
    
    UIImage *image = [[UIImage imageNamed:@"PriceButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.priceButton setBackgroundImage:image forState:UIControlStateNormal];
    
    self.view.tintColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:1.0f];
    self.popupView.layer.cornerRadius = 10;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.priceButton.contentEdgeInsets = UIEdgeInsetsMake(2, 5, 2, 5);
    
    [self setLabelsWithSearchResult:self.searchResult];
    [self setAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logic

- (void)presentInParentViewController:(UIViewController *)parentViewController {
    self.view.frame = parentViewController.view.frame;
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
    [self didMoveToParentViewController:parentViewController];
}

- (void)setLabelsWithSearchResult:(SearchResult *)searchResult {
    [self.artworkImageView  setImageWithURL:[NSURL URLWithString:searchResult.artworkURL100] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    self.nameLabel.text = searchResult.name;
    self.artistNameLabel.text = searchResult.artistName;
    self.kindLabel.text = [searchResult kindForDisplay];
    self.genreLabel.text = searchResult.genres[0];
    [self.priceButton setTitle:searchResult.price forState:UIControlStateNormal];
}

- (void)setAnimation {
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.duration = 0.3;
    bounceAnimation.delegate = self;
    
    bounceAnimation.values = @[@0.7, @1.2, @0.9, @1.0];
    bounceAnimation.keyTimes = @[@0.0, @0.284, @0.616, @1.0];
    
    bounceAnimation.timingFunctions = @[
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], 
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], 
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                        ];
    
    [self.popupView.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
    
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = @0;
    fadeAnimation.toValue = @0.5;
    fadeAnimation.duration = 0.1;
    [self.view.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self didMoveToParentViewController:self.parentViewController];
}

- (void)dismissFromParentViewController {
    [self willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:0.3 animations:^{
//        CGRect rect = self.view.bounds;
//        rect.origin.y += rect.size.height;
//        self.view.frame = rect;
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

#pragma mark - IBActions
- (IBAction)close:(id)sender {
    [self dismissFromParentViewController];
}

- (IBAction)openInAppStore:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.searchResult.storeUrl]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return (touch.view == self.view);
}

- (void)dealloc {
    [self.artworkImageView cancelImageRequestOperation];
}

#pragma mark - UISplitViewControllerDelegate

//- (void)

@end
