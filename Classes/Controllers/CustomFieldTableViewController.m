//
//  CustomFieldTableViewController.m
//  Ushahidi_iOS
//
//  Created by Bhadrik Patel on 9/18/12.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

#import "CustomFieldTableViewController.h"
#import "TableCellFactory.h"
#import "LoadingViewController.h"
#import "Settings.h"
#import "Incident.h"

@interface CustomFieldTableViewController ()

@end

@implementation CustomFieldTableViewController
@synthesize incident, customField;
@synthesize cancelButton,doneButton;

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.navigationBar.topItem.title = self.customField.fieldName;
    self.doneButton.title = NSLocalizedString(@"Done", nil);
    if ([self.doneButton respondsToSelector:@selector(setTintColor:)]) {
        self.doneButton.tintColor = [[Settings sharedSettings] doneButtonColor];
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
   	[self.allRows removeAllObjects];
	[self.filteredRows removeAllObjects];
	[self.allRows addObjectsFromArray:[self.customField defaultValues]];
	[self.filteredRows addObjectsFromArray:self.allRows];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc {
	[cancelButton release];
	[doneButton release];
	[incident release];
    [customField release];
    [super dealloc];
}


#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return self.filteredRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CheckBoxTableCell *cell = [TableCellFactory getCheckBoxTableCellForDelegate:self table:theTableView indexPath:indexPath];
	if (([customField defaultValues] != nil) && ([[customField defaultValues] count ] > 0)){
		[cell setTitle:(NSString *)[self.customField.defaultValues objectAtIndex:indexPath.row]];	
		if(customField.fieldType == CheckBoxFieldType){
            if([incident getCustomFieldCheckBoxValue:customField.fieldID choiceNum:indexPath.row] != nil){
                [cell setChecked:YES];
            }else {
                [cell setChecked:NO];
            }
            
        }else if((customField.fieldType == RadioFieldType)||(customField.fieldType == DropDownFieldType)){
            if([incident getCustomFieldValue:customField.fieldID] == nil){
                if(indexPath.row == 0){
                    [cell setChecked:YES];
                    [incident addUpdateCustomFieldValue:[self.customField.defaultValues objectAtIndex:0] forFieldID:[self.customField fieldID]];
                }else {
                    [cell setChecked:NO];
                }
            }else {
                if([cell.textLabel.text isEqualToString:[incident getCustomFieldValue:customField.fieldID]]){
                    [cell setChecked:YES];
                }else {
                    [cell setChecked:NO];
                }
            }
        }
	}
	else {
		[cell setTitle:nil];
		[cell setDescription:nil];
		[cell setChecked:NO];
	}
	return cell;
}


- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	CheckBoxTableCell *cell = (CheckBoxTableCell *)[theTableView cellForRowAtIndexPath:indexPath];
	if (cell.checked) {
        if(customField.fieldType == CheckBoxFieldType){
            [cell setChecked:NO];
            [self.incident removeCustomFieldCheckBoxChoice:customField.fieldID choiceNum:indexPath.row];
        } 
	}
	else {
        
        if((customField.fieldType == RadioFieldType)||(customField.fieldType == DropDownFieldType)){
            [cell setChecked:YES];
            [self.incident addUpdateCustomFieldValue:[cell.textLabel text] forFieldID:customField.fieldID];
            [self.tableView reloadData];
        }if(customField.fieldType == CheckBoxFieldType){
            [cell setChecked:YES];
            [self.incident addCustomFieldCheckBoxChoice:[cell.textLabel text] forFieldID:customField.fieldID choiceNum:indexPath.row];
        }
	}
}

#pragma mark -
#pragma mark CheckBoxTableCellDelegate

- (void) checkBoxTableCellChanged:(CheckBoxTableCell *)cell index:(NSIndexPath *)indexPath checked:(BOOL)checked {
	
	DLog(@"customCheckBoxTableCellChanged:%@ index:[%d, %d] checked:%d", cell.textLabel.text, indexPath.section, indexPath.row, checked)
	if (cell.checked) {
        
        if((customField.fieldType == RadioFieldType)||(customField.fieldType == DropDownFieldType)){
            [self.incident addUpdateCustomFieldValue:[cell.textLabel text] forFieldID:customField.fieldID];
            [self.tableView reloadData];
            [cell setChecked:YES];
        }
        if(customField.fieldType == CheckBoxFieldType){
            [self.incident addCustomFieldCheckBoxChoice:[cell.textLabel text] forFieldID:customField.fieldID choiceNum:indexPath.row];
            [cell setChecked:YES];
        }
       
	}
	else {
        if(customField.fieldType == CheckBoxFieldType){
            [self.incident removeCustomFieldCheckBoxChoice:customField.fieldID choiceNum:indexPath.row];
            [cell setChecked:NO];
        } 
        
        if((customField.fieldType == RadioFieldType)||(customField.fieldType == DropDownFieldType)){
            [self.tableView reloadData];
        }
	}
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void) filterRows:(BOOL)reloadTable {
	[self.filteredRows removeAllObjects];
	NSString *searchText = [self getSearchText];
	for (Category *category in self.allRows) {
		if ([category matchesString:searchText]) {
			[self.filteredRows addObject:category];
		}
	}
	DLog(@"Re-Adding Rows");
	if (reloadTable) {
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
	}
} 

@end

