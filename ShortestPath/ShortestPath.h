//
//  ShortestPath.h
//  ShortestPath
//
//  Created by Yoo Rinjae on 12. 11. 8..
//  Copyright (c) 2012년 DearMai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Airport;

@interface ShortestPath : NSObject

- (id)initWithPoints:(NSArray *)aPoints andRoutes:(NSArray *)aRoutes andAirports:(NSArray *)aAirports;
- (void)main:(Airport *)newDepartureAirport andArrivalAirport:(Airport *)newArrivalAirport;
@end
