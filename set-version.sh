#!/bin/sh

#  set-version.sh
#  MMSCameraViewController
#
#  Created by William Miller on 9/2/18.
#  Copyright © 2018 CocoaPods. All rights reserved.
echo $1
echo "MMSProfileImagePicker"
pwd
agvtool new-marketing-version $1
echo "MMSProfileImagePicker-Example"
cd example
pwd
agvtool new-marketing-version $1

