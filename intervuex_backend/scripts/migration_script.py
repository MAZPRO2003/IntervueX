import os
import json
import shutil
from datetime import datetime

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "app", "data")
QUESTIONS_FILE = os.path.join(DATA_DIR, "questions.json")

def migrate():
    print(f"Checking for existing questions in {QUESTIONS_FILE}")
    if os.path.exists(QUESTIONS_FILE):
        backup_file = os.path.join(DATA_DIR, f"questions_backup_{datetime.now().strftime('%Y%m%d%H%M%S')}.json")
        shutil.copy2(QUESTIONS_FILE, backup_file)
        print(f"Backed up to {backup_file}")
        
        # We wipe all generic questions to force recreation with company-specific data
        with open(QUESTIONS_FILE, "w") as f:
            json.dump({}, f)
        print("Cleared questions.json. Ready for company-specific data.")
    else:
        print("No questions.json found. Nothing to migrate.")

if __name__ == "__main__":
    migrate()
