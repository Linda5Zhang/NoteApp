//
//  NotesTableViewController.m
//  NoteApp
//
//  Created by yueling zhang on 5/26/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import "NotesTableViewController.h"
#import "CustomCell.h"

@interface NotesTableViewController ()

@property (nonatomic, retain) NSMutableArray *contents;
@property BOOL isImageFile;

@end

@implementation NotesTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[CustomCell class] forCellReuseIdentifier:@"Cell"];

    NSArray* filesArray = [[DBFilesystem sharedFilesystem] listFolder:[DBPath root] error:nil];
    self.contents = [[NSMutableArray alloc] initWithArray:filesArray];
    NSLog(@"contents are %@",self.contents);
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    DBFileInfo* theInfo = [self.contents objectAtIndex:[indexPath row]];
    DBPath* thePath = [theInfo path];
    NSString* theFileName = [thePath name];
    NSLog(@"the name of the file : %@",theFileName);
    
    NSArray* fileNameArray = [theFileName componentsSeparatedByString:@"."];
    if ([[fileNameArray objectAtIndex:(fileNameArray.count -1)] isEqual: @"PNG"]) {//Show Image Note
        self.isImageFile = YES;

        DBPath* existingPath = [[DBPath root] childPath:theFileName];
        DBFile* file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:nil];
        NSData* imageData = [file readData:nil];
        UIImage* theImage = [[UIImage alloc]initWithData:imageData];
        
        cell.imageView.image = theImage;
        cell.textView.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {//Show Text Note
        self.isImageFile = NO;
        
        DBPath* existingPath = [[DBPath root] childPath:theFileName];
        DBFile* file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:nil];
        NSString* theContents = [file readString:nil];

        cell.textView.text = theContents;
        cell.textView.userInteractionEnabled = YES;
        cell.imageView.image = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        
    return cell;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 170.0f;
}


@end
