## Build and run jcstress docker

### Build
docker build -t jcstress .

### Run
docker run jcstress:latest

## Get Results?
results_file=$(docker run jcstress:latest bash -c "ls /tmp/jcstress/jcstress-results-*.bin.gz")
container_id=$(docker ps -a | grep 'jcstress:latest' | head -n1 | awk '{print $1}')
docker cp ${container_id}:${results_file} .
