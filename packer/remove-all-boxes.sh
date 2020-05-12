#!/bin/sh
vagrant box list | cut -f 1 -d ' ' | xargs -L 1 vagrant box remove -f