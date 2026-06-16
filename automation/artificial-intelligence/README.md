# Ollama + Open WebUI

This setup allows you to run large language models (LLMs) locally using Ollama and interact with them through a user-friendly web interface provided by Open WebUI.

## Services

-   **Ollama**: Serves and manages LLMs locally.
-   **Open WebUI**: A web interface for interacting with Ollama-served models.

## Configuration

1.  **GPU Acceleration (Optional but Recommended)**: The `ollama` service is configured to use NVIDIA GPUs (`deploy.resources.reservations.devices`). Ensure you have the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) installed on your host if you want to use GPU acceleration. If you don't have an NVIDIA GPU or don't want to use it, remove or comment out the `deploy` section in `docker-compose.yml`.
2.  **Port Mapping**: Open WebUI is mapped to port `3000` on the host by default (`3000:8080`). You can change the host port if needed.
3.  **Models Directory (Optional)**: To use custom models, set the `MODELS_DIR` environment variable in `.env.example` to point to your models directory. This allows you to mount a local directory containing your models into the Ollama container.
4.  **WebUI Secret Key (Optional)**: For production environments, it's recommended to set the `WEBUI_SECRET_KEY` environment variable for the `open-webui` service to a secure, random string.

## Custom Models

To use custom models from your local directory, you can create them using the Modelfile:

```bash
docker exec -it ollama sh
ollama create custom-model-name -f /models/path/to/Modelfile
```

> **Note**: Since the docker volume mounts the models directory to `/models` inside the container, the path in the command should be the absolute path _inside_ the container (e.g. `/models/gpt-oss/Modelfle`)
