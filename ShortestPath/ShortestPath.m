//
//  ShortestPath.m
//  ShortestPath
//
//  Created by Yoo Rinjae on 12. 11. 8..
//  Copyright (c) 2012년 DearMai. All rights reserved.
//

#import "ShortestPath.h"
#import "Haversine.h"
#import "SignificantPoint.h"
#import "Airport.h"
#import "FlightRoute.h"

#define MAX_WEIGHT 99999999

@implementation ShortestPath {
    NSArray *points, *routes, *airports;
}

- (id)initWithPoints:(NSArray *)aPoints andRoutes:(NSArray *)aRoutes andAirports:(NSArray *)aAirports {
    if([self init]){
        points = aPoints;
        routes = aRoutes;
        airports = aAirports;
    }
    
    return self;
}

- (SignificantPoint *)getNearestPointWithAirport:(Airport *)newAirport {
    double min = 999999999999999;
    int index = -1;
    int i = 0;
    Haversine *haversine;
    
    for(SignificantPoint *point in points){
        haversine = [[Haversine alloc] initWithLat1:newAirport.latitude
                                               lon1:newAirport.longitude
                                               lat2:point.latitude
                                               lon2:point.longitude];
        double rt = [haversine toKilometers];
        if(min > rt) {
            min = rt;
            index = i;
        }
        i++;
    }
    
    return [points objectAtIndex:index];
}

- (int)significantPointIndexWithName:(NSString *)newName {
    for (int i = 0; i < [points count]; i++){
        SignificantPoint *point = [points objectAtIndex:i];
        if([point.name isEqualToString:newName] == YES) {
            return i;
        }
    }
    return -1;
}

