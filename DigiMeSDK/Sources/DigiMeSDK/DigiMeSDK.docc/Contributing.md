# Contributing

We are open to, and grateful for, any contributions made by the community. When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

## Code of Conduct

We have adopted the [Contributor Covenant](https://www.contributor-covenant.org/) as our Code of Conduct, and we expect project participants to adhere to it.
Please read the full text so that you can understand what actions will and will not be tolerated.

### Our Pledge

In the interest of fostering an open and welcoming environment, we as
contributors and maintainers pledge to making participation in our project and
our community a harassment-free experience for everyone, regardless of age, body
size, disability, ethnicity, gender identity and expression, level of experience,
nationality, personal appearance, race, religion, or sexual identity and
orientation.

### Our Standards

Examples of behavior that contributes to creating a positive environment include:

* Using welcoming and inclusive language
* Being respectful of differing viewpoints and experiences
* Gracefully accepting constructive criticism
* Focusing on what is best for the community
* Showing empathy towards other community members

Examples of unacceptable behavior by participants include:

* The use of sexualized language or imagery and unwelcome sexual attention or
advances
* Trolling, insulting/derogatory comments, and personal or political attacks
* Public or private harassment
* Publishing others' private information, such as a physical or electronic
  address, without explicit permission
* Other conduct which could reasonably be considered inappropriate in a
  professional setting

### Our Responsibilities

Project maintainers are responsible for clarifying the standards of acceptable
behavior and are expected to take appropriate and fair corrective action in
response to any instances of unacceptable behavior.

Project maintainers have the right and responsibility to remove, edit, or
reject comments, commits, code, wiki edits, issues, and other contributions
that are not aligned to this Code of Conduct, or to ban temporarily or
permanently any contributor for other behaviors that they deem inappropriate,
threatening, offensive, or harmful.

### Scope

This Code of Conduct applies both within project spaces and in public spaces
when an individual is representing the project or its community. Examples of
representing a project or community include using an official project e-mail
address, posting via an official social media account, or acting as an appointed
representative at an online or offline event. Representation of a project may be
further defined and clarified by project maintainers.

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be
reported by contacting the project team at support@digi.me. All
complaints will be reviewed and investigated and will result in a response that
is deemed necessary and appropriate to the circumstances. The project team is
obligated to maintain confidentiality with regard to the reporter of an incident.
Further details of specific enforcement policies may be posted separately.

Project maintainers who do not follow or enforce the Code of Conduct in good
faith may face temporary or permanent repercussions as determined by other
members of the project's leadership.

## Open Development
All work on our SDK happens directly on Github. Core team members and external contributors send pull requests which go through the same review process.

## Semantic Versioning
Our SDK follows semantic versioning. Patch versions are reserved for bug fixes, minor versions for new features and major version for any breaking changes.

## Branch Organisation
Please submit all changes directly to the master branch. We do our best to keep master in good shape, with all tests passing. Master could potentially have breaking changes to your application if we're working on the next major release.

## Workflow and Pull Requests
For non-trivial changes, please open an issue with a proposal for a new feature or refactoring before starting on the work. We don't want you to waste your efforts on a pull request that we won't want to accept. The core team will be monitoring for all pull requests. We require that tests to be included with your pull requests if you've added code that should be tested. Two approvers are needed before code can be merged.

## Development
To start working on the SDK, fork, then clone the repo:

`git clone https://www.github.com/<your_username>/digime-sdk-ios.git`

#### Installation

### Cocoapods

1. Add `DigiMeSDK` folder to root of your project folder.

2. Add `DigiMeSDK` to your `Podfile`:

```ruby
use_frameworks!
platform :ios, '13.0'

target 'TargetName' do
  pod 'DigiMeSDK', :path => '../'
end
```
> NOTE
> We do not currently support linking DigiMeSDK as a Static Library.
>
> **use_frameworks!** flag must be set in the Podfile

3. Navigate to the directory of your `Podfile` and run the following command:

```bash
	$ pod install --repo-update
```

## License
By contributing to our SDK, you agree that your contributions will be licensed under its Apache 2.0 license.
