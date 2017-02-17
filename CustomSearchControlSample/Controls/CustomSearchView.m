//
//  CustomSearchView.m
//  CustomSearchControlSample
//
//  Created by Mehtab on 16/02/2017.
//  Copyright © 2017 Mehtab. All rights reserved.
//

#import "CustomSearchView.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


const int INTIAL_SLIDER_VIEW_TOP_SPACING = 10;
const int SLIDER_VIEW_SPACING = 15;

#define BUTTON_TITLE_SLIDE_UP   @"Slide Up"
#define BUTTON_TITLE_SLIDE_DOWN @"Slide Down"

static int originalYPos = 0;
static int partialExpandedYPos = 0;


enum SLIDER_POSITION {

    HIDDEN = 0,
    PARTIAL_EXPANDED,
    EXPANDED
    
};


@interface CustomSearchView () {

    enum SLIDER_POSITION _sliderPosition;
}

//Outlets

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UIButton *slideButton;

//Constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopSpaceSliderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTrailingSliderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLeadingSliderView;

//Gesture
-(IBAction)handlePanGesture:(UIPanGestureRecognizer*)sender;

@end


@implementation CustomSearchView



- (id)initViewWithFrame:(CGRect)frame
{
    //self = [super initWithFrame:frame];

    UINib *nibs    = [UINib nibWithNibName:@"CustomSearchView" bundle:nil];
    NSArray *array = [nibs instantiateWithOwner:nil options:nil];
    if(array.count == 0){
        NSLog(@"Failed to open CustomSearchView xib.");
        return nil;
    }
    
    self = [array objectAtIndex:0];
    self.frame = frame;
    
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];

    
    [_slideButton setTitle:BUTTON_TITLE_SLIDE_DOWN forState:UIControlStateNormal];
    [_sliderView setUserInteractionEnabled:YES];
    [_sliderView addGestureRecognizer:panGesture];
    _sliderPosition = EXPANDED;
}

- (void) setSliderContentView: (UIView*) view {

    if(!view)
        return;
    
    [_sliderView addSubview:view];

}


#pragma mark - Sliding Methods
//
- (void) hideSlider {
    
    int sliderViewHeight = _sliderView.frame.size.height;

    _constraintTopSpaceSliderView.constant
    =  sliderViewHeight +  _constraintTopSpaceSliderView.constant;

    [UIView animateWithDuration:1.0
                     animations:^{
                         
                         [self layoutIfNeeded];
                         
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Slider Hidden!");
                         [_slideButton setTitle:BUTTON_TITLE_SLIDE_UP forState:UIControlStateNormal];
                         
                     }];
    
    _sliderPosition = HIDDEN;
}

- (void) slideDown {
    
    if(_sliderPosition == PARTIAL_EXPANDED || _sliderPosition == HIDDEN)
        return;
    
    CGRect mainVieframe = self.frame;
    
    [UIView animateWithDuration:1.0
                     animations:^{
                        
                         _constraintTopSpaceSliderView.constant
                         = mainVieframe.size.height - (mainVieframe.size.height * 0.5) ;
                         
                         _constraintLeadingSliderView.constant = SLIDER_VIEW_SPACING;
                         _constraintTrailingSliderView.constant = SLIDER_VIEW_SPACING;
                         [self layoutIfNeeded];

                     }
                     completion:^(BOOL finished){
                         NSLog(@"Slide Down!");
                         [_slideButton setTitle:BUTTON_TITLE_SLIDE_UP forState:UIControlStateNormal];
                     }];

    _sliderPosition = PARTIAL_EXPANDED;

}

- (void) slideUp {

    [UIView animateWithDuration:1.0
                     animations:^{
                         _constraintLeadingSliderView.constant = 0;
                         _constraintTrailingSliderView.constant = 0;
                         _constraintTopSpaceSliderView.constant = INTIAL_SLIDER_VIEW_TOP_SPACING ;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Slide Up!");
                         [_slideButton setTitle:BUTTON_TITLE_SLIDE_DOWN forState:UIControlStateNormal];

                     }];
    _sliderPosition = EXPANDED;

}


#pragma mark - UI Action

- (IBAction)onSlidePressed:(id)sender {
    
    if(_sliderPosition == PARTIAL_EXPANDED) {
        [self slideUp];
    } else if (_sliderPosition == EXPANDED) {
        [self slideDown];
    }

}

#pragma mark - Gesture Recognizer Method

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    //NSLog(@"handlePan");
    
    CGPoint translation = [recognizer translationInView:self];

    NSLog(@"Translation: %f",translation.y);
    
    float yPos = recognizer.view.center.y;
    NSLog(@"Center Y: %f", recognizer.view.center.y);

    
    if(originalYPos == 0)
        originalYPos = yPos;
    
    
    float slideDownLimit = originalYPos + 50;
    
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        
        //hide slider if slide down in PARTIAL_EXPANDED mode
        if((partialExpandedYPos != 0  && translation.y > 0 && _sliderPosition ==  PARTIAL_EXPANDED)) {
            [self hideSlider];
            return;
        }
        
        //Slide up if slide to upward position in PARTIAL_EXPANDED mode
        if((partialExpandedYPos != 0 && translation.y < 0 && _sliderPosition ==  PARTIAL_EXPANDED)) {
            [self slideUp];
            return;
        }
    }

    //Bring back slider to fully expanded postion if less than slideDownLimit
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        
        if(yPos < slideDownLimit && _sliderPosition ==  EXPANDED) {
            [self translateView:recognizer point:CGPointMake(recognizer.view.center.x , originalYPos)];
            return;
        }
    }
    
    
    // Bring back slider to fully expanded postion if slide to up when fully expanded
    if(translation.y <=0 && _sliderPosition ==  EXPANDED) {
        [self translateView:recognizer point:CGPointMake(recognizer.view.center.x , originalYPos)];
        return;
    }
    
    
    // Slide to the partial expanded position
  
    if(yPos >= slideDownLimit && _sliderPosition == EXPANDED) {
       [self slideDown];
        partialExpandedYPos = yPos;
        NSLog(@"Partial Expanded yPOS: %d", partialExpandedYPos);
        return;
    }
    
    [self translateView:recognizer point:CGPointMake(recognizer.view.center.x ,
                                                     recognizer.view.center.y + translation.y)];
    
}

- (void) translateView:(UIPanGestureRecognizer *)recognizer point:(CGPoint) point {
    recognizer.view.center = point;
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];

}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    return CGRectContainsPoint(_sliderView.frame,point)  || CGRectContainsPoint(_searchView.frame,point);
}




@end
