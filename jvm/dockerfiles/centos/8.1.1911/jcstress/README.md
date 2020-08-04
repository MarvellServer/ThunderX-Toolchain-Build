## Build and run jcstress docker

### Build
docker build -t jcstress .

### Run
 docker run -t --name jcstress-devtest -v "$(pwd)"/target:/app jcstress:latest


## Get Results?
 Results in ./target
