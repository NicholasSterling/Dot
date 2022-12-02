
export RUSTC_WRAPPER=sccache

# When I did brew install opencv,
# the QT 5 install said to add these:
export PATH="/usr/local/opt/qt/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/qt/lib"
export CPPFLAGS="-I/usr/local/opt/qt/include"
export PKG_CONFIG_PATH="/usr/local/opt/qt/lib/pkgconfig"

export RUST_BACKTRACE=1

# For MediaPipe
export GLOG_logtostderr=1

#export ANDROID_HOME=/usr/local/share/android-sdk
#export ANDROID_NDK_HOME=/usr/local/share/android-ndk
#export ANDROID_HOME=/Users/ns/Library/Android/sdk
#export ANDROID_NDK_HOME="$ANDROID_HOME/ndk"
#export ANDROID_NDK_HOME=/Users/ns/Android/Sdk/ndk-bundle/android-ndk-r19c
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_NDK_HOME=$HOME/Android/Ndk/android-ndk-r19c

export SKIM_DEFAULT_COMMAND='fd --type f'
