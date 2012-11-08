//
//  DataBuilder.h
//  ShortestPath
//
//  Created by Yoo Rinjae on 12. 11. 8..
//  Copyright (c) 2012년 DearMai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBuilder : NSObject

- (id)initWithDataPath:(NSString *)dataPath;
- (NSArray *)buildSignificantPoint;
- (NSArray *)buildFlightRoute;
- (NSArray *)buildAirport;

@end
