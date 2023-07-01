MATLAB toolbox for network construction and analysis based on neural projections data from the Allen Brain Atlas.

## About
This toolbox can be used to compile neural projections data from the Allen Mouse Connectivity Atlas (AMCA), and construct and analyze neural networks based on this dataset. The AMCA consists of many neuroimaging experiments in mice where the monosynaptic projections are captured using a fluorescent protein expressing viral tracer. These projections are quantified using a [neuroinformatics pipeline](https://www.ncbi.nlm.nih.gov/pubmed/25536338) and published on the [AMCA website](https://connectivity.brain-map.org).

This toolbox downloads the dataset, imports it into MATLAB, normalizes the data and constructs a network based on the projections. This network represents the anatomical network of the mouse brain, with connections representing axonal densities from one brain area to another. From this network a number of properties can be computed: degree of separation, shortest path from one area to another, overall degree of connectivity of the network, etc. The toolbox also includes functions for visualization of single experiments, i.e. an overview of projections originating in a particular brain area, targeting other areas throughout the brain. Cross-hemispheric connections are shown as well.

## Installation
The toolbox can be installed by cloning this repository and running build_database.m, which will download all of the necessary files. This will take some time but ensures that the dataset is up to date, since new experiments are being added regularly. Alternatively you can download the pre-installed toolbox and dataset here: (zip file)

## Documentation
Full documentation here: [Documentation](Documentation/Documentation_v2.pdf)

## Data
Data comes from the [Allen Brain Atlas](https://brain-map.org).

Related publications:
* [A mesoscale connectome of the mouse brain](https://www.nature.com/articles/nature13186)
* [Neuroinformatics of the Allen Mouse Brain Connectivity Atlas](https://www.ncbi.nlm.nih.gov/pubmed/25536338)

## License
MIT License would be appropriate but I don't know if that checks out with MathWorks' license.

This toolbox uses third party code; JSON.m which was published on MATLAB Central and falls under the MathWorks Limited License.

https://se.mathworks.com/matlabcentral/fileexchange/42236-parse-json-text
