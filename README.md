# Building

## Prerequisites

1. Xcode 8
1. [~/Projects/textmate](https://github.com/textmate/textmate)

## Bootstrap

First, build the XPC Service:

```
cd ~/Projects/textmate
git fetch origin syntax-mate && git checkout syntax-mate && git pull
./configure && ninja SyntaxMate
```

Next, open `.xcodeproj`, Build and Run.
