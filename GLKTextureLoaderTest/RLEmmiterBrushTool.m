//
//  RLEmmiterBrushTool.m
//  GLKTextureLoaderTest
//
//  Created by Anatoly Weinstein on 06/01/16.
//  Copyright © 2016 Anatoly Weinstein. All rights reserved.
//

#import "RLEmmiterBrushTool.h"

#import "RLToolSettings.h"
#import "RLGLKView.h"

@interface RLEmmiterBrushTool()
@property (assign) CGPoint firstPoint;
@property (assign) CGPoint lastPoint;
@end

@implementation RLEmmiterBrushTool {
    BOOL _renderAll;
}

- (id)init {
    
    if ((self = [super init])) {
        _isFirstRendered = NO;
        _renderAll = NO;
    }
    
    return self;
}

- (CGPoint)pointFromTouch:(UITouch*)touch type:(RLTouchType)type {
    
    CGPoint touchLocation = (RLTouchTypeCurrent == type) ?
    [touch locationInView:self.drawingView] :
    [touch previousLocationInView:self.drawingView];

    CGFloat touchLocationY = (self.drawingView.frame.size.height - touchLocation.y);
    
    return CGPointMake(touchLocation.x * self.drawingView.contentScaleFactor,
                       touchLocationY * self.drawingView.contentScaleFactor);
}

- (void)touchBegan:(UITouch *)touch {
    
    self.firstPoint = [self pointFromTouch:touch type:RLTouchTypeCurrent];
}

- (void)touchMoved:(UITouch *)touch {

    self.firstPoint = [self pointFromTouch:touch type:RLTouchTypePrevious];
    self.lastPoint  = [self pointFromTouch:touch type:RLTouchTypeCurrent];
    
    if (_renderAll || !_isFirstRendered) {
        [self.drawingView renderLineFromPoint:self.firstPoint toPoint:self.lastPoint];
        _isFirstRendered = YES;
    }
}

- (void)touchEnded:(UITouch *)touch {

    self.firstPoint = [self pointFromTouch:touch type:RLTouchTypePrevious];
    self.lastPoint  = [self pointFromTouch:touch type:RLTouchTypeCurrent];
    
    if (_renderAll || !_isFirstRendered) {
        [self.drawingView renderLineFromPoint:self.firstPoint toPoint:self.lastPoint];
        _isFirstRendered = YES;
    }
}

@end
