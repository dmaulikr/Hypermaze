//
//  HPPositionMask.h
//  Hypermaze
//
//  Created by Jakub Gruszecki on 21.08.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HPVisitedMask.h"

@interface HPPositionMask : HPVisibilityMask {
	HPGameState* gameState;
}

- (id)initWithGameState: (HPGameState*) state;

@end
