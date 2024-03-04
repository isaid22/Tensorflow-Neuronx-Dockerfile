# Tensorflow-Neuronx-Dockerfile
Describe how to build a docker container that serves TF Serving on Neuron device


Command to build the image from dockerfile:
```
docker build . -f Dockerfile -t tfnx210-tfs.v2
```

Once it's built, then run it:

```
docker run -it --net=host --device=/dev/neuron0 --device=/dev/neuron1 --device=/dev/neuron2 tfnx210-tfs.v2:latest
```