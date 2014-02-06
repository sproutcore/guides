#!/bin/bash
rm -rf out/ && rm .docpad.db && docpad generate -e production && rsync -av out/ ../sproutcore-guides.github.com
