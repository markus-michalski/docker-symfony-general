#!/usr/bin/env bash
set -e

echo "Restart ssh server"
/etc/init.d/ssh restart

CONTAINER_FIRST_STARTUP="CONTAINER_FIRST_STARTUP"
if [ ! -e /$CONTAINER_FIRST_STARTUP ];
then
    touch /$CONTAINER_FIRST_STARTUP
    symfony new . --version="7.1.*"
fi


echo "#####################################"
echo "###### Docker setup completed! ######"
echo "#####################################"

exec "$@"