# The health of the container is determined by whether Apache is running.
supervisorctl status apache2 | grep -q RUNNING
if [ $? -eq 0 ]
then
    exit 0
else
    exit 1
fi
