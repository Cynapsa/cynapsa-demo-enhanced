#!/bin/sh
cd /opt/cynapsa-enhanced/client || exit 1
printf '\nClient is stopped. Start it when ready:\n  ./run.sh\n\n'
exec /bin/bash -i
