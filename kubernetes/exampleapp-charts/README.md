# Application Endpoints

| Service | Port | Endpoint |
| ------ | ------ | ------ |
| AccountService | 8811 | http://account-service:8811/account/<resource>
| AuthService | 8812 | http://auth-service:8812/oauth/<resource>
| LogsService | 8813 | http://logs-service:8815/logs/<resource>
| DocService | 8814 | http://doc-service:8814/doc/<resource>
| Frontend | 80 | http://frontendt:80/<resource>

# Consumption Memory/Cpu

| Service | Limit CPU/Memory | Request CPU/Memory | Java Params |
| ------ | ------ | ------ |  ------ |
| AccountService | 1000m/1024Mi | 100m/512Mi | -Xmx820M -XX:MaxRAM=1024M -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap |
| AuthService | 1000m/1024Mi | 100m/512Mi | -Xmx820M -XX:MaxRAM=1024M -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap |
| DocService | 1000m/1600Mi | 100m/512Mi | -Xmx1300M -XX:MaxRAM=1600M -XX:+UnlockExperimentalVMOptions |
| LogsService | 1000m/1024Mi | 100m/512Mi | -Xmx820M -XX:MaxRAM=1024M -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap |
| Frontend | 50m/96Mi | 10m/48Mi  | - |