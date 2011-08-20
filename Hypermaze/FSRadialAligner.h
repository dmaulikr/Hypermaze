//
//  FSRadialAligner.h
//  Hypermaze
//
//  Created by Jakub Gruszecki on 19.08.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTreeNode.h"

@interface FSRadialAligner : NSObject {
	double angle;
	double radius;
	double margin;
	NSMutableArray* root;
}

- (CGPoint) alignElementOnIndex: (NSIndexPath*) index;
- (CGPoint) alignElementOnIndex: (NSIndexPath*) index radiusDelta: (double) rad marginDelta: (double) marg;

@end
