# envoy-example

클라우드 네이티브에서 Nginx 보다 Envoy 를 사용하는 사례가 많아짐에 따라, Envoy 의 각종 기능과 성능을 테스트해봅니다.

- Envoy Proxy: https://www.envoyproxy.io
- Document: https://www.envoyproxy.io/docs/envoy/latest

## Components

Docker 컨테이너로 테스트를 진행합니다.

- [docker-compose.yaml](docker-compose.yaml)
    - 컨테이너 목록:
        1. simple-http-server: Go로 짜여진 심플한 HTTP 서버입니다. Upstream 용으로 사용합니다.
            - 소스 코드: [simple-http-server](simple-http-server)
        2. envoy: simple-http-server를 Reverse Proxy하는 Envoy
        3. nginx: simple-http-server를 Reverse Proxy하는 Nginx
    - 실행법: `make docker-up`
        - 모든 컨테이너들이 데몬으로 실행됩니다.
- [locust-envoy.yaml](locust-envoy.yaml)
    - Envoy 성능을 테스트하기 위한 HTTP 요청 Generator입니다.
    - 4개의 Worker 노드에서 요청을 수행한 뒤, Master 노드에서 최종적으로 Aggregation 합니다.
    - 컨테이너 목록:
        - master
        - worker
    - 실행법: `make locust-envoy`
- [locust-nginx.yaml](locust-nginx.yaml)
    - 같은 방법으로 Nginx 성능을 테스트합니다.
    - 실행법: `make locust-nginx`

## Results

- Apple M1 (8C8T) Mac Mini 2021 에서의 결과이므로 절대적인 수치는 아닙니다.
- 모든 컨테이너들은 1 코어만 사용하도록 CPU 제한을 두었습니다.

|            | Envoy       | Nginx       |
|------------|-------------|-------------|
| 평균 RPS     | 5,981 req/s | 2,099 req/s |
| P99.9 레이턴시 | 10 ms       | 78 ms       |
| CPU 사용률    | 53.97 %     | 102.87 %    |
| 메모리 사용률    | 19.23 MiB   | 7.35 MiB    |

### Envoy

```
# HTTP 요청 개수
| Type     Name           # reqs      # fails |    Avg     Min     Max    Med |   req/s  failures/s
| --------|-------------|-------|-------------|-------|-------|-------|-------|--------|-----------
| GET      /ping          358877     0(0.00%) |      1       0      28      1 | 5981.09        0.00
| --------|-------------|-------|-------------|-------|-------|-------|-------|--------|-----------
|          Aggregated     358877     0(0.00%) |      1       0      28      1 | 5981.09        0.00

# HTTP 응답 시간 (ms)
| Type     Name               50%    66%    75%    80%    90%    95%    98%    99%  99.9% 99.99%   100% # reqs
| --------|-------------|--------|------|------|------|------|------|------|------|------|------|------|------
| GET      /ping                1      2      2      2      2      3      4      4     10     17     29 358877
| --------|-------------|--------|------|------|------|------|------|------|------|------|------|------|------
|          Aggregated           1      2      2      2      2      3      4      4     10     17     29 358877

# CPU 사용률
CONTAINER ID   NAME                     CPU %     MEM USAGE / LIMIT   MEM %     NET I/O           BLOCK I/O    PIDS
047408b635cc   envoy                    53.97%    19.23MiB / 128MiB   15.03%    136MB / 185MB     0B / 0B      16
daa0c674ef3d   simple-http-server       35.74%    9.305MiB / 64MiB    14.54%    102MB / 66.4MB    0B / 0B      14
5ad4b12c47e5   envoy-example-master-1   0.14%     31.71MiB / 64MiB    49.54%    91.6kB / 22.8kB   0B / 0B      3
879ee646f1b0   envoy-example-worker-1   67.43%    32.53MiB / 64MiB    50.83%    17.3MB / 14.7MB   0B / 0B      3
d5e7cd40d871   envoy-example-worker-2   66.08%    32.5MiB / 64MiB     50.78%    15.1MB / 12.7MB   0B / 0B      3
3e333e830a46   envoy-example-worker-3   70.01%    32.53MiB / 64MiB    50.83%    17.8MB / 15MB     0B / 0B      3
d3a8da9e8934   envoy-example-worker-4   65.07%    32.53MiB / 64MiB    50.82%    15.9MB / 13.4MB   0B / 0B      3
```

### Nginx

```
# HTTP 요청 개수
| Type     Name           # reqs      # fails |    Avg     Min     Max    Med |   req/s  failures/s
| --------|-------------|-------|-------------|-------|-------|-------|-------|--------|-----------
| GET      /ping          125846     0(0.00%) |      4       0     160      2 | 2099.18        0.00
| --------|-------------|-------|-------------|-------|-------|-------|-------|--------|-----------
|          Aggregated     125846     0(0.00%) |      4       0     160      2 | 2099.18        0.00

# HTTP 응답 시간 (ms)
| Type     Name               50%    66%    75%    80%    90%    95%    98%    99%  99.9% 99.99%   100% # reqs
| --------|-------------|--------|------|------|------|------|------|------|------|------|------|------|------
| GET      /ping                2      2      3      4      7     10     66     70     78     86    160 125846
| --------|-------------|--------|------|------|------|------|------|------|------|------|------|------|------
|          Aggregated           2      2      3      4      7     10     66     70     78     86    160 125846

# CPU 사용률
CONTAINER ID   NAME                     CPU %     MEM USAGE / LIMIT   MEM %     NET I/O           BLOCK I/O    PIDS
6ecadbc9d923   nginx                    102.87%   7.352MiB / 128MiB   5.74%     82.5MB / 90.8MB   0B / 4.1kB   5
daa0c674ef3d   simple-http-server       7.84%     10.34MiB / 64MiB    16.16%    195MB / 144MB     0B / 0B      16
534d23077631   envoy-example-master-1   0.24%     31.72MiB / 64MiB    49.56%    105kB / 24.7kB    0B / 0B      3
7583be3a3693   envoy-example-worker-1   12.12%    32.56MiB / 64MiB    50.87%    8.68MB / 7.24MB   0B / 0B      4
f6452d81b1f3   envoy-example-worker-2   8.22%     32.29MiB / 64MiB    50.45%    6.8MB / 5.71MB    0B / 0B      3
8cdfa07f690e   envoy-example-worker-3   9.17%     32.36MiB / 64MiB    50.56%    7.15MB / 6.01MB   0B / 0B      4
01770ba2477c   envoy-example-worker-4   9.88%     32.45MiB / 64MiB    50.70%    8.42MB / 7.03MB   0B / 0B      3
```