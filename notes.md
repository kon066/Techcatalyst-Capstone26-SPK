monday:
ran into a problem with loading files into aws glue. it was reading the time columns as unknown when we needed it to be a timestamp.
we fixed it by running our own crawler and writing the schema and data into a table. we can run the crawler on the entire folder in the future.
we had a problem with writing the data from our data table to an s3 bucket. It was having a problem with the datatype of the timestamp columns. we asked tarek for a solution. custom transformation function that turned those 2 columns from objects to timestamps. then we ran into a problem where our bucket did not follow the naming convention that gives it permission to be written into. this gave us the idea to create 2 jobs, one to fix this error and land the data, and another to transform data and land to snowflake. this problem helped us to learn that it is a good idea to split up different functionalities in different jobs or sections to problem solve and debug better. We ran into another problem where we did not have the permissions to write into snowflake using glue. We had to consult our instructor and were able to get permissions for our aws accounts.

look into why multiple parquet files are written into out output bucket folders



tuesday: 
we also realized that running yellow and green ingest in parallel made it so we were running both everytime we were trying to troubleshoot one. It made it harder to see the issue as well. we ran into a problem when we changed the path from file to folder. we may have to compare the schemas between 2025 and 2026 data to see if thats the reason they can be run together. we decided to not use glue to move data. we used a copy in the aws cloudshell to move the data into our raw bucket. we used aws s3 sync s3://techcatalyst-de-2026/raw/green_taxi/ s3://techcatalyst-spk-capstone/taxi_timestamp_fixed/taxi_green/. glue parser was not working with timestamp in our data. so we switch version and changed datatype of column which let us write to snwoflake.

yellow_taxi_raw: 38,759,706 rows
green_taxi_raw: 465,029 rows

yellow_taxi_bronze: 23,070,793 rows
green_taxi_bronze: 374,353 rows

we decided to keep data that was from right before january or right after may.


