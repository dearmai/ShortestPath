//
//  DataBuilder.m
//  ShortestPath
//
//  Created by Yoo Rinjae on 12. 11. 8..
//  Copyright (c) 2012년 DearMai. All rights reserved.
//

#import "DataBuilder.h"
#import "SignificantPoint.h"
#import "FlightRoute.h"
#import "Airport.h"

@implementation DataBuilder {
    NSString *_dataPath;
}

- (id)initWithDataPath:(NSString *)dataPath {
    if([self init]) {
        _dataPath = dataPath;
    }
    return self;
}

- (double)geoStringToDouble:(char *)str {
    double hour, minute, second;
    char buf[10] = "\0", c;
    int flagField = 0, indexBuf = 0;
    
    for(int i = 0; i < strlen(str); i++){
        c = str[i];
        buf[indexBuf++] = c;
        
        if(c == '.') {
            if(flagField == 0) {
                hour = atof(buf);
                flagField++;
            }
            else minute = atof(buf);
            
            indexBuf = 0;
            memset(buf, '\0', sizeof(buf));
        }
    }
    
    second = atof(buf);
    
    minute = minute / 60.0;
    second = second / (60.0 * 60.0);
    
    //printf("%s - %f - %f - %f\n", str, hour, minute, second);
    
    return hour + minute + second;
}

- (NSArray *)buildSignificantPoint {
    SignificantPoint *point;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FILE *file;
    char *path = (char *)[[NSString stringWithFormat:@"%@/%@", _dataPath, @"point.txt"] UTF8String];
    char c;
    char buf[500] = "\0";
    int bufIndex = 0;
    int flagField = 0;
    
    if((file = fopen(path, "r")) == nil) {
        printf("SignificentPoint file read error.");
        exit(1);
    }
    
    while (1) {
        c = fgetc(file);
        buf[bufIndex++] = c;
        
        if(point == nil) point = [[SignificantPoint alloc] init];
        
        if(c == '\t' || c == ' ' || c == '\n' || c == EOF) {
            buf[bufIndex - 1] = '\0';
            
            flagField++;
            switch(flagField) {
                case 1:
                    point.name = [NSString stringWithUTF8String:buf];
                    break;
                case 2:
                    point.latitude = [self geoStringToDouble:buf];
                    break;
                case 3:
                    point.longitude = [self geoStringToDouble:buf];
                    flagField = 0;
                    [array addObject:point];
                    point = nil;
                    break;
            }
            
            bufIndex = 0;
            memset(buf, '\0', sizeof(buf));
            if(c == EOF) break;
        }
    }
    
    fclose(file);
    
    return array;
}

- (NSArray *)buildAirport {
    Airport *airport;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FILE *file;
    char *path = (char *)[[NSString stringWithFormat:@"%@/%@", _dataPath, @"airport.txt"] UTF8String];
    char c;
    char buf[500] = "\0";
    int bufIndex = 0;
    int flagField = 0;
    
    if((file = fopen(path, "r")) == nil) {
        printf("Airport file read error.");
        exit(1);
    }
    
    while (1) {
        c = fgetc(file);
        buf[bufIndex++] = c;
        
        if(airport == nil) airport = [[Airport alloc] init];
        
        if(c == '\t' || c == ' ' || c == '\n' || c == EOF) {
            buf[bufIndex - 1] = '\0';
            
            flagField++;
            switch(flagField) {
                case 1:
                    airport.name = [NSString stringWithUTF8String:buf];
                    break;
                case 2:
                    airport.nameEn = [NSString stringWithUTF8String:buf];
                    break;
                case 3:
                    airport.icao = [NSString stringWithUTF8String:buf];
                    break;
                case 4:
                    airport.latitude = [self geoStringToDouble:buf];
                    break;
                case 5:
                    airport.longitude = [self geoStringToDouble:buf];
                    flagField = 0;
                    [array addObject:airport];
                    airport = nil;
                    break;
            }
            
            bufIndex = 0;
            memset(buf, '\0', sizeof(buf));
            if(c == EOF) break;
        }
    }
    
    fclose(file);
    
    return array;
}

- (NSArray *)buildFlightRoute {
    FlightRoute *route;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *arrayPoint;
    FILE *file;
    char *path = (char *)[[NSString stringWithFormat:@"%@/%@", _dataPath, @"route.txt"] UTF8String];
    char c;
    char buf[500] = "\0";
    int bufIndex = 0;
    
    if((file = fopen(path, "r")) == nil) {
        printf("Fight route file read error.");
        exit(1);
    }
    
    while (1) {
        c = fgetc(file);
        buf[bufIndex++] = c;
        
        if(route == nil) route = [[FlightRoute alloc] init];
        
        if(c == '=') {
            buf[bufIndex - 1] = '\0';
            route.name = [NSString stringWithUTF8String:buf];
            bufIndex = 0;
            memset(buf, '\0', sizeof(buf));
            
            // NSLog(@"%@", route.name);
            
            arrayPoint = [[NSMutableArray alloc] init];
            
            while (1) {
                c = fgetc(file);
                buf[bufIndex++] = c;
                
                if(c == ',' || c == '\n' || c == EOF){
                    buf[bufIndex - 1] = '\0';
                    
                    NSString *pointName = [NSString stringWithUTF8String:buf];
                    [arrayPoint addObject:pointName];
                    
                    bufIndex = 0;
                    memset(buf, '\0', sizeof(buf));
                    if(c == '\n' || c == EOF) {
                        route.pointNameArray = arrayPoint;
                        arrayPoint = nil;
                        //ungetc(c, file);
                        break;
                    }
                }
            }
        }
        
        if(c == '\n' || c == EOF) {
            //NSLog(@"%@", route.name);
            if(route.name == nil) break;
            [array addObject:route];
            route = nil;
            bufIndex = 0;
            memset(buf, '\0', sizeof(buf));
            if(c == EOF) break;
        }
    }
    
    fclose(file);
    
    return array;
}

@end
