# Ambassador iOS SDK

[View Documentation](https://github.com/GetAmbassador/documentation/blob/master/documentation/process/mobile/ios_guides.md)

## Getting Started
Install Git hooks:
```
$ ln -s ../../git-hooks/prepare-commit-msg .git/hooks/prepare-commit-msg
$ ln -s ../../git-hooks/pre-push .git/hooks/pre-push
```

The `pre-push` hook requires re-initialization of the repo:
```
$ git init
```

Make sure the `pre-push` hook is executable:
```
$ chmod +x .git/hooks/pre-push
```
