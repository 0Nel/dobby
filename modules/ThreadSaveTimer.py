#!/bin/python

import time
from threading import Lock, Thread

class ThreadSaveTimer():
    def __init__(self, timeout):
        self.lock = Lock()
        self.terminate = False
        self.timeout = timeout
        self.sleepThread = Thread(target = self.startTimer)
        self.start()

    def __del__(self):
        self.sleepThread.join()

    def start(self):
        self.sleepThread.start()
            
    def startTimer(self):
        steps = 200.0
        for sequence in range(int(steps)):
            if not self.timedOut():
                time.sleep(self.timeout/steps)
        self.stop()
    
    def stop(self):
        self.lock.acquire()
        self.terminate = True
        self.lock.release()

    def timedOut(self):
        self.lock.acquire()
        current = self.terminate
        self.lock.release()
        return current
