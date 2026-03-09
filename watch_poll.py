"""
Forces watchdog to use PollingObserver before mkdocs loads it.
Needed in WSL2 where inotify doesn't reliably detect file changes from VSCode.
"""
import watchdog.observers
import watchdog.observers.polling

watchdog.observers.Observer = watchdog.observers.polling.PollingObserver

import mkdocs.__main__
mkdocs.__main__.cli()
