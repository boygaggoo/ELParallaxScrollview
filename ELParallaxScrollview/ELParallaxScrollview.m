//
//  ELParallaxScrollview.m
//  ELParallaxScrollviewDemo
//
//  Created by Eric Lui on 2013-08-10.
//  Copyright (c) 2013 Eric Lui. All rights reserved.
//

#import "ELParallaxScrollview.h"

@interface ParallaxView : NSObject

@property (nonatomic, strong) UIView * view;
@property (nonatomic, assign) CGFloat animationStartPoint;
@property (nonatomic, assign) CGFloat animationEndPoint;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, readonly) CGPoint translationSpeed;
@property (nonatomic, assign) bool isVertical;

-(id)initWithView:(UIView *)view andEndPoint:(CGPoint)endPoint
                        andAnimationStartPoint:(CGFloat)animationStartPoint
                          andAnimationEndPoint:(CGFloat)animationEndPoint
                                  andDirection:(bool)isVertical;

@end

@implementation ParallaxView

-(id)initWithView:(UIView *)view andEndPoint:(CGPoint)endPoint
                      andAnimationStartPoint:(CGFloat)animationStartPoint
                        andAnimationEndPoint:(CGFloat)animationEndPoint
                                andDirection:(bool)isVertical {
    self = [super init];
    
    if (self) {
        _view = view;
        
        _animationStartPoint = animationStartPoint;
        _animationEndPoint = animationEndPoint;
        
        _startPoint = view.frame.origin;
        _endPoint = endPoint;
        
        _isVertical = isVertical;
        
        [self updateTranslationSpeed];
    }
    
    return self;
}

-(void)updateTranslationSpeed {
    CGPoint distanceToTravel = CGPointMake(_endPoint.x - _startPoint.x, _endPoint.y - _startPoint.y);
    CGFloat timeForTravel = _animationEndPoint - _animationStartPoint;
    
    _translationSpeed = CGPointMake(distanceToTravel.x/timeForTravel, distanceToTravel.y/timeForTravel);
    
    if (isnan(_translationSpeed.x)) {_translationSpeed.x = 0;}
    if (isnan(_translationSpeed.y)) {_translationSpeed.y = 0;}
}

@end

@interface ELParallaxScrollview ()

@property (nonatomic, strong) UIScrollView * mainScrollview;
@property (nonatomic, strong) NSMutableArray * parallaxViewsArray;

@end

@implementation ELParallaxScrollview

-(id)initWithFrame:(CGRect)frame andIsVertical:(bool)isVertical {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _parallaxViewsArray = [NSMutableArray array];
        
        _mainScrollview = [[UIScrollView alloc] initWithFrame:frame];
        [_mainScrollview setDelegate:self];
        
        _isVertical = isVertical;
        
        [super addSubview:_mainScrollview];
    }
    return self;
}

-(void)setContentSize:(CGSize)size {
    [_mainScrollview setContentSize:size];
}

-(void)addSubview:(UIView *)view {
    [_mainScrollview addSubview:view];
}

-(void)addSubview:(UIView *)view withEndPoint:(CGPoint)endPoint {
    [self addSubview:view withEndPoint:endPoint
                     andAnimationStart:(_isVertical ? view.frame.origin.y : view.frame.origin.x)
                       andAnimationEnd:(_isVertical ? endPoint.y : endPoint.x)];
}

-(void)addSubview:(UIView *)view withEndPoint:(CGPoint)endPoint
                       andAnimationStart:(CGFloat)animationStartPoint
                         andAnimationEnd:(CGFloat)animationEndPoint {
    ParallaxView *pView = [[ParallaxView alloc] initWithView:view
                                                 andEndPoint:endPoint
                                      andAnimationStartPoint:animationStartPoint
                                        andAnimationEndPoint:animationEndPoint
                                                andDirection:_isVertical];
    [_parallaxViewsArray addObject:pView];
    [_mainScrollview addSubview:pView.view];
}

#pragma mark - UIScrollviewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffset = (_isVertical ? scrollView.contentOffset.y : scrollView.contentOffset.x);
    
    for (ParallaxView * pView in _parallaxViewsArray) {
        if (pView.animationStartPoint <= contentOffset && pView.animationEndPoint >= contentOffset) {
            CGRect frame = pView.view.frame;
            frame.origin.y = ((contentOffset - pView.animationStartPoint) * pView.translationSpeed.y) + pView.startPoint.y;
            frame.origin.x = ((contentOffset - pView.animationStartPoint) * pView.translationSpeed.x) + pView.startPoint.x;
            [pView.view setFrame:frame];
        } else if (pView.animationStartPoint >= contentOffset) {
            CGRect frame = pView.view.frame;
            frame.origin = pView.startPoint;
            [pView.view setFrame:frame];
        } else {
            CGRect frame = pView.view.frame;
            frame.origin = pView.endPoint;
            [pView.view setFrame:frame];
        }
    }
}

@end
