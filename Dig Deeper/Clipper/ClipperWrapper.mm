//
//  ClipperWrapper.m
//  Dig Deeper
//
//  Created by Matthias Fey on 21.03.15.
//  Copyright (c) 2015 Rusty1s. All rights reserved.
//

#import "ClipperWrapper.h"

#include "clipper.hpp"

#define kClipperScale 1000000.0f

@implementation Polygon
{
    @public
    ClipperLib::Path _path;
}

-(instancetype)initWithPoints:(NSArray *)points
{
    ClipperLib::IntPoint(0, 0);
    
    if (self = [super init]) {
        for (NSValue *value : points) { [self addPoint:value.CGPointValue]; }
    }
    return self;
}

-(NSValue *)objectAtIndex:(int)index
{
    if (index >= 0 && index < self.count) {
        CGPoint point = CGPointMake(_path[index].X/kClipperScale, _path[index].Y/kClipperScale);
        return [NSValue valueWithCGPoint:point];
    }
    else { return nil; }
}

-(void)addPoint:(CGPoint)point
{
    _path.push_back(ClipperLib::IntPoint(kClipperScale*point.x, kClipperScale*point.y));
}

-(void)insertPoint:(CGPoint)point atIndex:(int)index
{
    ClipperLib::Path::iterator it = _path.begin() + index;
    _path.insert(it, ClipperLib::IntPoint(point.x, point.y));
}

-(void)removeLastPoint {
    _path.pop_back();
}

-(void)removePointAtIndex:(int)index {
    _path.erase(_path.begin()+index);
}

-(NSUInteger)count { return _path.size(); }

-(BOOL)isEmpty { return self.count == 0; }

-(NSArray *)array {
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:self.count];
    
    for (int i = 0; i < _path.size(); i++) {
        [points addObject:[self objectAtIndex:i]];
    }
    
    return points;
}

@end

@implementation PolygonSet
{
    @public
    ClipperLib::Paths _paths;
}

-(instancetype)initWithPolygon:(Polygon *)polygon
{
    return [self initWithObjects:@[polygon]];
}

-(instancetype)initWithObjects:(NSArray *)objects
{
    if (self = [super init]) {
        for (Polygon *polygon : objects) { [self addPolygon:polygon]; }
    }
    return self;
}

-(Polygon *)polygonAtIndex:(int)index
{
    if (index >= 0 && index < self.count) {
        Polygon *polygon = [[Polygon alloc] init];
        polygon->_path = _paths[index];
        return polygon;
    }
    else { return nil; }
}

-(void)addPolygon:(Polygon *)polygon;
{
    _paths.push_back(polygon->_path);
}

-(void)removeLastPolygon {
    _paths.pop_back();
}

-(void)removePolygonAtIndex:(int)index {
    _paths.erase(_paths.begin()+index);
}

-(NSUInteger)count { return _paths.size(); }

-(BOOL)isEmpty { return self.count == 0; }

-(NSArray *)array {
    NSMutableArray *polygons = [NSMutableArray arrayWithCapacity:self.count];
    
    for (int i = 0; i < _paths.size(); i++) {
        [polygons addObject:[self polygonAtIndex:i]];
    }
    
    return polygons;
}

-(PolygonSet *)unionWithPolygon:(Polygon *)polygon
{
    return [self unionWithPolygonSet:[[PolygonSet alloc] initWithPolygon:polygon]];
}

-(PolygonSet *)unionWithPolygonSet:(PolygonSet *)polygonSet
{
    return [self executeWithPolygonSet:polygonSet andClipType:ClipperLib::ClipType::ctUnion];
}

-(PolygonSet *)intersectWithPolygon:(Polygon *)polygon
{
    return [self intersectWithPolygonSet:[[PolygonSet alloc] initWithPolygon:polygon]];
}

-(PolygonSet *)intersectWithPolygonSet:(PolygonSet *)polygonSet
{
    return [self executeWithPolygonSet:polygonSet andClipType:ClipperLib::ClipType::ctIntersection];
}

-(PolygonSet *)differenceWithPolygon:(Polygon *)polygon
{
    return [self differenceWithPolygonSet:[[PolygonSet alloc] initWithPolygon:polygon]];
}

-(PolygonSet *)differenceWithPolygonSet:(PolygonSet *)polygonSet
{
    return [self executeWithPolygonSet:polygonSet andClipType:ClipperLib::ClipType::ctDifference];
}

-(PolygonSet *)offset:(CGFloat)offset
{
    ClipperLib::ClipperOffset _clipperOffset;
    _clipperOffset.AddPaths(_paths, ClipperLib::JoinType::jtSquare, ClipperLib::EndType::etClosedPolygon);
    
    PolygonSet *newPolygonSet = [[PolygonSet alloc] init];
    _clipperOffset.Execute(newPolygonSet->_paths, kClipperScale*offset);
    return newPolygonSet;
}

-(PolygonSet *)inset:(CGFloat)inset
{
    return [self offset:-inset];
}

// MARK: Helper

-(PolygonSet *)executeWithPolygonSet:(PolygonSet *)polygonSet andClipType:(ClipperLib::ClipType)clipType {
    ClipperLib::Clipper _clipper;
    _clipper.StrictlySimple();
    
    _clipper.AddPaths(_paths, ClipperLib::PolyType::ptSubject, YES);
    _clipper.AddPaths(polygonSet->_paths, ClipperLib::PolyType::ptClip, YES);
    
    PolygonSet *newPolygonSet = [[PolygonSet alloc] init];
    _clipper.Execute(clipType, newPolygonSet->_paths);
    
    return newPolygonSet;
}

@end
