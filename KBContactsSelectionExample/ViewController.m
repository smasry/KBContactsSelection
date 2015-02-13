//
//  ViewController.m
//  KBContactsSelectionExample
//
//  Created by Kamil Burczyk on 13.12.2014.
//  Copyright (c) 2014 Sigmapoint. All rights reserved.
//

#import "ViewController.h"
#import "KBContactsSelectionViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)push:(UIButton *)sender {
    
    KBContactsSelectionViewController *vc = [KBContactsSelectionViewController contactsSelectionViewControllerWithConfiguration:^(KBContactsSelectionConfiguration *configuration) {
        configuration.mode = KBContactsSelectionModeMessages;
        configuration.shouldShowNavigationBar = NO;
        configuration.tintColor = [UIColor blueColor];
    }];
    [vc setContactsDelegate:self];

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)present:(UIButton *)sender {
    
    KBContactsSelectionViewController *vc = [KBContactsSelectionViewController contactsSelectionViewControllerWithConfiguration:^(KBContactsSelectionConfiguration *configuration) {
        configuration.tintColor = [UIColor blueColor];
        configuration.mode = KBContactsSelectionModeEmail;
    }];
    [vc setContactsDelegate:self];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)selectedContacts:(NSArray*)contacts{
#ifndef NDEBUG
    NSLog(@"[%@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
    for (NSString* contact in contacts) {
        NSLog(@"%@", contact);
    }
}

@end
