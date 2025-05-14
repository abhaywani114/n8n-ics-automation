## 🛠 n8n ICS Calendar Merger
This project sets up a self-hosted n8n instance and builds a workflow to merge future events from a remote .ics calendar into a local calendar.ics file.

## ❗ Problem Statement
Manually maintaining calendar files by merging bookings from multiple sources. In this task, the goal is to automate the process using a self-hosted n8n workflow that:

- Fetches a remote .ics calendar (containing future bookings)
- Parses and filters only future events
- Merges them into a local calendar.ics file, avoiding duplicates
- Overwrites the original file with the updated version
- This ensures the local calendar remains up-to-date with minimal manual effort.

## ✅ How I Setup n8n using docker

To automate the environment setup, I used a **custom Dockerfile** to install the external npm package `ical.js`, which is needed to parse `.ics` calendar files inside n8n workflows.

Instead of manually running `docker exec` to install the package inside the container, I:

1.  **Created a Dockerfile** that extends the official `n8nio/n8n` image.
2.  Used the `ARG` instruction (`NPM_GLOBAL_PACKAGES`) to install `ical.js` globally during the build process: 
    Dockerfile
    ```yaml
     RUN if [ -n "$NPM_GLOBAL_PACKAGES" ]; then npm install -g $NPM_GLOBAL_PACKAGES; fi
     ``` 
    
3.  **Configured `docker-compose.yml`** to:
        -   Build the image using the Dockerfile
    -   Pass `ical.js` as the value of `NPM_GLOBAL_PACKAGES`
        
    -   Expose necessary ports and environment variables (including timezone and basic auth)
        
    -   Mount volumes for config and local `.ics` files
        
This approach ensures the required package (`ical.js`) is pre-installed every time the container is built, making the setup reproducible and eliminating the need for manual intervention.



### 🚀 Steps to Run the Project

1.  **Clone the Project (if needed)**
        
    ```bash 
    git clone https://github.com/your-repo/n8n-project.git cd n8n-project
    ``` 
    
2.  **Prepare Configuration Directory**  
    Set the correct ownership and permissions:
   
    ```bash
	    sudo chown -R 1000:1000 ./my-n8n-config
	    sudo chmod -R 700 ./my-n8n-config
	  ``` 
    
3.  **Start the n8n Server**  
    If you're using Docker Compose:

    ```bash
    docker-compose up -d
    ``` 
    
    Or manually via Docker:
    
	```bash
	 docker run -it --rm \
	      --name n8n \
	      -p 5678:5678 \
	      -v $(pwd)/my-n8n-config:/home/node/.n8n \
	      n8nio/n8n
      ``` 
    
4.  **Access n8n UI**  
    Open your browser and go to:
    
   ```arduino
   http://localhost:5678
   ``` 
    
----------

## 🔁 Screenshots

![image](https://github.com/user-attachments/assets/050e3fbd-7671-4454-abe1-77a66615538c)
Workflow

![image](https://github.com/user-attachments/assets/5240e369-e3f9-45d4-abc7-4c9103f8a36e)
Result

![Screenshot_20250513_233504](https://github.com/user-attachments/assets/db6dd22d-3261-4af5-b137-4b952fb4dad2)
Env


## 🔁 ICS File Merge Automation in n8n

To automate the merging of upcoming appointments from a remote `.ics` calendar into a local `.ics` file, I built an **n8n workflow** with the following steps:

### 🧩 Workflow Breakdown
1.  **Trigger Daily at 9 AM**
    
    -   Used **Schedule Trigger** to run the workflow every day at 9:00 AM.
        
2.  **Read Local ICS File**
    
    -   Used **Read File** node to read a local `.ics` file (`/home/dummy-files/dummy-file-calendar.ics`) from disk.
        
3.  **Fetch Remote ICS File**
    
    -   Used **HTTP Request** node to download a remote `.ics` calendar via HTTP GET.
        
4.  **Convert Remote Text to File**
    
    -   Used **Convert to File** node to transform the downloaded ICS text into a file-compatible binary format.
        
5.  **Merge Both Files**
    
    -   Merged local and remote ICS data using the **Merge** node.
        
    -   Then parsed both files using **custom JavaScript** with `ical.js`, extracting events.
        
    -   Filtered upcoming events from the remote file and merged them with the local calendar, avoiding duplicates based on `UID`.
        
6.  **Convert Merged JSON → ICS**
    
    -   Created a new `.ics` file from the merged JSON data using `ical.js`.
        
7.  **Write to Disk**
    
    -   Saved the updated `.ics` calendar back to disk (`/home/dummy-files/output.ics`).

### ✅ Tools Used
-   **`ical.js`**: Installed globally via Dockerfile to parse and generate `.ics` content.
-   **Custom Dockerfile**: Automated the environment setup using build-time `ARG` for npm install.
-   **Volumes**: Used Docker volumes to persist local `.ics` files in the container.

## 🧰 Troubleshooting 
| Problem | Cause | Solution |
|---------|-------|----------|
| `Permission denied` on startup | Wrong folder permissions | Run the `chown` and `chmod` commands again |
| `Cannot bind to port 5678` | Port is already in use | Change port in Docker/compose file or stop the other app |
| n8n doesn't retain workflows after restart | Config not mounted properly | Make sure `my-n8n-config` is mounted to `/home/node/.n8n` |
| n8n starts but no workflows show up | Running with wrong volume | Double-check `-v` option in Docker run or `volumes` in compose |
| Container crashes on start | Possibly corrupted config | Rename `my-n8n-config` to back it up and try again |
