# Script al inicio de sesión para sicronizar Google Drive con directorio local

#!/bin/bash

rclone mount GDrive:/ ~/GoogleDrive --vfs-cache-mode full &
