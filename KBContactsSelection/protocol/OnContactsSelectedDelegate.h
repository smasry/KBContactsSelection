//
//  OnContactsSelectedProtocol.h
//  KBContactsSelectionExample
//
//  Created by alberto Penas Amor on 13/2/15.
//  Copyright (c) 2015 Sigmapoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBContactsSelectionConfiguration.h"

@protocol OnContactsSelectedDelegate <NSObject>
- (void)selectedContacts:(NSArray*)contacts from:(KBContactsSelectionMode)mode;
@end
