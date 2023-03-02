# Writing And Reading Raw Data

digi.me prides itself in normalizing data from a huge array of sources into common ontologies, however, as a data portability facilitator, we support the flow of data in both directions - from the user to you, and from you back to the user.

To differentiate these types of data, we refer to these as follows:

* Data sources from external services, which is then normalized into differnet ontologies is referred to as **mapped** data.
* Data written to a user's digi.me via this SDK is referred to as **raw data**.

The digi.me Private Sharing SDK makes it easy to write data to a user's digi.me and read it back again.

## Writing Raw Data

Before data can be written, you should already have credentials for this user.  If you don't have any, you will need to authorize the user first. Make sure the contract used is a **WRITE** contract.

To write the data, you need to build a `metadata` object that describes what data your pushing along with the `Data` representation of your data itself.

```swift
// Obtain the data you wish to post.
let data: Data = ...

// All push submissions must be pushed with appropriate metadata. The following is taken from one of the example apps.
let metadata = RawFileMetadataBuilder(mimeType: .applicationJson, accounts: ["Account1"])
                .objectTypes([.init(name: "receipt")])
                .tags(["groceries"])
                .reference(["Receipt \(dateFormatter.string(from: Date()))"])
                .build()

let credentials = my_stored_credentials
digiMe.write(data: data, metadata: metadata, credentials: credentials) { result in
  switch result {
    case .success(let refreshedCredentials):
        // Update your stored credentials as these may have changed
        
    case .failure(let error):
        // Handle failure
    }
}
```


## Reading Raw Data

In order to read data which you have written to user's digi.me you will need a separate **READ** contract configured to read raw data. Please [contact support](https://developers.digi.me/contact-us) to discuss this.

Reading raw data is similar to reading mapped data, in that you will need to authorize the user with this contract.  The only difference is that to access the same data space that your write contract has written to, you will also need to pass the credentials for you write contract.  This is because, by default, authorizing a contract creates a new data space - only by linking another contract will those contracts access the same data space.

You will also need to create a separate digi.me instance configured with your read contract.

```swift
let writeCredentials = my_write_credentials

readDigiMe.authorize(linkToContractWithCredentials: writeCredentials) { result in
    switch result {
    case .success(let credentials):
        // Store these credentials for your read contract
        
    case.failure(let error):
        // Handle failure    }
}
```

Now you are ready to read the data you have written:

```swift
let credentials = my_stored_read_credentials
readDigiMe.readAllFiles(credentials: credentials, readOptions: nil) { result in
	switch result {
   	case .success(let file):
        // Access data or metadata of file.
        
   case .failure(let error):
       // Handle Error
   }
} completion: { result in
    switch result {
    case .success(let (fileList, refreshedCredentials)):
        // Handle success and update stored credentials as these may have been refreshed.
    case .failure(let error):
        // Handle failure.
    }
}
```

The returned file's `metadata` will be a `raw` type containing the actual metadata accompanying the data when it was written.

*NB: Please refer to our Read/Write example in the [Example App](https://github.com/digime/digime-sdk-ios/tree/master/Examples/DigiMeSDKExample) for a working example of this.*
