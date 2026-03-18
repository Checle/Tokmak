#!/bin/bash

set -eux

swift build -c release --product TokmakCoreBenchmark
ls -lh ./.build/release/TokmakCoreBenchmark | awk '{printf  "::warning file=Sources/TokmakCoreBenchmark/main.swift,line=1,col=1::TokmakCoreBenchmark is %s.",$5}'
./.build/release/TokmakCoreBenchmark
swift build -c release --product TokmakStaticHTMLBenchmark
ls -lh ./.build/release/TokmakStaticHTMLBenchmark | awk '{printf  "::warning file=Sources/TokmakStaticHTMLBenchmark/main.swift,line=1,col=1::TokmakStaticHTMLBenchmark is %s.",$5}'
./.build/release/TokmakStaticHTMLBenchmark
