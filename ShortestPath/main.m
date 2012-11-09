//
//  main.m
//  ShortestPath
//
//  Created by Yoo Rinjae on 12. 11. 4..
//  Copyright (c) 2012년 DearMai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataBuilder.h"
#import "SignificantPoint.h"
#import "FlightRoute.h"
#import "Airport.h"
#import "ShortestPath.h"

void debugMessage(NSArray *pointArray, NSArray *routeArray, NSArray *airportArray) {
    int i = 0;
    for(SignificantPoint *point in pointArray) {
        printf("%s - %f, %f\n", [point.name UTF8String], point.latitude, point.longitude);
    }
    
    for(FlightRoute *route in routeArray){
        printf("%s - ", [route.name UTF8String]);
        for(NSString *pointName in route.pointNameArray){
            printf("%s > ", [pointName UTF8String]);
        }
        printf("\n");
    }
    
    printf("\n\n-------------------------------------------\n\n");
    
    i = 0;
    for(Airport *airport in airportArray) {
        printf("%d - %s(%s, %s) - %f, %f\n",
               i++,
               [airport.name UTF8String], [airport.nameEn UTF8String], [airport.icao UTF8String],
               airport.latitude, airport.longitude);
    }
    
    printf("\n\n-------------------------------------------\n\n");
    for(FlightRoute *route in routeArray){
        for(NSString *pointName in route.pointNameArray){
            BOOL isFind = NO;
            
            for(SignificantPoint *point in pointArray) {
                if([pointName isEqualToString:point.name]) {
                    isFind = YES;
                    break;
                }
            }
            
            if(isFind == NO) {
                printf("%10s/%10s - Do not finded.\n", [route.name UTF8String], [pointName UTF8String]);
            }
        }
    }
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        system("pwd");
        
        NSString *dataPath = @"/Users/dearmai/Documents/Workspace/c/Shortest";
        
        DataBuilder *dataBuilder = [[DataBuilder alloc] initWithDataPath:dataPath];
        NSArray *pointArray = [dataBuilder buildSignificantPoint];
        NSArray *routeArray = [dataBuilder buildFlightRoute];
        NSArray *airportArray = [dataBuilder buildAirport];
        
        Airport *departureAirport = [airportArray objectAtIndex:0];
        Airport *arrivalAirport = [airportArray objectAtIndex:18];
        
        debugMessage(pointArray, routeArray, airportArray);
        
        ShortestPath *instance = [[ShortestPath alloc] initWithPoints:pointArray
                                                        andRoutes:routeArray
                                                        andAirports:airportArray];
        [instance main:departureAirport andArrivalAirport:arrivalAirport];
    }
    return 0;
}