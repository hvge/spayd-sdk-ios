#!/bin/sh
# ---------------------------------------------------------------------
# [/] SmartPlatba
#
# Copyright 2012 www.qr-platba.cz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: Juraj Durech <juraj@inmite.eu>
# ---------------------------------------------------------------------

set +v

# global settings
TARGET_NAME=SmartPayment
TMP_DIR="../Temp"
OUTPUT_DIR="../Library"
OUTPUT_BASE_DIR="$OUTPUT_DIR/$TARGET_NAME"
SRC_DIR="./$TARGET_NAME"

# find tools
XCODEBUILD=`xcrun -sdk iphoneos -find xcodebuild`
LIPO=`xcrun -sdk iphoneos -find lipo`
CP="cp"
RM="rm"
MKDIR="mkdir"

# Build a single platform (iphone / simulator)

function BUILD_PLATFORM
{
	LIBNAME=$1
	PLATFORM=$2
		
	echo "$0: -----------------------------------------------------"
	echo "$0: Building $LIBNAME for platform $PLATFORM"
	echo "$0: -----------------------------------------------------"

	BUILD_DIR="$TMP_DIR/$LIBNAME-$PLATFORM"
	$XCODEBUILD -project $LIBNAME.xcodeproj -configuration 'Release' -sdk $PLATFORM CONFIGURATION_BUILD_DIR=$BUILD_DIR OBJROOT=$TMP_DIR clean
	if [ $? -ne 0 ]; then
		exit 1;
	fi
	$XCODEBUILD -project $LIBNAME.xcodeproj -configuration 'Release' -sdk $PLATFORM CONFIGURATION_BUILD_DIR=$BUILD_DIR OBJROOT=$TMP_DIR build
}

function CREATE_FAT_LIBRARY
{
	echo "$0: -----------------------------------------------------"
	echo "$0: Creating fat library"
	echo "$0: -----------------------------------------------------"
	
	LIBNAME=$1
	PLATFORM1="$TMP_DIR/$LIBNAME-$2/lib$LIBNAME.a"
	PLATFORM2="$TMP_DIR/$LIBNAME-$3/lib$LIBNAME.a"
	OUTPUT="$OUTPUT_BASE_DIR/lib$LIBNAME.a"
	
	$RM -r "$OUTPUT_BASE_DIR"
	$MKDIR -p "$OUTPUT_BASE_DIR"
	if [ $? -ne 0 ]; then
		exit 1;
	fi
	
	$LIPO -create $PLATFORM1 $PLATFORM2 -output $OUTPUT
	if [ $? -ne 0 ]; then
		echo "$1: can't create universal library $1"
		exit 1;
	fi
	
	# copy headers

	$CP $LIBNAME/*.h $OUTPUT_BASE_DIR
	if [ $? -ne 0 ]; then
		exit 1;
	fi
	$MKDIR $OUTPUT_BASE_DIR/CountrySpecific
	if [ $? -ne 0 ]; then
		exit 1;
	fi
	$CP $LIBNAME/CountrySpecific/*.h $OUTPUT_BASE_DIR/CountrySpecific
	if [ $? -ne 0 ]; then
		exit 1;
	fi
	
	echo "$0: -----------------------------------------------------"
	echo "$0: Creating archive..."
	echo "$0: -----------------------------------------------------"
	pushd $OUTPUT_DIR
	tar -zcvf $LIBNAME.tar.gz $LIBNAME
	popd
}

# do the stuff

mkdir -p "$TMP_DIR"
if [ $? -ne 0 ]; then
	exit 1;
fi

BUILD_PLATFORM $TARGET_NAME iphoneos
if [ $? -ne 0 ]; then
	exit 1;
fi

BUILD_PLATFORM $TARGET_NAME iphonesimulator
if [ $? -ne 0 ]; then
	exit 1;
fi

CREATE_FAT_LIBRARY $TARGET_NAME iphoneos iphonesimulator
if [ $? -ne 0 ]; then
	exit 1;
fi

# cleanup

$RM -r build
$RM -r "$TMP_DIR"

echo "$0: -----------------------------------------------------"
echo "$0: OK"
echo "$0: -----------------------------------------------------"

