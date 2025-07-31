# Docker Compose for MinIO and MongoDB with Document Size Limit

This project sets up a local environment with **MinIO** (S3-compatible object storage) and **MongoDB**, using **Docker Compose**. The goal is to provide a test environment for file and metadata storage while considering MongoDB's document size limit.

## Project Structure

```
project-root/
│-- docker-compose.yml
│-- README.md
```

## How to Run the Project

1. Ensure you have Docker and Docker Compose installed.

2. In the terminal, navigate to the project folder and run:

   ```bash
   docker-compose up -d
   ```

3. Access:

   * **MinIO Console:** [http://localhost:9001](http://localhost:9001)

     * Username: `minioadmin`
     * Password: `minioadmin`
   * **MongoDB:** Port `27017`

4. To stop the services:

   ```bash
   docker-compose down
   ```

## MongoDB Document Size Limit Considerations

* **MongoDB** has a **maximum document size of 16MB**.
* If a file or metadata exceeds this size, it **cannot be stored in a single document**.
* Recommended approach:

  * Use **MinIO** to store large binary files (no size restrictions like MongoDB's 16MB limit).
  * Use **MongoDB** only for metadata or references to files (e.g., bucket URL, filename, hash).
  * If direct file storage in MongoDB is required, use **GridFS**, which splits large files into chunks smaller than 16MB.

## Example of MongoDB Document Structure

```json
{
  "fileName": "report.pdf",
  "bucket": "my-files",
  "path": "https://localhost:9000/my-files/report.pdf",
  "uploadedAt": "2025-07-31T14:00:00Z",
  "sizeBytes": 52428800,
  "hash": "abc123xyz"
}
```

## Notes

* MinIO acts as an S3-compatible server and works with any S3 SDK.
* MongoDB is used for structured data only, avoiding the 16MB limitation.
* For production:

  * Use **persistent volumes** on external disks.
  * Configure secure environment variables (avoid `minioadmin`).
  * Enable TLS certificates for secure connections.
