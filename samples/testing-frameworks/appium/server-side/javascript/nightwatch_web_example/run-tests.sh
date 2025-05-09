#!/bin/bash

changeNpmCacheLocation(){
	echo "Change npm cache to .npm_cache folder..."
	mkdir .npm_cache
	npm config set cache ~/.npm_cache
}

startIOSWebkitProxy(){
	echo "Will start ios_webkit on port: 27753 for UDID: ${IOS_UDID}"
	node /opt/appium/bin/ios-webkit-debug-proxy-launcher.js -c ${IOS_UDID}:27753 -d > ios-webkit-debug-proxy.log 2>&1 &
}

startAppium(){
	if [ "$(uname)" == "Darwin" ]; then
		#startWebkit proxy for web testing
		startIOSWebkitProxy
		echo "Starting Appium on Mac..."
		appium --log-no-colors --log-timestamp
	elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
		# Create the screenshots directory, if it doesn't exist'
		echo "Starting Appium on Linux..."
    # Use appium-X.X, to choose a specific Appium server version. More about supported versions at
    # https://support.smartbear.com/bitbar/docs/en/mobile-app-tests/automated-testing/appium-support.html
		appium --log-no-colors --log-timestamp
	else
		echo "Operating system not supported, exiting..."
		exit 1
	fi

	sleep 10
	ps -ef|grep appium
}

initializeTestRun(){
	echo "Extracting tests.zip..."
	unzip tests.zip
	echo "Installing Project Dependencies..."
	npm install
	rm -f tests/reports/*
}

executeTests(){
	if [ "$(uname)" == "Darwin" ]; then
		echo "Running iOs Tests..."
		npm run test:ios
	elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
		echo "Running Android Tests..."
		npm run test:android
	fi
	echo "Finished Running Tests!"

	cp tests/reports/*.xml TEST-all.xml

	if [ ! -f "TEST-all.xml" ]; then
		echo "Error occured during the test run";
		exit 1
	fi
}


changeNpmCacheLocation
startAppium
initializeTestRun
executeTests

