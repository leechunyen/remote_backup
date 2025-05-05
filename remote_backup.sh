#!/bin/bash

# Backup script supporting multiple protocols and backup types (mysql or path)
# Usage: ./backup.sh [options]

# Function to display usage
usage() {
    echo "Usage: $0 -t <backup_type> -s <source> -p <protocol> -u <username> -w <password> -h <host> -d <destination> [-n <name>]"
    echo "  -t: Backup type (mysql/path)"
    echo "  -s: Source path or database name"
    echo "  -p: Protocol (ftp/ftps/sftp/webdav)"
    echo "  -u: Username for remote server"
    echo "  -w: Password for remote server"
    echo "  -h: Host address"
    echo "  -d: Destination base path"
    echo "  -n: Custom name for backup (optional, default: timestamp)"
    exit 1
}

# Parse command line arguments
while getopts "t:s:p:u:w:h:d:n:" opt; do
    case $opt in
        t) BACKUP_TYPE="$OPTARG";;
        s) SOURCE="$OPTARG";;
        p) PROTOCOL="$OPTARG";;
        u) USERNAME="$OPTARG";;
        w) PASSWORD="$OPTARG";;
        h) HOST="$OPTARG";;
        d) DEST_PATH="$OPTARG";;
        n) CUSTOM_NAME="$OPTARG";;
        *) usage;;
    esac
done

# Validate required arguments
if [ -z "$BACKUP_TYPE" ] || [ -z "$SOURCE" ] || [ -z "$PROTOCOL" ] || [ -z "$USERNAME" ] || [ -z "$HOST" ] || [ -z "$DEST_PATH" ]; then
    usage
fi

# Set timestamp format (2025may12_19_03_50)
TIMESTAMP=$(date +%Y%h%d_%H_%M_%S)

# Set backup name
if [ -z "$CUSTOM_NAME" ]; then
    BACKUP_NAME="$TIMESTAMP"
else
    BACKUP_NAME="${CUSTOM_NAME}_${TIMESTAMP}"
fi

# Temporary directory for backup
TEMP_DIR="/tmp/backup_$(date +%s)"
mkdir -p "$TEMP_DIR"

# Function to create backup
create_backup() {
    case $BACKUP_TYPE in
        mysql)
            mysqldump -u root "$SOURCE" > "$TEMP_DIR/backup.sql"
            tar -czf "$TEMP_DIR/${BACKUP_NAME}.tar.gz" -C "$TEMP_DIR" backup.sql
            ;;
        path)
            if [ -f "$SOURCE" ]; then
                # Source is a file
                tar -czf "$TEMP_DIR/${BACKUP_NAME}.tar.gz" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"
            elif [ -d "$SOURCE" ]; then
                # Source is a directory
                tar -czf "$TEMP_DIR/${BACKUP_NAME}.tar.gz" -C "$SOURCE" .
            else
                echo "Error: Path $SOURCE does not exist"
                exit 1
            fi
            ;;
        *)
            echo "Invalid backup type"
            exit 1
            ;;
    esac
}

# Function to upload backup
upload_backup() {
    case $PROTOCOL in
        ftp)
            curl -T "$TEMP_DIR/${BACKUP_NAME}.tar.gz" -u "$USERNAME:$PASSWORD" "ftp://$HOST/$DEST_PATH/"
            ;;
        ftps)
            curl --ftp-ssl -T "$TEMP_DIR/${BACKUP_NAME}.tar.gz" -u "$USERNAME:$PASSWORD" "ftp://$HOST/$DEST_PATH/"
            ;;
        sftp)
            echo "put $TEMP_DIR/${BACKUP_NAME}.tar.gz $DEST_PATH/" | sftp "$USERNAME@$HOST"
            ;;
        webdav)
            curl -u "$USERNAME:$PASSWORD" -T "$TEMP_DIR/${BACKUP_NAME}.tar.gz" "$HOST/$DEST_PATH/"
            ;;
        *)
            echo "Invalid protocol"
            exit 1
            ;;
    esac
}

# Create destination directory if it doesn't exist
case $PROTOCOL in
    ftp|ftps)
        curl -u "$USERNAME:$PASSWORD" --ftp-create-dirs -Q "MKD $DEST_PATH" "ftp://$HOST/"
        ;;
    sftp)
        echo "mkdir $DEST_PATH" | sftp "$USERNAME@$HOST"
        ;;
    webdav)
        curl -u "$USERNAME:$PASSWORD" -X MKCOL "$HOST/$DEST_PATH/"
        ;;
esac

# Main execution
create_backup
upload_backup

# Cleanup
rm -rf "$TEMP_DIR"

echo "Backup done: ${BACKUP_NAME}.tar.gz"