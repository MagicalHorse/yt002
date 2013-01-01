//
//  FSResource.m
//  FashionShop
//
//  Created by gong yi on 11/27/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSResource.h"

@implementation FSResource

@synthesize domain;
@synthesize relativePath;
@synthesize height;
@synthesize width;
@synthesize type;
@synthesize order;



+ (RKObjectMapping *)getRelationDataMap
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    [relationMap mapKeyPathsToAttributes:@"domain",@"domain",@"name",@"relativePath",@"height",@"height",@"width",@"width",@"order",@"order",@"type",@"type",nil];
    return relationMap;
}


-(NSURL *)absoluteUrl
{
    return self.absoluteUrl120;
}
-(NSURL *)absoluteUrlOrigin
{
    if (relativePath && domain)
    {
        NSString *relative = [NSString stringWithFormat:@"%@_original.jpg",relativePath];
        
        return [NSURL URLWithString:relative relativeToURL:[NSURL URLWithString:self.domain]];
    }
    else
        return nil;

}

-(NSURL *)absoluteUrl120
{
    if (relativePath && domain)
    {
        NSString *relative = [self composeRelativeFromWidth:120];
    
        return [NSURL URLWithString:relative relativeToURL:[NSURL URLWithString:self.domain]];
    }
    else
        return nil;
}
-(NSURL *)absoluteUrl320
{
    if (relativePath && domain)
    {
        NSString *relative = [self composeRelativeFromWidth:320];
        
        return [NSURL URLWithString:relative relativeToURL:[NSURL URLWithString:self.domain]];
    }
    else
        return nil;
}

-(NSString *) composeRelativeFromWidth:(int)inWid
{
    return  [NSString stringWithFormat:@"%@_%dx0.jpg",self.relativePath,inWid];
   }

@end
