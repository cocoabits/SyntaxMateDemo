# Building

## Prerequisites

1. Xcode 8
1. [~/Projects/textmate](https://github.com/textmate/textmate)

## Bootstrap

First, build the XPC Service:

```
cd ~/Projects/textmate
git fetch origin master && git checkout master && git pull
./configure && ninja SyntaxMate
open ~/build/TextMate/Applications/SyntaxMate/
```

Next, open `SyntaxMateDemo.xcodeproj`, Build and Run.
