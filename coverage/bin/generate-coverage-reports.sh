#!/bin/bash -x
#
#  generate-coverage.sh
#  DLRAppStoreRatings
#
#  Created by Nate Walczak on 3/25/15.
#  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
#

#
#  Xcode -> Preferences
#
#  Locations
#    Derived Data: Relative
#

#
#  Target Build Settings
#
#  Apple LLVM 6.0 - Code Generation
#    Generate Test Coverage Files: Yes
#    Instrument Program Flow: Yes
#

#
#  Before you can run this script:
#
#  1) Make sure that you've change your Xcode preferences
#  2) Run Product -> Clean
#  3) Run Product -> Test
#

TARGET_NAME="DLRAppStoreRatings"
TEST_TARGET_NAME="DLRAppStoreRatingsTests"

ROOT_DIR="`dirname $0`/../../"

DERIVED_DATA_DIR="DerivedData/${TARGET_NAME}/Build/Intermediates/${TARGET_NAME}.build/Debug-iphonesimulator/${TEST_TARGET_NAME}.build/Objects-normal/x86_64"
COVERAGE_REPORTS_DIR="coverage/reports"
COVERAGE_HTML_FILE="${COVERAGE_REPORTS_DIR}/coverage.html"

(cd "$ROOT_DIR" ; [ ! -d "${COVERAGE_REPORTS_DIR}" ] && mkdir "${COVERAGE_REPORTS_DIR}")

(cd "$ROOT_DIR" ; gcovr -r . --object-directory "${DERIVED_DATA_DIR}" --exclude '.*main.*' --html --html-details -o "${COVERAGE_HTML_FILE}")
