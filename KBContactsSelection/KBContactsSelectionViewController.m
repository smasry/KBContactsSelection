//
//  KBContactsSelectionViewController.m
//  KBContactsSelectionExample
//
//  Created by Kamil Burczyk on 13.12.2014.
//  Copyright (c) 2014 Sigmapoint. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "KBContactsSelectionViewController.h"
#import "KBContactsTableViewDataSource.h"

@interface KBContactsSelectionViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) KBContactsTableViewDataSource *kBContactsTableViewDataSource;
@property (nonatomic, strong) KBContactsSelectionConfiguration *configuration;

@end

@implementation KBContactsSelectionViewController

+ (KBContactsSelectionViewController*)contactsSelectionViewControllerWithConfiguration:(void (^)(KBContactsSelectionConfiguration* configuration))configurationBlock
{
    KBContactsSelectionViewController *vc = [[KBContactsSelectionViewController alloc] initWithNibName:@"KBContactsSelectionViewController" bundle:nil];
    
    KBContactsSelectionConfiguration *configuration = [KBContactsSelectionConfiguration defaultConfiguration];
    
    if (configurationBlock) {
        configurationBlock(configuration);
    }
    
    vc.configuration = configuration;

    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self prepareContactsDataSource];
    [self prepareNavigationBar];
    [self customizeColors];
}

- (void)prepareContactsDataSource
{
    _kBContactsTableViewDataSource = [[KBContactsTableViewDataSource alloc] initWithTableView:_tableView configuration:_configuration];
    _tableView.dataSource = _kBContactsTableViewDataSource;
    _tableView.delegate = _kBContactsTableViewDataSource;
}

- (void)prepareNavigationBar
{
    if (!_configuration.shouldShowNavigationBar) {
        _navigationBarSearchContactsHeight.constant = 0;
        _navigationBarSearchContacts.hidden = YES;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", nil) style:UIBarButtonItemStylePlain target:self action:@selector(buttonSelectPushed:)];
        [self.navigationItem setRightBarButtonItem:bi animated:YES];
        
        self.title = NSLocalizedString(@"Search contacts", nil);
    }
}

- (void)customizeColors
{
    _navigationBarSearchContacts.tintColor = _configuration.tintColor;
    self.navigationController.navigationBar.tintColor = _configuration.tintColor;
    _searchBar.tintColor = _configuration.tintColor;
    _tableView.sectionIndexColor = _configuration.tintColor;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_kBContactsTableViewDataSource runSearch:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - IBActions

- (IBAction)buttonCancelPushed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buttonSelectPushed:(id)sender {
    if (_configuration.mode == KBContactsSelectionModeMessages) {
        [self showMessagesViewControllerWithSelectedContacts];
    } else {
        [self showEmailViewControllerWithSelectedContacts];
    }
}

- (void)showMessagesViewControllerWithSelectedContacts
{
    
    if (_contactsDelegate) {
        [self dismissViewControllerAnimated:YES completion:^(void){
            [_contactsDelegate selectedContacts:[_kBContactsTableViewDataSource selectedContacts] from:KBContactsSelectionModeMessages];
            _contactsDelegate = nil;
        }];
    }else{
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *messageComposeVC = [[MFMessageComposeViewController alloc] init];
            messageComposeVC.delegate = self;
            messageComposeVC.recipients = [_kBContactsTableViewDataSource phonesOfSelectedContacts];
            [self presentViewController:messageComposeVC animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Messaging not supported", @"") message:NSLocalizedString(@"Messaging on this device is not  supported.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void)showEmailViewControllerWithSelectedContacts{
    if (_contactsDelegate) {
        [self dismissViewControllerAnimated:YES completion:^(void){
            [_contactsDelegate selectedContacts:[_kBContactsTableViewDataSource emailsOfSelectedContacts] from:KBContactsSelectionModeEmail];
            _contactsDelegate = nil;
        }];
    }else{
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
            mailComposeVC.mailComposeDelegate = self;
            [mailComposeVC setToRecipients:[_kBContactsTableViewDataSource emailsOfSelectedContacts]];
        
            [self presentViewController:mailComposeVC animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Messaging not supported", @"") message:NSLocalizedString(@"Sending emails from this device is not supported.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
        }
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
