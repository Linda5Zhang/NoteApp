//
//  ViewController.m
//  NoteApp
//
//  Created by yueling zhang on 5/22/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import "ViewController.h"
#import "NotesTableViewController.h"
#import <EventKit/EventKit.h>

@interface ViewController ()
@property (strong, nonatomic)UINavigationBar* navBar;
@property (strong, nonatomic)NSString *theNoteDate;
@property (strong, nonatomic)UITextView* textView;
@property (strong, nonatomic)UIImageView* imageView;
@property BOOL isAddImage;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[DBAccountManager sharedManager]linkFromController:self.navigationController];
    
    //Self navigation bar, add a bar button, called 'list of notes'
    UIBarButtonItem* listOfNotes = [[UIBarButtonItem alloc] initWithTitle:@"List Of Notes" style:UIBarButtonItemStyleBordered target:self action:@selector(listNotes)];
    self.navigationItem.rightBarButtonItem = listOfNotes;
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, self.view.bounds.size.width, 160)];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont systemFontOfSize:20];
    self.textView.textColor =[UIColor blueColor];
    self.textView.delegate = self;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.textView];
    
    
    //add a NEW navigation bar for keyboard, and add two bar buttons
    self.navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(5, 5, self.view.bounds.size.width, 44)];
    UINavigationItem *navItem = [[UINavigationItem alloc]init];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneTyping)];
    
    UIBarButtonItem* cameraButton = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStyleBordered target:self action:@selector(addPhotos)];
    
    navItem.leftBarButtonItem = cameraButton;
    navItem.rightBarButtonItem = doneButton;
    self.navBar.items = [[NSArray alloc] initWithObjects:navItem, nil];
    
    //add NEW navigation bar as accessory view for keyboard
    self.textView.inputAccessoryView = self.navBar;
    
    self.theNoteDate = [self theNoteDate];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [self.textView becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.imageView.image = nil;
    self.textView.text = @"";
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)theNoteDate
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss MM-dd-yyyy"];
    NSString* theDate = [formatter stringFromDate:[NSDate date]];
    return theDate;
}

- (void) listNotes
{
    NotesTableViewController* ntvc = [[NotesTableViewController alloc] init];
    [self.navigationController pushViewController:ntvc animated:YES];
}

- (void) addPhotos
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void) doneTyping
{
    //No text or photo, show alert
    if ([[self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0 && self.isAddImage == NO) {
    
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"Empty" message:@"The note is empty." delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
        [emptyAlert show];
        
    }else{
        NSString* dataInTextView = self.textView.text;
        NSArray* splitData = [dataInTextView componentsSeparatedByString:@":"];
        
        //Determine whether there's "TODO:" string
        if (splitData.count > 1) {
            NSString* toDoThings = [splitData objectAtIndex:1];
            NSArray* contentArray = [toDoThings componentsSeparatedByString:@"\n"];
            NSString* firstPart = [contentArray objectAtIndex:0];
            
            
            if ([[splitData objectAtIndex:0] isEqual:@"TODO"]) {//has "TODO:" string, add reminder
                
                EKEventStore* eventStore = [[EKEventStore alloc] init];
                
                if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
                    // iOS 6 and later
                    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                        if (granted){
                            //---- codes here when user allow your app to access theirs' calendar.
                            EKEvent* myEvent = [EKEvent eventWithEventStore:eventStore];
                            myEvent.title = firstPart;
                            myEvent.notes = toDoThings;
                            myEvent.startDate = [[NSDate alloc] init];
                            myEvent.endDate = [[NSDate alloc] init];
                            [myEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
                            
                            NSError* err;
                            [eventStore saveEvent:myEvent span:EKSpanThisEvent error:&err];
                            if(err)
                                NSLog(@"unable to save event to the calendar!: Error= %@", err);
                        }else
                        {
                            //----- codes here when user NOT allow your app to access the calendar.
                            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Not allowed" message:@"The user does not allow to get the calendar." delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
                            [errorAlert show];
                        }
                    }];
                }
                else {
                    //---- codes here for IOS < 6.0.
                    EKEvent* myEvent = [EKEvent eventWithEventStore:eventStore];
                    myEvent.title = firstPart;
                    myEvent.notes = toDoThings;
                    myEvent.startDate = [[NSDate alloc] init];
                    myEvent.endDate = [[NSDate alloc] init];
                    [myEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
                    
                    NSError* err;
                    [eventStore saveEvent:myEvent span:EKSpanThisEvent error:&err];
                    if (err) {
                        NSLog(@"Unable to save event to the calendar. Error is : %@",err);
                    }   
                }
                
            }//end add reminder
        }//no ":", no "TODO:", no need to add reminder
        
        //Add an image file or txt file to dropbox
        if (self.isAddImage == NO) {
            NSString* theFileName = [[NSString alloc] initWithFormat:@"%@.txt",self.theNoteDate];
            NSString* theContent = self.textView.text;
            
            DBPath* newPath = [[DBPath root] childPath:theFileName];
            DBFile* file = [[DBFilesystem sharedFilesystem] createFile:newPath error:nil];
            [file writeString:theContent error:nil];
            NSLog(@"save the txt file to dropbox.");
        } else {
            self.isAddImage = NO;
            [self.textView resignFirstResponder];
            
            UIGraphicsBeginImageContext(self.view.bounds.size);
            [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage* savedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIGraphicsBeginImageContext(CGSizeMake(160, 160));
            [savedImage drawInRect: CGRectMake(0, 0, 160, 160)];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData *imageData = UIImagePNGRepresentation(resizedImage);
            NSString* theFileName = [[NSString alloc] initWithFormat:@"%@.PNG",self.theNoteDate];
            DBPath* newPath = [[DBPath root] childPath:theFileName];
            DBFile* file = [[DBFilesystem sharedFilesystem] createFile:newPath error:nil];
            [file writeData:imageData error:nil];
            NSLog(@"save the image file to dropbox.");
        }

        [self.textView becomeFirstResponder];
        self.imageView.image = nil;
        self.textView.text = @"";
    }
    
}


#pragma mark UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the image from info dictionary
    UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:^{
        self.imageView.image = image;
        self.isAddImage = YES;
    }];
    
}


@end
