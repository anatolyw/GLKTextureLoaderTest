//
//  RLEmmiterBrush.h
//  GLKTextureLoaderTest
//
//  Created by Anatoly Weinstein on 06/01/16.
//  Copyright © 2016 Anatoly Weinstein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface RLEmmiterBrush : NSObject
- (id)initWithProjectionMatrix:(GLKMatrix4)projectionMatrix;
- (void)renderWithModelViewMatrix:(GLKMatrix4)modelViewMatrix fromPoint:(CGPoint)start toPoint:(CGPoint)end;
@end
