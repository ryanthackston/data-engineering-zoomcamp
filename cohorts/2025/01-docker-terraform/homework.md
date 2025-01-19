# Module 1 Homework: Docker & SQL

In this homework we'll prepare the environment and practice
Docker and SQL

When submitting your homework, you will also need to include
a link to your GitHub repository or other public code-hosting
site.

This repository should contain the code for solving the homework. 

When your solution has SQL or shell commands and not code
(e.g. python files) file format, include them directly in
the README file of your repository.


## Question 1. Understanding docker first run 

Run docker with the `python:3.12.8` image in an interactive mode, use the entrypoint `bash`.

What's the version of `pip` in the image?

X 24.3.1
- 24.2.1
- 23.3.1
- 23.2.1


## Question 2. Understanding Docker networking and docker-compose

Given the following `docker-compose.yaml`, what is the `hostname` and `port` that **pgadmin** should use to connect to the postgres database?

```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin  

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```

- postgres:5433
- localhost:5432
- db:5433
- postgres:5432
X db:5432

If there are more than one answers, select only one of them

##  Prepare Postgres

Run Postgres and load data as shown in the videos
We'll use the green taxi trips from October 2019:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz
```

You will also need the dataset with zones:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

Download this data and put it into Postgres.

You can use the code from the course. It's up to you whether
you want to use Jupyter or a python script.

## Question 3. Trip Segmentation Count

During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, **respectively**, happened:
1. Up to 1 mile
2. In between 1 (exclusive) and 3 miles (inclusive),
3. In between 3 (exclusive) and 7 miles (inclusive),
4. In between 7 (exclusive) and 10 miles (inclusive),
5. Over 10 miles 

Answers:

with distance_under_1 as (
SELECT count(*)
FROM green_taxi_oct_2019 gt 
where gt.trip_distance <= 1
),
distance_1_to_3 as (
SELECT count(*)
FROM green_taxi_oct_2019 gt 
where gt.trip_distance > 1
and gt.trip_distance <= 3
),
distance_3_to_7 as (
SELECT count(*)
FROM green_taxi_oct_2019 gt 
where gt.trip_distance > 3
and gt.trip_distance <= 7
),
distance_7_to_10 as (
SELECT count(*)
FROM green_taxi_oct_2019 gt 
where gt.trip_distance > 7
and gt.trip_distance <= 10
),
distance_over_10 as (
SELECT count(*)
FROM green_taxi_oct_2019 gt 
where gt.trip_distance > 10
)
select *
from distance_under_1
cross join distance_1_to_3
cross join distance_3_to_7
cross join distance_7_to_10
cross join distance_over_10

- 104,802;  197,670;  110,612;  27,831;  35,281
- 104,802;  198,924;  109,603;  27,678;  35,189
- 104,793;  201,407;  110,612;  27,831;  35,281
- 104,793;  202,661;  109,603;  27,678;  35,189
X 104,838;  199,013;  109,645;  27,688;  35,202


## Question 4. Longest trip for each day

Which was the pick up day with the longest trip distance?
Use the pick up time for your calculations.

Tip: For every day, we only care about one single trip with the longest distance. 

SELECT
trip_distance,
lpep_pickup_datetime, 
lpep_dropoff_datetime,
COALESCE(zpu."Borough", 'Outside of NYC') as pickup_borough,
zpu."Zone" as pickup_zone,
COALESCE(zdo."Borough", 'Outside of NYC') as dropoff_borough,
zdo."Zone" as dropoff_zone
FROM green_taxi_oct_2019 gt 
join zones zpu on zpu."LocationID" = gt."PULocationID"
join zones zdo on gt."DOLocationID" = zdo."LocationID"
order by trip_distance desc
limit 5;

- 2019-10-11
- 2019-10-24
- 2019-10-26
X 2019-10-31


## Question 5. Three biggest pickup zones

Which were the top pickup locations with over 13,000 in
`total_amount` (across all trips) for 2019-10-18?

Consider only `lpep_pickup_datetime` when filtering by date.
 
SELECT
ROUND(CAST(SUM(total_amount) AS NUMERIC), 2) AS total_amount,
zpu."Zone" as pickup_zone        
FROM green_taxi_oct_2019 gt 
join zones zpu on zpu."LocationID" = gt."PULocationID"
join zones zdo on gt."DOLocationID" = zdo."LocationID"
where cast(lpep_pickup_datetime AS DATE) = to_date('2019-10-18', 'YYYY-MM-DD')
group by 
zpu."Zone"
order by total_amount desc

X East Harlem North, East Harlem South, Morningside Heights
- East Harlem North, Morningside Heights
- Morningside Heights, Astoria Park, East Harlem South
- Bedford, East Harlem North, Astoria Park


## Question 6. Largest tip

For the passengers picked up in October 2019 in the zone
name "East Harlem North" which was the drop off zone that had
the largest tip?

Note: it's `tip` , not `trip`

We need the name of the zone, not the ID.

SELECT
gt.tip_amount,
zpu."Zone" as pickup_zone,
COALESCE(zpu."Borough", 'Outside of NYC') as Borough
FROM green_taxi_oct_2019 gt 
join zones zpu on zpu."LocationID" = gt."PULocationID"
join zones zdo on gt."DOLocationID" = zdo."LocationID"
order by gt.tip_amount desc

- Yorkville West
X JFK Airport
- East Harlem North
- East Harlem South


## Terraform

In this section homework we'll prepare the environment by creating resources in GCP with Terraform.

In your VM on GCP/Laptop/GitHub Codespace install Terraform. 
Copy the files from the course repo
[here](../../../01-docker-terraform/1_terraform_gcp/terraform) to your VM/Laptop/GitHub Codespace.

Modify the files as necessary to create a GCP Bucket and Big Query Dataset.


## Question 7. Terraform Workflow

Which of the following sequences, **respectively**, describes the workflow for: 
1. Downloading the provider plugins and setting up backend,
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform`

Answers:
- terraform import, terraform apply -y, terraform destroy
- teraform init, terraform plan -auto-apply, terraform rm
- terraform init, terraform run -auto-approve, terraform destroy
X terraform init, terraform apply -auto-approve, terraform destroy
- terraform import, terraform apply -y, terraform rm


## Submitting the solutions

* Form for submitting: https://courses.datatalks.club/de-zoomcamp-2025/homework/hw1
