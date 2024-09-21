rm run.log
./ci/blackbox.sh --driver=rtlsim --clusters=1 --cores=1 --threads=1 --warps=3 --app=vecadd --debug=0 &
PID=$!
sleep 1
kill $PID
#CONFIGS="-DSOCKET_SIZE=1" 
#./ci/blackbox.sh --driver=rtlsim --clusters=1 --cores=2 --threads=2 --warps=1 --app=vecadd --debug=0
#./ci/blackbox.sh --driver=rtlsim --cores=2 --clusters=2 --l3cache --app=diverge --args="-n1"

# 2 core --mesh
CONFIGS="-DSOCKET_SIZE=1" ./ci/blackbox.sh --driver=rtlsim --cores=4 --l2cache --app=diverge --args="-n1" --debug=1
# 1 core
#./ci/blackbox.sh --driver=rtlsim --cores=2 --l2cache --app=diverge --args="-n1" --debug=1
