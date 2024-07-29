# GiphyFinder

### The app in action
<img src="https://github.com/user-attachments/assets/a855dca1-782f-4208-8c46-c33020b9f694" height="400"/>

### Getting started

To run the app locally, you must create a file (`GiphyFinder/Secrets.plist`) and add a
key-value pair to it, that is, key with name `GiphyAPIKey` and a string value containing
your Giphy API key.

Note: if you do not have a Giphy API key, go to the Giphy Developers portal, create an
account and create an API key for iOS.

### Figma
Before creating the app I planned it out in Figma. To view it [see this link](https://www.figma.com/design/6qbZBGtM3tsyMn0tQPS7VJ/GiphyFinder-by-Patricia)
or just take a look at the screenshot below.
![figma](https://github.com/user-attachments/assets/ed4a680f-10ee-4fc0-95dd-9ad57d5b8fe4)

### Solution details
Solution was built and ran on Xcode version 15.4, macOS version 14.5, Swift 5.10.

Used SDWebImage as a package dependency to display individual GIFs. Other libraries, for
example, JellyGIF, might be faster, but SDWebImage is popular and stable.

The code handles multiple errors, but displays on the screen the following errors: too
many symbols in the search field, no internet connection. Additionally we could handle
and display more errors, for example, Giphy is down (>= 500 status code), API request
limit reached (max 100 calls per hour, status code 429), Giphy API key isn't set or
too many GIFs loaded (Giphy API max offset is 4999 and max limit is 50, that would make
the maximum 5049 or 5000 if we round down).

High quality GIFs are displayed also in the grid view, this was done to increase the
loading time, to see better how the loading indicator works. In the final version lower
quality GIFs should be used in the grid, and higher quality GIFs should be used in the
detailed view.

Code uses the MVC (Model-View-Controller) architecture pattern.

### References
1. [[Link]](https://www.youtube.com/watch?v=x9Vy-wmtYic) **YouTube video "Gif searching app in plain javascript using GIPHY API"**: to get some initial idea of how the final solution should look;
2. [[Link]](https://www.udemy.com/course/ios-13-app-development-bootcamp/) **Udemy course "iOS & Swift - The Complete iOS App Development Bootcamp"**: to learn iOS/Swift app development;
3. [[Link]](https://colorhunt.co/palette/f9f5f6f8e8eefdcedff2bed1) **Color Hunt**: to find a nice color palette for the app;
4. [[Link]](https://www.canva.com/) **Canva**: to create an icon/logo for the app;
5. [[Link]](https://figma.com/) **Figma**: to create the initial app design;
6. [[Link]](https://www.appicon.co/) **App Icon**: to get the 1x, 2x and 3x versions of the logo;
7. [[Link]](https://www.swift.org/documentation/) **Swift Documentation**: to understand Swift better;
8. [[Link]](https://developer.apple.com/documentation) **Apple Developer Documentation**: to understand UI components better;
9. [[Link]](https://chatgpt.com/) **ChatGPT**: to have useful conversations with an artificial iOS App Developer.
10. [[Link]](https://developers.giphy.com/) **GIPHY Developers**: to get API key and familiarize myself with the API;
11. [[Link]](https://vikramios.medium.com/disabling-dark-mode-in-ios-da0205344a1a) **Medium "Disabling Dark Mode in iOS Apps with Swift"**: to disable dark mode for the app;
12. [[Link]](https://iremkaraoglu.medium.com/get-started-with-uicollectionview-3e744b78ed7f) **Medium "Get started with UICollectionView 🍏"**: to understand UICollectionView;
13. [[Link]](https://developer.apple.com/forums/thread/16233) **Apple Developer "Find only stop to type"**: to implement auto-search;
14. [[Link]](https://stackoverflow.com/questions/7010547/uitextfield-text-change-event) **Stack Overflow "UITextField text change event"**: to implement auto-search;
15. [[Link]](https://stackoverflow.com/questions/24180954/how-to-hide-keyboard-in-swift-on-pressing-return-key) **Stack Overflow "How to hide keyboard in swift on pressing return key?"**: to close keyboard when pressing return;
16. [[Link]](https://www.youtube.com/watch?v=opkU2UuPk0A) **YouTube "Intro to Unit Testing in Swift"**: to implement unit tests.
17. [[Link]](https://www.hackingwithswift.com/example-code/networking/how-to-check-for-internet-connectivity-using-nwpathmonitor) **Hacking With Swift "How to check for internet connectivity using NWPathMonitor"**: to implement network availability handling.
18. [[Link]](https://stackoverflow.com/questions/38894031/swift-how-to-detect-orientation-changes) **Stack Overflow "Swift - How to detect orientation changes"**: to detect orientation change.
