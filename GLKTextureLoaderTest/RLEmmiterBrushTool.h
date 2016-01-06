//
//  RLEmmiterBrushTool.h
//  GLKTextureLoaderTest
//
//  Created by Anatoly Weinstein on 06/01/16.
//  Copyright © 2016 Anatoly Weinstein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef enum {
    RLTouchTypeCurrent  = 0,
    RLTouchTypePrevious = 1,
} RLTouchType;

@class RLRetainedGLKView;

@interface RLEmmiterBrushTool : NSObject

@property (weak)   RLRetainedGLKView* drawingView;
@property (assign) BOOL isFirstRendered;

- (void)touchBegan:(UITouch *)touch;
- (void)touchMoved:(UITouch *)touch;
- (void)touchEnded:(UITouch *)touch;

@end
