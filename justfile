set shell := ["zsh", "-lc"]

default:
    @just --list

xcode-open:
    open ios/Offload.xcodeproj

build:
    xcodebuild -project ios/Offload.xcodeproj -scheme Offload -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath .derivedData/xcodebuild build

test:
    xcodebuild -project ios/Offload.xcodeproj -scheme Offload -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath .derivedData/xcodebuild test

lint-docs:
    markdownlint --fix .

lint-yaml:
    yamllint .

lint: lint-docs lint-yaml
