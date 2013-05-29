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

@property (nonatomic, retain) DBFilesystem *filesystem;
@property (nonatomic, retain) DBPath *root;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
    if ([[fileNameArray objectAtIndex:(fileNameArray.count -1)] isEqual: @"PNG"]) {
        self.isImageFile = YES;

        DBPath* existingPath = [[DBPath root] childPath:theFileName];
        DBFile* file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:nil];
        NSData* imageData = [file readData:nil];
        UIImage* theImage = [[UIImage alloc]initWithData:imageData];
        
        cell.imageView.image = theImage;
        cell.textView.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else {
        self.isImageFile = NO;
        
        DBPath* existingPath = [[DBPath root] childPath:theFileName];
        DBFile* file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:nil];
        NSString* theContents = [file readString:nil];

        cell.textView.text = theContents;
        cell.imageView.image = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        
    return cell;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 170.0f;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
//}

@end
