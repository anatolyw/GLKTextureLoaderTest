//
//  RLGLKView.h
//  GLKTextureLoaderTest
//
//  Created by Anatoly Weinstein on 06/01/16.
//  Copyright © 2016 Anatoly Weinstein. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class RLToolSettings;

@interface RetainedEAGLLayer : CAEAGLLayer
@end

@interface RLRetainedGLKView : GLKView <GLKViewDelegate>

- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end;
- (void)clear;
- (void)updateBrush;

@end
