# DevOps-Heroes

This repository provides a ready-to-use docker-compose.yml for running a GitLab CE server and a GitLab Runner.

## Initial setup:

1. Replace the domain

    Replace all occurrences of `gitlab.devops-heroes.com` in this repository with your own domain.

2. Ensure your domain is reachable
    
    Verify that your domain is accessible (e.g. via ping).
    
    **Note**: If your domain is not public or does not exist, you need to manually register it in your hosts file.

    ```
    In Windows: C:\Windows\System32\drivers\etc\hosts
    In Linux / Mac: /etc/hosts
    ```

    Example of host resolution entry:
    ```
    127.0.0.1	gitlab.devops-heroes.com
    ```

3. Start the services

    Ensure Docker and Docker Compose are installed, then run:
    
    > docker-compose up -d --force-recreate --remove-orphans

4. Once the job "certificate_authority" is completed, retrieve the "ca.crt" from its volume and install it in the trusted certificate authorities of your personal computer.

## Gitlab Setup & Administration

1. Log in

    A few minutes after starting the services, the login page will be available.

    > Username: root
    
    > Password: found in `./volumes/gitlab/secrets/root_password.txt`

2. Create a new administrator user

    After logging in, it's recommended to create a new administrator user.

    > Go to https://gitlab.devops-heroes.com/admin/users.

    > Click "New User" and fill in the details.

    > Ensure the Administrator role is selected.

    > Click "Create user", then click "Edit" to set a new password for your administrator account.

3. Create a new project group

    > Go to https://gitlab.devops-heroes.com/groups/new

    > Click "Create group"

    > Choose a name for the group

    > Click "Create group"

4. Create a new project

    > Go to https://gitlab.devops-heroes.com/projects/new

    > Click "Create blank project"

    > Choose a project name

    > Select the project owner (either a group or a user)

5. Register a new Gitlab runner

    You have three options for registering a GitLab Runner:

    1. Create a Global instance runner:
    
        > Go to https://gitlab.devops-heroes.com/admin/runners

        > Click "New instance runner"

    2. Create a Group instance runner:

        > Go to https://gitlab.devops-heroes.com/dashboard/groups

        > Select your project group

        > Navigate to Settings > CI/CD

        > Ensure instance runners are enabled for this group

        > Navigate to Build > Runners

        > Click "New group runner"

    3. Create a Project instance runner:

        > Open your project

        > Navigate to Settings > CI/CD

        > Expand Runners and click "New project runner"

    ### Runner Setup Steps
    Once on the "New Runner" page:
    > Leave the "Tags" field empty

    > Enable "Run untagged jobs"

    Then:

    > Click "Create runner"

    > Copy the command provided in Step 1 and paste it into the Exec tab of the GitLab Runner container in Docker Desktop (or execute it via Docker CLI).

    > Confirm your domain name

    > Enter a name for your runner

    > Select an executor. If you plan to use the runner for DIND (Docker-in-Docker), choose "docker".

    > Select the default Docker image. If using DIND, choose "docker"

   **Note**: If you choose to use DIND, update the "network_mode" and the "volumes" configuration in `./volumes/gitlab-runner/config/runner-config.toml` with the following:

    ```
    tls_verify = true
    network_mode = "devops-heroes_gitlab"
    volumes = [
        "/var/run/docker.sock:/var/run/docker.sock", 
        "/cache",
        "devops-heroes_certificates:/etc/gitlab-runner/certs:ro"
    ]
    ```