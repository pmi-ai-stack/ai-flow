#!/bin/sh
command -v ai-flow >/dev/null 2>&1 || exit 0
exec ai-flow hook guard
