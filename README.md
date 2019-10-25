# seattle-nwmls-joiner

Joiner component for listings infra

## Docker Image  
This image builds a Flink job cluster which can be used to run single job. The job is part of the image and, thus, there is no extra job submission needed.
Image is based on the official Java Alpine (OpenJDK 8) image. Flink version and jar that needs to be run can be provided as part of the build process.

### Build Docker image  
An image can be built using "build.sh" script. We need to build code jar before building the image.

**Options:**  
*--job-artifacts*: pass absolute path of the jar that needs to be run  
*--from-archive*: provide absolute path of flink archive. Although code supports other ways of getting flink, building from archive is preferred as the plan is to keep these archives in Artifactory. 

**Example:**  
```bash
./build.sh --job-artifacts "/Users/rkandoji/Documents/GitProjects/flink-joiner/target/scala-2.11/flink-joiner-assembly-0.1-SNAPSHOT.jar" --from-archive "/Users/rkandoji/Documents/flink-1.8.1-bin-scala_2.11.tgz"
```

### Deploying cluster and running the job

It can be deployed using docker-compose by providing below variables:  
*FLINK_DOCKER_IMAGE_NAME* - Image name to use for the deployment (default: flink-job:latest)  
*FLINK_JOB* - Name of the Flink job to execute

**Example:**  
```
FLINK_DOCKER_IMAGE_NAME=flink-job:latest FLINK_JOB=com.urbancompass.data.pipeline.flink.CRMLSJoiner docker-compose up
```

### Kill the cluster  
```
docker-compose kill
```

**Note:**   
Docker build script and docker-compose has more options than what I mentioned here, but the above options should be sufficient to get started.

### References:  
https://github.com/apache/flink/tree/release-1.9/flink-container/docker 
