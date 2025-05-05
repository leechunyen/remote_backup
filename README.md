# Backup Script Guide

## Introduction
This Bash script provides a versatile solution for creating and uploading backups of MySQL databases or file paths to remote servers using multiple protocols. It supports both file and directory backups, as well as MySQL database dumps, and can transfer backups via FTP, FTPS, SFTP, or WebDAV. The script is designed for automation, with customizable backup names and secure credential handling.

Key features:
- Supports MySQL database and file/directory backups
- Multiple protocol support: FTP, FTPS, SFTP, WebDAV
- Customizable backup names with optional timestamp
- Automatic creation of destination directories
- Secure cleanup of temporary files

## Usage Guide

### Prerequisites
- **Bash environment**: The script runs on Linux/Unix systems with Bash.
- **Dependencies**:
  - `mysqldump` for MySQL backups
  - `tar` for creating compressed archives
  - `curl` for FTP, FTPS, and WebDAV uploads
  - `sftp` for SFTP uploads
- **Network access**: Ensure connectivity to the remote server and appropriate permissions.
- **Credentials**: Username and password for the remote server.

### Installation
1. Save the script to a file, e.g., `remote_backup.sh`.
2. Make it executable:
   ```bash
   chmod +x remote_backup.sh
   ```

### Command Syntax
```bash
./remote_backup.sh -t <backup_type> -s <source> -p <protocol> -u <username> -w <password> -h <host> -d <destination> [-n <name>]
```

### Options
| Option | Description | Required | Example |
|--------|-------------|----------|---------|
| `-t` | Backup type: `mysql` or `path` | Yes | `-t mysql` |
| `-s` | Source: database name (for MySQL) or file/directory path (for path) | Yes | `-s mydb` or `-s /var/www` |
| `-p` | Protocol: `ftp`, `ftps`, `sftp`, or `webdav` | Yes | `-p sftp` |
| `-u` | Username for remote server | Yes | `-u myuser` |
| `-w` | Password for remote server | Yes | `-w mypass` |
| `-h` | Host address of remote server | Yes | `-h example.com` |
| `-d` | Destination base path on remote server | Yes | `-d /backups` |
| `-n` | Custom name for backup (optional, defaults to timestamp) | No | `-n daily_backup` |

### Examples

#### MySQL Backup with SFTP
Backup a MySQL database named `mydb` and upload it to `example.com` via SFTP:
```bash
./remote_backup.sh -t mysql -s mydb -p sftp -u myuser -w mypass -h example.com -d /backups -n mysql_backup
```
This creates a compressed SQL dump (`mysql_backup_2025may12_19_03_50.tar.gz`) and uploads it to `/backups` on the remote server.

#### Directory Backup with FTP
Backup the directory `/var/www` and upload it to `example.com` via FTP:
```bash
./remote_backup.sh -t path -s /var/www -p ftp -u myuser -w mypass -h example.com -d /backups
```
This creates a compressed archive (`2025may12_19_03_50.tar.gz`) and uploads it to `/backups`.

#### File Backup with WebDAV
Backup a single file `/etc/config.conf` and upload it to `example.com` via WebDAV:
```bash
./remote_backup.sh -t path -s /etc/config.conf -p webdav -u myuser -w mypass -h https://example.com -d /backups -n config
```
This creates a compressed archive (`config_2025may12_19_03_50.tar.gz`) and uploads it to `/backups`.

### Notes
- **Security**: Avoid hardcoding passwords in scripts for production use. Consider using environment variables or a credential file.
- **Error Handling**: The script validates inputs and checks for valid backup types and protocols. Ensure the source exists and the remote server is accessible.
- **Temporary Files**: The script uses `/tmp/backup_<timestamp>` for temporary storage and cleans up after execution.
- **MySQL Access**: The script assumes `mysqldump` uses the `root` user. Modify the `create_backup` function if a different user is needed.

### Troubleshooting
- **Permission Errors**: Ensure the user running the script has access to the source and temporary directory.
- **Connection Issues**: Verify the host, username, password, and protocol. Check firewall settings.
- **Missing Dependencies**: Install `mysqldump`, `tar`, `curl`, or `sftp` if not present.
- **Invalid Source**: Confirm the database name or file/directory path exists.

### Automation
To run the script automatically, use a cron job. Example for daily MySQL backups at 2 AM:
```bash
0 2 * * * /path/to/remote_backup.sh -t mysql -s mydb -p sftp -u myuser -w mypass -h example.com -d /backups -n daily
```

This guide provides a comprehensive overview of the backup script's functionality and usage. For further customization, refer to the script's source code.