#!/bin/sh

#  bump-build.sh
#  MMSCameraViewController
#
#  Created by William Miller on 9/2/18.
#  Copyright © 2018 CocoaPods. All rights reserved.
echo "MMSCameraViewController"
pwd
agvtool what-version
agvtool next-version
agvtool what-version
echo "MMSCameraViewController-Example"
cd example
pwd
agvtool what-version
agvtool next-version
agvtool what-version
