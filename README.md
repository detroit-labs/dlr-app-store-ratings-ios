# DLRAppStoreRatings

This is a <b>internal</b> CocoaPod.

## Installation

To install it, simply add the following line to your Podfile:

```rb
source 'git://git@github.com:detroit-labs/detroit-labs-specs.git'
source 'git://git@github.com:CocoaPods/Specs.git'

pod 'DLRAppStoreRatings'
```

If this command fails with the message below, check that you have [added your ssh key to GitHub](https://help.github.com/articles/generating-ssh-keys/):

```sh
Pre-downloading: `DetroitLabsRecipes` from `git@github.com:detroit-labs/detroit-labs-recipes-ios.git`, tag `v0.4.0`
[!] /usr/local/bin/git clone git@github.com:detroit-labs/detroit-labs-recipes-ios.git /path/to/local/repo/myrepo/Pods/DetroitLabsRecipes --single-branch --depth 1 --branch v0.4.0

Cloning into '/path/to/local/repo/myrepo/Pods/DetroitLabsRecipes'...

Permission denied (publickey).
```

If you are asked for your username & password and your GitHub account is 2-factor auth enabled, you may need to [authenticate using an access token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/).

## Contributing

After a PR has merged and the version number bumped, push the podspec to the detroit-labs repo:

```pod repo push detroit-labs```

## Author

- Chris Trevarthen, ctrevarthen@detroitlabs.com
- Nathan Walczak, nate.walczak@detroitlabs.com

## Examples
