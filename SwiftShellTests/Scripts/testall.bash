#!/usr/bin/env bash

# http://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
# Exit on any error.
set -e
# Exit on any error in a pipeline.
set -o pipefail

#./exitswhenopeningnon-existentfile.swift
./listallexecutablesinpath.swift
./print_arguments.swift 1 2
./print_environment.swift
ls | ./print_linenumbers.swift
./readfilelinebyline.swift
./stream_out.swift
./callswiftscriptfromswift.swift
