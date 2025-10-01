#!/bin/bash

# ====== CONFIGURATION ======
DB_NAME="parking_db"
DB_USER="parking_user"
DB_CONTAINER="backend-db-1"   # Change if container name is different
BACKUP_DIR="./db_backups"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$TIMESTAMP.sql"

# ====== FUNCTIONS ======
backup_db() {
    mkdir -p $BACKUP_DIR
    echo "📦 Taking backup of $DB_NAME ..."
    docker exec -t $DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME > $BACKUP_FILE
    echo "✅ Backup completed: $BACKUP_FILE"
}

restore_db() {
    if [ -z "$1" ]; then
        echo "❌ Please provide backup file path to restore"
        exit 1
    fi
    FILE=$1
    echo "📂 Restoring $DB_NAME from $FILE ..."
    
    # Create DB if not exists
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 \
    || docker exec -it $DB_CONTAINER psql -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;"

    docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME < $FILE
    echo "✅ Restore completed into $DB_NAME"
}

# ====== MAIN ======
case "$1" in
    backup)
        backup_db
        ;;
    restore)
        restore_db $2
        ;;
    *)
        echo "Usage: $0 {backup|restore <backup_file>}"
        exit 1
        ;;
esac
