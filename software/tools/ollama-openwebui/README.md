# Ollama + Open WebUI

This setup allows you to run large language models (LLMs) locally using Ollama and interact with them through a user-friendly web interface provided by Open WebUI.

## Services

-   **Ollama**: Serves and manages LLMs locally.
-   **Open WebUI**: A web interface for interacting with Ollama-served models.

## Configuration

1.  **GPU Acceleration (Optional but Recommended)**: The `ollama` service is configured to use NVIDIA GPUs (`deploy.resources.reservations.devices`). Ensure you have the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) installed on your host if you want to use GPU acceleration. If you don't have an NVIDIA GPU or don't want to use it, remove or comment out the `deploy` section in `docker-compose.yml`.
2.  **Port Mapping**: Open WebUI is mapped to port `3000` on the host by default (`3000:8080`). You can change the host port if needed.
3.  **WebUI Secret Key (Optional)**: For production environments, it's recommended to set the `WEBUI_SECRET_KEY` environment variable for the `open-webui` service to a secure, random string.

## Usage

1.  Access Open WebUI in your browser.
2.  You will need to pull models into Ollama before you can use them. This can often be done directly through the Open WebUI interface, or by exec-ing into the Ollama container:
    ```bash
    docker exec -it ollama ollama pull <model_name> 
    # Example: docker exec -it ollama ollama pull llama3
    ```
 