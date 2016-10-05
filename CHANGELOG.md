# Change Log
All notable changes to this project will be documented in this file.
`MMSProfileImagePicker` adheres to [Semantic Versioning](http://semver.org/).


## [1.2.0](https://github.com/miller-ms/MMSProfileImagePicker/releases/tag/1.2.0)
Released on 2016-10-04. 

#### Updated
- Corrected problem where unable to sitch camera when return to camera from edit screen (#1)
- Replaced UIImagePickerController with MMSCameraViewController Pod for taking.
- Has a limitation when taking a photo with the front lens where the captured image is the mirrored reflection.  Needs a new version of the camera object to correct.
- Dependent pod MMSCameraViewController requires swift 3.
- Added by [William Miller](https://github.com/miller-ms).


## [1.1.0](https://github.com/miller-ms/MMSProfileImagePicker/releases/tag/1.1.0)
Released on 2016-06-11. 

#### Added
- Refreshed project files for cocoapods 1.0.1
- Worked out all the kinks with travis-ci to build the complete project
- Published to cocoapods.
- Still need to beef up the automated tests.
- Corrected constraint warning in example storyboard.
- Corrected build warnings for build targets where cocoapods used ${} instead of $()
- Removed version history from readme.md
 - Added by [William Miller](https://github.com/miller-ms).

## [1.0.5](https://github.com/miller-ms/MMSProfileImagePicker/releases/tag/1.0.5)
Released on 2016-03-08. 

#### Added
- Updated example code with version 1.0.5.
 - Added by [William Miller](https://github.com/miller-ms).

## [1.0.4](https://github.com/miller-ms/MMSProfileImagePicker/releases/tag/1.0.4)
Released on 2016-03-08. 

#### Added
- Added appledoc comments to MMSProfileImagePickerDelegate.
 - Added by [William Miller](https://github.com/miller-ms).
- Added CHANGELOG.md file.
 - Added by [William Miller](https://github.com/miller-ms).

#### Updated
- Renamed property maxiumuZoomScale to maximumZoomScale
- Added references to articles in the README.md
 - Updated by [William Miller](https://github.com/miller-ms).

#### Removed
- Removed commented out code that no longer applies.
 - Removed by [William Miller](https://github.com/miller-ms).

#### Fixed

## [1.0.3](https://github.com/miller-ms/MMSProfileImagePicker/releases/tag/1.0.3)
Released on 2016-03-08. 

#### Updated
- Embellished and corrected comments to support appledoc.
  - Updated by [William Miller](https://github.com/miller-ms).

## [1.0.2](https://github.com/miller-ms/MMSProfileImagePicker/releases/tag/1.0.2)
Released on 2016-03-08. 

#### Updated
- updated documentation to conform with appledocs format.
 - Updated by [William Miller](https://github.com/miller-ms).


## [1.0.1](https://github.com/miller-ms/MMSProfileImagePicker/releases/tag/1.0.1)
Released on 2016-03-02. 

#### Fixed
- Problems with successful travis-ci builds.
  - Fixed by [William Miller](https://github.com/miller-ms).

## [1.0.0](https://github.com/miller-ms/MMSProfileImagePicker/releases/tag/1.0.0)
Released on 2016-02-28. 

#### Added
- Initial release of MMSProfileImagePicker.
 - Added by [William Miller](https://github.com/miller-ms).