- (void)calcShortestPathWithDeparturePoint:(SignificantPoint *)newDeparturePoint
                          andArrivalPoint:(SignificantPoint *)newArrivalPoint {
    NSUInteger countPoint = [points count];
    double matrix[countPoint][countPoint];
    BOOL debug = YES;
    
    if(debug) printf("\n\n------------------------- Make matrix -------------------------\n\n");
    
    for(int i = 0; i < countPoint; i++){
        for(int j = 0; j < countPoint; j++){
            matrix[i][j] = MAX_WEIGHT;
        }
    }
    
    for(int i = 0; i < countPoint; i++) {
        SignificantPoint *thisPoint = [points objectAtIndex:i];
        matrix[i][i] = 0;
        
        if(debug) printf("Check [%6s] point.\n", [thisPoint.name UTF8String]);
        
        for(FlightRoute *route in routes) {
            int j = 0;
            
            for(NSString *pointName in route.pointNameArray) {
                int pointIndex = [self significantPointIndexWithName:pointName];
                
//                if(DEBUG && [route.name isEqualToString:@"Y64"]){
//                    printf(" %s(%d) ", [pointName UTF8String], pointIndex);
//                }
                
                j++;
                if(pointIndex == i && j != [route.pointNameArray count]) {
                    NSString *strNextPoint = [route.pointNameArray objectAtIndex:j];
                    if(debug) printf("\t%s-%s", [route.name UTF8String], [strNextPoint UTF8String]);
                    
                    int nextPointIndex = [self significantPointIndexWithName:strNextPoint];
                    SignificantPoint *nextPoint = [points objectAtIndex:nextPointIndex];
                    Haversine *haversign = [[Haversine alloc] initWithLat1:thisPoint.latitude
                                                                      lon1:thisPoint.longitude
                                                                      lat2:nextPoint.latitude
                                                                      lon2:nextPoint.longitude];
                    double weight = [haversign toKilometers];
                    
                    matrix[i][nextPointIndex] = weight;
                }
            }
            
            //printf("\n");
            
            // 뒤로도 가능하기 때문에 왕복
            //j = (int)[route.pointNameArray count];
            for(int k = (int)[route.pointNameArray count] - 1; k >= 0; k--) {
                NSString *pointName = [route.pointNameArray objectAtIndex:k];
                int pointIndex = [self significantPointIndexWithName:pointName];
                
                if(pointIndex == i && k != 0) {
                    NSString *strNextPoint = [route.pointNameArray objectAtIndex:k - 1];
                    int nextPointIndex = [self significantPointIndexWithName:strNextPoint];
                    SignificantPoint *nextPoint = [points objectAtIndex:nextPointIndex];
                    Haversine *haversign = [[Haversine alloc] initWithLat1:thisPoint.latitude
                                                                      lon1:thisPoint.longitude
                                                                      lat2:nextPoint.latitude
                                                                      lon2:nextPoint.longitude];
                    double weight = [haversign toKilometers];
                    
                    matrix[i][nextPointIndex] = weight;
                }
            }
        }
        
        if(debug) printf("\n");
    }
    
    printf("   ");
    for(int i = 0; i < countPoint; i++){
        printf("%2d", i % 100);
    }
    printf("\n");
    for(int i = 0; i < countPoint; i++){
        printf("%3d", i);
        for(int j = 0; j < countPoint; j++){
            if(matrix[i][j] == 0.0) printf(" 0");
            else if(matrix[i][j] == MAX_WEIGHT) printf("  ");
            else if(matrix[i][j] > 0.0) printf(" 1");
            else printf("  ");
        }
        printf("\n");
    }
    
    double distance[countPoint];
    BOOL visited[countPoint];
    int path[countPoint];
    const NSUInteger departureIndex = [self significantPointIndexWithName:newDeparturePoint.name];
    const NSUInteger arrivalIndex = [self significantPointIndexWithName:newArrivalPoint.name];
    
    for(int i = 0; i < countPoint; i++){
        distance[i] = matrix[departureIndex][i];
        visited[i] = NO;
        
        if(distance[i] > 0 && distance[i] < MAX_WEIGHT) {
            path[i] = (int)departureIndex;
        } else {
            path[i] = -1;
        }
    }
    
    distance[departureIndex] = 0;
    visited[departureIndex] = true;
    
    for(int i = 0; i < countPoint; i++) {
        double min = INT_MAX;
        NSUInteger minIndex = -1;
        
        for(int j = 0; j < countPoint; j++){
            if(visited[j] == YES) continue;
            if(distance[j] >= min) continue;
            
            min = distance[j];
            minIndex = j;
        }
        
        visited[minIndex] = true;
        
        for(int j = 0; j < countPoint; j++){
            if(visited[j] == YES) continue;
            if(distance[minIndex] + matrix[minIndex][j] >= distance[j]) continue;
            
            distance[j] = distance[minIndex] + matrix[minIndex][j];
            path[j] = (int)minIndex;
        }
    }
    
    NSLog(@"거리 : %fKm\n", distance[arrivalIndex]);
    
    for (int i = 0; i < countPoint; i++){
        int cv = i;
        SignificantPoint *point = [points objectAtIndex:cv];
        printf("To %s : %s", [point.name UTF8String], [point.name UTF8String]);
        
        while(path[cv] >= 0){
            SignificantPoint *point1 = [points objectAtIndex:path[cv]];
            printf("<-[%s]", [point1.name UTF8String]);
            cv = path[cv];
        }
        
        printf("\n");
    }
}

- (void)main:(Airport *)newDepartureAirport andArrivalAirport:(Airport *)newArrivalAirport {
    SignificantPoint *depaturePoint = [self getNearestPointWithAirport:newDepartureAirport];
    SignificantPoint *arrivalPoint = [self getNearestPointWithAirport:newArrivalAirport];
    
    NSLog(@"%@, %f, %f", depaturePoint.name, depaturePoint.latitude, depaturePoint.longitude);
    NSLog(@"%@, %f, %f", arrivalPoint.name, arrivalPoint.latitude, arrivalPoint.longitude);
    
    [self calcShortestPathWithDeparturePoint:depaturePoint andArrivalPoint:arrivalPoint];
}

@end
