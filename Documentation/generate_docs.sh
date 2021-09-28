# Due to jazzy using xcodebuild to build Swift package, it needs to be run from directory where Swift package is located. This is where the config file `.jazzy.yaml` is also located
cd ..
jazzy
# Remove generated docset as we don't need it
rm -rf docsets
