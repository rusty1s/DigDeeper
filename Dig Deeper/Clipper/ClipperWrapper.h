//
//  ClipperWrapper.h
//  Dig Deeper
//
//  Created by Matthias Fey on 21.03.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Polygon : NSObject

-(instancetype)initWithPoints:(NSArray *)points;

-(NSValue *)objectAtIndex:(int)index;
-(void)addPoint:(CGPoint)point;
-(void)insertPoint:(CGPoint)point atIndex:(int)index;
-(void)removeLastPoint;
-(void)removePointAtIndex:(int)index;

@property(readonly) NSUInteger count;
@property(readonly) BOOL isEmpty;
@property(nonatomic, readonly) NSArray *array;

@end

@interface PolygonSet : NSObject

-(instancetype)initWithPolygon:(Polygon *)polygon;
-(instancetype)initWithObjects:(NSArray *)objects;

-(Polygon *)polygonAtIndex:(int)index;
-(void)addPolygon:(Polygon *)polygon;
-(void)removeLastPolygon;
-(void)removePolygonAtIndex:(int)index;

@property(readonly) NSUInteger count;
@property(readonly) BOOL isEmpty;
@property(nonatomic, readonly) NSArray *array;

-(PolygonSet *)unionWithPolygon:(Polygon *)polygon;
-(PolygonSet *)unionWithPolygonSet:(PolygonSet *)polygonSet;

-(PolygonSet *)intersectWithPolygon:(Polygon *)polygon;
-(PolygonSet *)intersectWithPolygonSet:(PolygonSet *)polygonSet;

-(PolygonSet *)differenceWithPolygon:(Polygon *)polygon;
-(PolygonSet *)differenceWithPolygonSet:(PolygonSet *)polygonSet;

-(PolygonSet *)offset:(CGFloat)offset;
-(PolygonSet *)inset:(CGFloat)inset;

@end
