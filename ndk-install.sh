#!/bin/bash

# Script to install NDK into AndroidIDE
install_dir=$HOME
sdk_dir=$install_dir/android-sdk
cmake_dir=$sdk_dir/cmake
ndk_base_dir=$sdk_dir/ndk

ndk_dir=""
ndk_ver=""
ndk_ver_name=""
ndk_file_name=""
ndk_installed=false
cmake_installed=false
echo "Select with NDK version you need install?"

select item in r17c r18b r19c r20b r21e r22b r23b r24 Quit; do
	case $item in
	"r17c")
		ndk_ver="17.2.4988734"
		ndk_ver_name="r17c"
		break
		;;
	"r18b")
		ndk_ver="18.1.5063045"
		ndk_ver_name="r18b"
		break
		;;
	"r19c")
		ndk_ver="19.2.5345600"
		ndk_ver_name="r19c"
		break
		;;
	"r20b")
		ndk_ver="20.1.5948944"
		ndk_ver_name="r20b"
		break
		;;
	"r21e")
		ndk_ver="21.4.7075529"
		ndk_ver_name="r21e"
		break
		;;
	"r22b")
		ndk_ver="22.1.7171670"
		ndk_ver_name="r22b"
		break
		;;
	"r23b")
		ndk_ver="23.2.8568313"
		ndk_ver_name="r23b"
		break
		;;
	"r24")
		ndk_ver="24.0.8215888"
		ndk_ver_name="r24"
		break
		;;

	"Quit")
		echo "Exit.."
		exit
		;;
	*)
		echo "Ooops"
		;;
	esac
done

echo "Selected this version $ndk_ver_name ($ndk_ver) to install"
echo 'Warning! This NDK only for aarch64'
cd "$install_dir" || exit
# checking if previous installed NDK and cmake

ndk_dir="$ndk_base_dir/$ndk_ver"
ndk_file_name="android-ndk-$ndk_ver_name-aarch64.zip"

if [ -d "$ndk_dir" ]; then
	echo "$ndk_dir exists. Deleting NDK $ndk_ver..."
	rm -rf "$ndk_dir"
else
	echo "NDK does not exists."
fi

if [ -d "$cmake_dir/3.10.1" ]; then
	echo "$cmake_dir/3.10.1 exists. Deleting cmake..."
	rm -rf "$cmake_dir"
fi

if [ -d "$cmake_dir/3.18.1" ]; then
	echo "$cmake_dir/3.18.1 exists. Deleting cmake..."
	rm -rf "$cmake_dir"
fi

if [ -d "$cmake_dir/3.22.1" ]; then
	echo "$cmake_dir/3.22.1 exists. Deleting cmake..."
	rm -rf "$cmake_dir"
fi

if [ -d "$cmake_dir/3.23.1" ]; then
	echo "$cmake_dir/3.23.1 exists. Deleting cmake..."
	rm -rf "$cmake_dir"
fi

# download NDK
echo "Downloading NDK $ndk_ver_name..."
wget https://github.com/jzinferno/termux-ndk/releases/download/v1/$ndk_file_name --no-verbose --show-progress -N

if [ -f "$ndk_file_name" ]; then
    echo "Unziping NDK $ndk_ver_name..."
	unzip -qq $ndk_file_name
	rm $ndk_file_name

	# moving NDK to Android SDK directory
	if [ -d "$ndk_base_dir" ]; then
		mv android-ndk-$ndk_ver_name "$ndk_dir"
	else
		echo "NDK base dir does not exists. Creating..."
		mkdir "$sdk_dir"/ndk
		mv android-ndk-$ndk_ver_name "$ndk_dir"
	fi

	# create missing link
	if [ -d "$ndk_dir" ]; then
		echo "Creating missing links..."
		cd "$ndk_dir"/toolchains/llvm/prebuilt || exit
		ln -s linux-aarch64 linux-x86_64
		cd "$ndk_dir"/prebuilt || exit
		ln -s linux-aarch64 linux-x86_64
		cd "$install_dir" || exit

		# patching cmake config
		echo "Patching cmake configs..."
		sed -i 's/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Android)\nset(ANDROID_HOST_TAG linux-aarch64)\nelseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/g' "$ndk_dir"/build/cmake/android-legacy.toolchain.cmake
		sed -i 's/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Android)\nset(ANDROID_HOST_TAG linux-aarch64)\nelseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/g' "$ndk_dir"/build/cmake/android.toolchain.cmake
		ndk_installed=true
	else
		echo "NDK does not exists."
	fi
else
	echo "$ndk_file_namep does not exists."
fi

# download cmake
echo "Downloading cmake..."
wget https://github.com/MrIkso/AndroidIDE-NDK/raw/main/cmake.zip --no-verbose --show-progress -N

# unzip cmake
if [ -f "cmake.zip" ]; then
	echo "Unziping cmake..."
	unzip -qq cmake.zip -d "$sdk_dir"
	rm cmake.zip
	# set executable permission for cmake
	chmod -R +x "$cmake_dir"/3.23.1/bin
	# add cmake to path
	# echo "Adding cmake to path..."
	# echo -e "\nPATH=\$PATH:$HOME/android-sdk/cmake/3.23.1/bin" >>"$SYSROOT"/etc/ide-environment.properties
	# create link from 3.18.1 and 3.10.2 to 3.23.1
	cd $cmake_dir
	ln -s 3.23.1 3.18.1
        ln -s 3.23.1 3.22.1
        ln -s 3.23.1 3.10.2
	cmake_installed=true
else
	echo "cmake.zip does not exists."
fi

if [[ $ndk_installed == true && $cmake_installed == true ]]; then
	echo 'Installation Finished. NDK has been installed successfully, please restart AndroidIDE!'
else
	echo 'NDK and cmake has been does not installed successfully!'
fi
