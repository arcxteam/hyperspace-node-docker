# Run Hyperspace AI Node based-on Docker
 
HyperspaceAI is building a browser-based blockchain supercomputer designed to provide users with secure, controllable AI applications.

## Joining Steps  
### 1. Visit the Official Website  
First, open your browser and visit the following URL:  
[http://node.hyper.space](http://node.hyper.space)

GitHub: [http://github.com/hyperspaceai](http://github.com/hyperspaceai)

### 2. Activate the Node  
1. Select the model at arrow 1. Then, find and toggle the red switch at arrow 2. After this action, a message will pop up: "Allocated and ready to accept challenges." The system will automatically configure the settings. Please be patient for a few minutes until the configuration is complete.  

![Node-Web-by-hyperspace-01-23-2025_02_31_AM](https://github.com/user-attachments/assets/0925c02d-e3c1-45b5-a496-c363971fb787)

2. You can choose one of the following two methods to run your node:  
   - **Using Browser:** Run the node directly in the browser without downloading any additional software.  
   - **Download the Hyperspace Application:** If you prefer using a dedicated app, you can download and install the Hyperspace app.

### 3. Increase Activity  
To ensure your node stays active and earns a higher score, make sure to follow these points:  
- **Stay Online:** The node needs to remain online to process network requests and challenges. This will directly impact your activity score.  
- **Complete All Activities:** Regularly check and complete the activities required by the platform to maintain and improve your node's score.  

**Note:** This project has high RAM and computational resource demands, relying on users to share their RAM for data processing. If your device has low performance, please participate cautiously to avoid affecting the device's operation.

---

## Linux CLI Node (VPS)

### System Requirements  
**Minimum Configuration:**  
- 4GB RAM, 2 Virtual CPUs  

**Recommended Configuration:**  
- 8GB RAM, 4 Virtual CPUs  

### Running with Docker:  
**One-click script:**  
```bash
curl -O https://raw.githubusercontent.com/arcxteam/hyperspace-node-docker/refs/heads/main/aios-install.sh && chmod +x aios-install.sh && ./aios-install.sh
```  
Just follow the prompt to input your private key.

### Useful Commands

**View logs:**  
```bash
docker logs -f aios-container
```

**Check points:**  
```bash
docker exec -it aios-container /app/aios-cli hive points
```

**View private key:**  
```bash
docker exec -it aios-container /app/aios-cli hive whoami
```

### STOP & DELETE for HyperspaceAI

**Stop the Docker container:**  
```bash
docker stop aios-container
```

**Delete the Docker container:**  
```bash
docker rm aios-container
```

**Delete the Docker image:**  
```bash
docker rmi kartikhyper/aios
```
