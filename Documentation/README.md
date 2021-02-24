#SDK Documentation Guide

To generate documentation, simply run the `generate_documentation` script from this directory.
This uses `jazzy` tool.

##SDK Code Documentation

At present, `jazzy` cannot generate both Swift and Objective-C documentation directly. Therefore intermediate Swift and Objective-C docs need to be generated independently use `sourcekitten`.

To help it determine which Objective-C headers to parse for documentation, there is a `SDKHeaders.h` file which includes paths to all the headers we want to document. Please update this file if you need to include additional headers.

Our SDK contains a mixture of Swift and Objective-C. As a consequence, all Swift files that are accessed by Objective-C files have to be made `public` (even though they would ideally be `internal`).
Unfortunately this means that the Swift classes that should be `internal` are included in our documentation.

##SDK Guides (.md) Documentation

All SDK markdown guides can be found in `./guides/`