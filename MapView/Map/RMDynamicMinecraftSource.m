//
//  OpenStreetMapsSource.m
//
// Copyright (c) 2008-2012, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "RMDynamicMinecraftSource.h"

@interface RMDynamicMinecraftSource ()

@property (nonatomic, assign) NSInteger tileSize;
@end

@implementation RMDynamicMinecraftSource

- (id)init
{
	if (!(self = [super init]))
        return nil;

    self.minZoom = 0;
    self.maxZoom = 10;
    _overlays = [@[] mutableCopy];
    
	return self;
} 

- (id)initWithHost:(NSString*)host withMaxZoom:(NSInteger)maxZoom andMinZoom:(NSInteger)minZoom
{
    if (!(self = [super init]))
        return nil;
    
    _tileSize = 0;
    

    self.minZoom = minZoom;
    self.maxZoom = maxZoom;
    
    self.hostURL = host;
    self.overlays = [@[] mutableCopy];
    
    return self;
}

- (id)initWithHost:(NSString *)host andOverlays:(NSMutableArray*)overlays withMaxZoom:(NSInteger)maxZoom andMinZoom:(NSInteger)minZoom
{
    if (!(self = [super init]))
        return nil;
    
    _overlays = overlays;
    _hostURL = [host copy];
    _tileSize = 0;
    
    self.minZoom = maxZoom;
    self.maxZoom = minZoom;
    
    _overlays = [@[] mutableCopy];
    
    
    return self;
}

- (id)initWithHost:(NSString *)host andOverlays:(NSMutableArray*)overlays withMaxZoom:(NSInteger)maxZoom andMinZoom:(NSInteger)minZoom atDefaultZoom:(NSInteger)defaultZoom
{
    if (!(self = [super init]))
        return nil;
    
    _overlays = overlays;
    _hostURL = [host copy];
    _tileSize = 0;
    self.minZoom = maxZoom;
    self.maxZoom = minZoom;

    _overlays = [@[] mutableCopy];
    
    return self;
}

- (id)initWithHost:(NSString *)host andOverlays:(NSMutableArray*)overlays withMaxZoom:(NSInteger)maxZoom andMinZoom:(NSInteger)minZoom atDefaultZoom:(NSInteger)defaultZoom withTileSize:(NSInteger)tileSize
{
    
    if (!(self = [super init]))
        return nil;
    
    _overlays = overlays;
    _hostURL = [host copy];
    
    self.minZoom = maxZoom;
    self.maxZoom = minZoom;
    
    _tileSize = tileSize;
    _overlays = [@[] mutableCopy];
    
    return self;
}

- (NSURL *)URLForTile:(RMTile)tile
{
    NSMutableString*urlToReturn = [[NSMutableString alloc]initWithString:self.hostURL];
    NSLog(@"Enter method %@", urlToReturn);
    
    if (tile.x >= pow(2, tile.zoom) || tile.y >= pow(2, tile.zoom)) {
        [urlToReturn appendFormat:@"/blank"];
    }else if (tile.zoom == 0){
        [urlToReturn appendFormat:@"/base"];
    }else{
        for (int z = tile.zoom - 1; z >= 0 ; --z) {
            int xInside = (int)floor(tile.x / pow(2, z)) % 2;
            int yInside = (int)floor(tile.y / pow(2, z)) % 2;
            [urlToReturn appendFormat:@"/%d", (xInside + 2 * yInside)];
        }
    }
    
    [urlToReturn appendFormat:@".png"];
    urlToReturn = [urlToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return [NSURL URLWithString:urlToReturn];
}

- (NSArray *)URLsForTile:(RMTile)tile
{
    NSMutableArray*urls = [@[] mutableCopy];
    NSURL *tileUrl = [self URLForTile:tile];
    [urls addObject:tileUrl];
    
    for (int i = 0; i < self.overlays.count; i++) {
        
        NSMutableString*urlToReturn = [[NSMutableString alloc]initWithString:[self.overlays objectAtIndex:i]];
        
        if (tile.x >= pow(2, tile.zoom) || tile.y >= pow(2, tile.zoom)) {
            [urlToReturn appendFormat:@"/blank"];
        }else if (tile.zoom == 0){
            [urlToReturn appendFormat:@"/base"];
        }else{
            for (int z = tile.zoom - 1; z >= 0 ; --z) {
                int xInside = (int)floor(tile.x / pow(2, z)) % 2;
                int yInside = (int)floor(tile.y / pow(2, z)) % 2;
                [urlToReturn appendFormat:@"/%d", (xInside + 2 * yInside)];
            }
        }
        
        [urlToReturn appendFormat:@".png"];
        [urls addObject:[NSURL URLWithString:urlToReturn]];
    }
    return urls;
}

- (NSUInteger)tileSideLength
{
    if (_tileSize != 0) {
        return _tileSize;
    }else{
        return kDefaultTileSize;
    }
}


- (NSString *)uniqueTilecacheKey
{
    NSMutableString*cacheName = [NSMutableString stringWithFormat:@"MineCraftMap%@", self.hostURL];
    //Alphabetize, so the same combination of overlays but added in a different order does not cause multiple caches.
    [self.overlays sortUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString*string in self.overlays) {
        [cacheName appendString:string];
    }
    
	return cacheName;
}

- (NSString *)shortName
{
	return @"Minecraft map";
}

- (NSString *)longDescription
{
	return @"Dynamic Minecraft Map";
}

- (NSString *)shortAttribution
{
	return @"© MapCraft";
}

- (NSString *)longAttribution
{
	return @"Map data © MapCraft";
}

@end
