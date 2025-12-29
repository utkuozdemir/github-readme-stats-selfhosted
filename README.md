# github-readme-stats-selfhosted

This is a Docker image for self-hosting the [github-readme-stats](https://github.com/anuraghazra/github-readme-stats) project.

## Why?

The original [github-readme-stats](https://github.com/anuraghazra/github-readme-stats) is built to run on Vercel. While there is a public instance available,
it can experience downtime or rate limiting. I created this project to allow users to easily host their own instance using Docker.

There are other Docker images available for this purpose, but they often bundle the application code inside the image.
This means they become outdated as soon as the upstream project is updated.

This project works differently. It downloads the latest code from the official repository every time the container starts.
This ensures your instance is always running the most recent version without needing to pull a new Docker image.

## Prerequisites

You need at least one GitHub Personal Access Token (PAT).

Refer to the upstream documentation to [generate your Personal Access Token](https://github.com/anuraghazra/github-readme-stats?tab=readme-ov-file#first-step-get-your-personal-access-token-pat).

## Usage

### Running in Docker

Run the following command (replace `your_token_here` with your token and `your_username` with your GitHub username):

```bash
TAG=latest # consider using a tagged release instead of latest
docker run -d \
  --name readme-stats \
  -p 9000:9000 \
  -e PAT_1=your_token_here \
  -e WHITELIST=your_username \
  ghcr.io/utkuozdemir/github-readme-stats-selfhosted:$TAG
```

Once running, you can access the stats at:
`http://localhost:9000/api?username=your_username`

### Docker Compose

This repository includes a [`docker-compose.yml`](./docker-compose.yml) file.

1. Open `docker-compose.yml`.
2. Replace `your_github_pat_here` with your actual token.
3. Add `WHITELIST=your_username` to the environment section (strongly recommended).
4. Run the container:

```bash
docker compose up -d
```

### Running on Kubernetes

For Kubernetes, we recommend using the [bjw-s app-template](https://github.com/bjw-s-labs/helm-charts/tree/main/charts/other/app-template) Helm chart.
You can find the full documentation for the chart [here](https://bjw-s-labs.github.io/helm-charts/docs/app-template/).

1. Add the Helm repository:
   ```bash
   helm repo add bjw-s https://bjw-s.github.io/helm-charts
   helm repo update
   ```

2. Create a Kubernetes Secret for your PAT(s):

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: readme-stats-secret
   type: Opaque
   stringData:
     PAT_1: "your_github_pat_here"
   ```

   Apply it: `kubectl apply -f secret.yaml`

3. Create a `values.yaml` file:

   ```yaml
   controllers:
     main:
       containers:
         main:
           image:
             repository: ghcr.io/utkuozdemir/github-readme-stats-selfhosted
             tag: latest # consider using a tagged release instead of latest
           envFrom:
             - secretRef:
                 name: readme-stats-secret
           env:
             # Strongly Recommended: Prevent abuse by allowing only specific users
             WHITELIST: your_username
             
             # Optional: Configure other variables
             # GITHUB_README_STATS_REF: master
             # CACHE_SECONDS: 7200

   service:
     main:
       ports:
         http:
           port: 9000
   ```

4. Install the chart:
   ```bash
   helm install readme-stats bjw-s/app-template -f values.yaml
   ```

## Configuration

You can configure the container using environment variables.

| Variable                   | Description                                                                                                                              | Default                                                  |
|:---------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------------------------|
| `PAT_1`                    | **Required.** Your GitHub Personal Access Token. You can add `PAT_2`, `PAT_3`, etc., to increase your rate limit.                        | None                                                     |
| `WHITELIST`                | **Strongly Recommended.** Comma-separated list of usernames allowed to use the instance. Set this to your own username to prevent abuse. | `null` (Open to everyone)                                |
| `GITHUB_README_STATS_REPO` | The git repository URL to clone.                                                                                                         | `https://github.com/anuraghazra/github-readme-stats.git` |
| `GITHUB_README_STATS_REF`  | The branch, tag, or commit hash to use.                                                                                                  | `master`                                                 |
| `FIX_AUDIT`                | Run `npm audit fix` before starting the server.                                                                                          | `true`                                                   |
| `PORT`                     | The internal port the Node server listens on.                                                                                            | `9000`                                                   |

### Locking the version

By default, the container uses the `master` branch. To lock the version to a specific commit or tag, set the `GITHUB_README_STATS_REF` variable.

```yaml
environment:
  - PAT_1=your_token
  # Example: Lock to a specific commit hash or to a tag
  - GITHUB_README_STATS_REF=8994937bd139cd43b6ec431229f009f1e5204d3d
```
