import subprocess
import time
import threading
import os

class M2Controller:
    _instance = None
    
    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def __init__(self):
        # Invoking bash -lc ensures the WSL environment loads necessary PATH variables
        self.process = subprocess.Popen(
            ["wsl", "bash", "-lc", "M2 --no-readline --quiet"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )
        self.initialized = False
        self.lock = threading.Lock()
        
        # Allow WSL a moment to initialize and verify the process remains active
        time.sleep(1.0)
        if self.process.poll() is not None:
            error_log = self.process.stderr.read()
            print(f"CRITICAL ERROR: M2 Boot Failure. Output:\n{error_log}")

    def run_script(self, script_path):
        with self.lock:
            if self.process.poll() is not None:
                print("Error: The background M2 process has terminated unexpectedly.")
                return

            cmd = f'load "{script_path}"'
            self.process.stdin.write(cmd + '\n')
            self.process.stdin.flush()
            
            delimiter = "---M2_EXECUTION_COMPLETE---"
            self.process.stdin.write(f'print "{delimiter}"\n')
            self.process.stdin.flush()
            
            while True:
                line = self.process.stdout.readline()
                if delimiter in line or not line:
                    break