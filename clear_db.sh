#!/bin/bash

echo "=========================================="
echo "Clearing Local Database..."
echo "=========================================="

# macOS database location
DB_PATH="$HOME/Library/Containers/com.example.xpress/Data/Library/Application Support/com.example.xpress/databases/"

if [ -d "$DB_PATH" ]; then
    echo "Found database directory: $DB_PATH"
    rm -f "${DB_PATH}dbresto30.db"
    rm -f "${DB_PATH}dbresto30.db-shm"
    rm -f "${DB_PATH}dbresto30.db-wal"
    echo "✅ Database files deleted!"
else
    echo "⚠️  Database directory not found"
    echo "Searching for database files..."
    find ~/Library -name "dbresto30.db" 2>/dev/null
fi

echo "=========================================="
echo "Done! Now restart your app."
echo "=========================================="

