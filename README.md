# Scaling Infrastructure as Code on Google Cloud Platform

The Google Cloud Platform facing cloud infrastructure demo code for the Google Next '24 talk "Scaling Infrastructure as Code: Proven Strategies and Productive Workflows".

This core infrastructure serves as the main "hub" of all of the other demo projects and also hosts two services directly:

[Multiplayer Cloud Server](https://github.com/jcolemorrison/multiplayer-cloud-server)

[Multiplayer Cloud Client](https://github.com/jcolemorrison/multiplayer-cloud-client)

## Requirements

1. Either one user or service account with editor (or scoped permissions) to deploy this project.

2. An empty service account in the project to be used for the client site bucket.

3. Enabling the following APIs:
  - Compute Engine
  - Cloud Resource Manager
  - Google Cloud Memorystore for Redis
  - Google Storage