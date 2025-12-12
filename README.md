# Setup

Run
```
docker build -t cxlmc
```
at the top-level directory where `Dockerfile` is located, and then run
```
docker run -it --rm cxlmc bash
```
to run a bash session inside the container.

Note that the docker image may take up to 1 hour to build

# Experiment Workflow

At the default directory of the docker container, run the script 
```
./run_bugs.sh
```
to find bugs with CXLMC in each benchmark, and run 
```
./run_perf.sh
```
to measure CXLMC's performance on each benchmark.
