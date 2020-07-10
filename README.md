# Goole LocationPicker

A ready for use and fully customizable location picker for your app.

![](https://raw.githubusercontent.com/MahmoudMMB/MMBGoogleLocationPicker/master/Screenshots/locationpicker.gif)

![Language](https://img.shields.io/badge/language-Swift%204.1-orange.svg)
[![CocoaPods](https://img.shields.io/cocoapods/v/MMBGoogleLocationPicker.svg?style=flat)](http://cocoadocs.org/docsets/MMBGoogleLocationPicker/)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![License](https://img.shields.io/github/license/JeromeTan1997/LocationPicker.svg?style=flat)

* [Features](#features)
* [Installation](#installation)
    - [Cocoapods](#cocoapods)
* [Quick Start](#quick-start)
    - [Programmatically](#programmatically)
* [Customization](#customization)
    - [Methods](#methods)
    - [Text](#text)
    - [Color](#color)
    - [Image](#image)
* [Change Log](#change-log)
* [Contribute](#contribute)
* [License](#license)

## Features
* Easy to use - A fully functional location picker can be integrated to your app within __5 lines__ of codes. `LocationPicker` can be subclassed in storyboard or programmatically.
* All kinds of locations to pick - Users can pick locations from their current location, search results or a list of locations provided by your app.
* Permission worry free - `LocationPicker` requests location access for you.

## Installation

### Cocoapods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate `LocationPicker` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'YourApp' do
    pod 'MMBGoogleLocationPicker'
end
```

## Quick Start

### Programmatically

Import `MMBGoogleLocationPicker`

```swift
import MMBGoogleLocationPicker
```

__NOTE__: If you installed via Cocoapods:

```swift
import MMBGoogleLocationPicker
```
present `MMBGoogleLocationPicker`, it needs to be nested inside a navigation controller so that it can be dismissed.
```swift
LocationPicker.googleMapKey = "Your_Goole_map_key"
let locationPicker = LocationPicker.shared
locationPicker.pickCompletion = { (pickedLocationItem) in
    if let coordinate = pickedLocationItem.coordinate {
        debugPrint("Picked location is (latitude: \(coordinate.latitude), longitude: \(coordinate.longitude))")
    }
}
locationPicker.addBarButtons()
// Call this method to add a done and a cancel button to navigation bar and set navigation bar background.
let navigationController = UINavigationController(rootViewController: locationPicker)
navigationController.navigationBar.isTranslucent = false
navigationController.navigationBar.tintColor = .white
navigationController.navigationBar.barTintColor = .black
navigationController.view.backgroundColor = .black
navigationController.viewControllers.first?.view.backgroundColor = .black
present(navigationController, animated: true, completion: nil)
```

##### `func addBarButtons`

This method provides 3 optional parameter. `doneButtonItem` and `cancelButtonItem` can be set as the customized `UIBarButtonItem` object. `doneButtonOrientation` is used to determine how to align these two buttons. If none of the parameters is provided, two system style buttons would be used, and the done button would be put on the right side.

After this method is called, these two buttons can be accessed via `barButtonItems` property.

##### `func setColors`

This method aims to set colors more conveniently. `themColor` will be set to `currentLocationIconColor`, `searchResultLocationIconColor`, `alternativeLocationIconColor`, `pinColor`. `primaryTextColor` and `secondaryTextColor` can also be set by this method.

##### `func setLocationDeniedAlertControllerTitle`

This method provides the text of `locationDeniedAlertController` simultaneously.

If this method is not called, the alert controller will be presented like this

![](https://raw.githubusercontent.com/MahmoudMMB/MMBGoogleLocationPicker/master/Screenshots/location-access.png)

__Grant__ button will direct user to the Settings where location access can be changed.

### Text

| Property name | Default | Target | Remark |
| ------------- |:-------:| ------ | ------ |
| currentLocationText | "Current Location" | currentLocationCell.locationNameLabel.text | The text that indicates the user's current location |
| searchBarPlaceholder | "Search for location" | searchBar.placeholder | The text that ask user to search for locations |
| locationDeniedAlertTitle | "Location access denied" | alertController.title | The text of the alert controller's title |
| locationDeniedAlertMessage | "Grant location access to use current location" | alertController.message | The text of the alert controller's message |
| locationDeniedGrantText | "Grant" | alertAction.title | The text of the alert controller's _Grant_ button |
| locationDeniedCancelText | "Cancel" | alertAction.title | The text of the alert controller's _Cancel_ button |

### Color

| Property name | Default | Target | Remark |
| ------------- |:-------:| ------ | ------ |
| tableViewBackgroundColor | UIColor.white | tableView.backgroundColor | The background color of the table view |
| currentLocationIconColor | UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1) | UIImage() | The color of the icon showed in current location cell, the icon image can be changed via property `currentLocationIconImage` |
| searchResultLocationIconColor | UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1) | UIImage() | The color of the icon showed in search result location cells, the icon image can be changed via property `searchResultLocationIconImage` |
| alternativeLocationIconColor | UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1) | UIImage() | The color of the icon showed in alternative location cells, the icon image can be changed via property 'alternativeLocationIconImage' |
| pinColor | UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1) | UIImage() | The color of the pin showed in the center of map view, the pin image can be changed via property `pinImage` |
| primaryTextColor | UIColor(colorLiteralRed: 0.34902, green: 0.384314, blue: 0.427451, alpha: 1) | Multiple | The text color of search bar and location name label in location cells |
| secondaryTextColor | UIColor(colorLiteralRed: 0.541176, green: 0.568627, blue: 0.584314, alpha: 1) | Multiple | The text color of location address label in location cells |

### Image

| Property name | Target | Remark |
| ------------- | ------ | ------ |
| currentLocationIconImage | currentLocationCell.iconView.image | The image of the icon showed in current location cell, this image's color won't be affected by property `currentLocationIconColor` |
| searchResultLocationIconImage | searchResultLocationCell.iconView.image | The image of the icon showed in search result location cells, this image's color won't be affected by property `searchResultLocationIconColor` |
| alternativeLocationIconImage | alternativeLocationCell.iconView.image | The image of the icon showed in alternative location cells, this image's color won't be affected by property `alternativeLocationIconColor` |

## Change Log

[CHANGELOG.md](https://github.com/MahmoudMMB/MMBGoogleLocationPicker/blob/master/CHANGELOG.md)

## Contribute

* If you encounter any bugs or other problems, please create issues or pull requests.
* If you want to add more features to `LocationPicker`, you are more than welcome to create pull requests.
* If you are good at English, please correct my English.
* If you like the project, please star it and share with others.
* If you have used LocationPicker in your App, please tell me by creating an issue.

## License

The MIT License (MIT)

Copyright (c) 2016 Jerome Tan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
