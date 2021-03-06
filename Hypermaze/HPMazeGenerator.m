//
//  HPMazeGenerator.m
//  Hypermaze
//
//  Created by Jakub Gruszecki on 22.07.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>
#import "HPMazeGenerator.h"
#import "FS3DPoint.h"
#import "HPDirection.h"
#import "HPDirectionUtil.h"
#import "HPChamberUtil.h"
#import "HPGlobals.h"
#import "HPPathFinder.h"

#define MOLE_MAX_LENGTH 20
#define MOLE_MIN_LENGTH 2

FS3DPoint getNextFreeChamber(Byte ***topology, int size) {
	for (int i=0; i<size; i++) {
		for (int j=0; j<size; j++) {
			for (int h=0; h<size; h++) {
				if (topology[i][j][h] == 0) {
					return point3D(i,j,h);
				}
			}
		}
	}
	return INVALID_POINT;
}

BOOL isPositionValid(FS3DPoint position, int size) {
	return position.x >= 0 && position.y >=0 && position.z >= 0 && position.x < size && position.y < size && position.z < size;
}

BOOL isChamberFree(Byte*** topology, FS3DPoint position) {
	return topology[position.x][position.y][position.z] == 0;
}

void crushWallInDirection(Byte*** top, FS3DPoint pos, HPDirection dir)
{
	top[pos.x][pos.y][pos.z] = [HPChamberUtil createPassageInDirection:dir chamber:top[pos.x][pos.y][pos.z]];
}

FS3DPoint digIntoChamber(Byte*** topology, FS3DPoint position, HPDirection direction) {
	FS3DPoint nextPosition = [HPDirectionUtil moveInDirection: direction fromPoint: position];
	HPDirection opositeDirection = [HPDirectionUtil getOpositeDirectionTo: direction];
	crushWallInDirection(topology, position, direction);
	crushWallInDirection(topology, nextPosition, opositeDirection);
	return nextPosition;
}

Byte *** initTopology(int size) {
	Byte ***topology = (Byte***) malloc(size*sizeof(Byte**));
	for (int i=0; i<size; i++) {
		topology[i] = (Byte**) malloc(size*sizeof(Byte*));
		for (int j=0; j<size; j++) {
			topology[i][j] = (Byte*) malloc(size*sizeof(Byte));
			for (int h=0; h<size; h++) {
				topology[i][j][h] = 0;
			}
		}
	}
	return topology;
}

@implementation HPMazeGenerator

- (id) init {
    if (self = [super init]) {
		status = genBegin;
		progress = 0;
		maze = nil;
    }
    return self;
}

void digEntranceAndExit(Byte ***topology,int size) {
	crushWallInDirection(topology, BEGIN_POINT, dirSouthEast);
	crushWallInDirection(topology, point3D(size-1, size-1, size-1), dirNorthWest);

}
- (int) randomMoleLength {
    int moleMax = arc4random() % (MOLE_MAX_LENGTH - MOLE_MIN_LENGTH) + MOLE_MIN_LENGTH;
    return moleMax;
}

- (void) generateMazeInSize: (int) size {
	status = genWorking;
	Byte ***topology = initTopology(size);
	BOOL firstMole = YES;
	int totalChambers = (int)pow(size, 3);
	int diggedChambers = 1;
	int moleLength = 0;
	FS3DPoint molePosition = BEGIN_POINT;
	HPDirection* allDirections = [HPDirectionUtil getAllDirections];
	int moleMax = [self randomMoleLength];
	do {
		moleLength++;
		[NSThread sleepForTimeInterval:0.00005]; 
		if (!firstMole && moleLength==1) {
			HPDirection dirToExisting;
			for (int i=0; i<DIR_TOTAL_DIRECTIONS; i++) {
				dirToExisting = allDirections[i];
				FS3DPoint visitedPosition = [HPDirectionUtil moveInDirection: dirToExisting fromPoint: molePosition];
				if (isPositionValid(visitedPosition, size)) {
					if (!isChamberFree(topology, visitedPosition)) {
						break;
					}
				}
			}
			digIntoChamber(topology, molePosition, dirToExisting);
			diggedChambers++;
			progress = (double)diggedChambers/(double)totalChambers;
		} else {
			firstMole = NO;
		}
		
		HPDirection randomDirection = allDirections[arc4random() % DIR_TOTAL_DIRECTIONS];
		HPDirection moleDirection = randomDirection;
		BOOL canDigIntoChamber = NO;
		BOOL checkedAllDirections = NO;
		do {
			moleDirection = [HPDirectionUtil getNextDirection: moleDirection];
			checkedAllDirections = moleDirection == randomDirection;
			FS3DPoint nextMolePosition = [HPDirectionUtil moveInDirection: moleDirection fromPoint: molePosition];
			canDigIntoChamber = isPositionValid(nextMolePosition, size) && isChamberFree(topology, nextMolePosition);
		} while (!(canDigIntoChamber || checkedAllDirections));
		if (canDigIntoChamber && moleLength < moleMax) {
			molePosition = digIntoChamber(topology, molePosition, moleDirection);
			diggedChambers++;
			progress = (double)diggedChambers/(double)totalChambers;
		} else {
			molePosition = getNextFreeChamber(topology, size);
			moleLength = 0;
			moleMax = [self randomMoleLength];
		}
	} while (totalChambers > diggedChambers);
	digEntranceAndExit(topology,size);
	NSArray* solution = [HPPathFinder findPathInTopology:topology size:size from:BEGIN_POINT to:point3D(size-1, size-1, size-1)];
	maze = [[HPMaze alloc] initWithTopology: topology size: size solution: solution];
	status = genComplete;
}

- (HPMazeGeneratorState) getStatus {
	return status;
}

- (double) getProgress {
	return progress;
}

- (HPMaze*) getMaze {
	return maze;
}

-(void)dealloc {
	[maze release];
	[super dealloc];
}

@end
