# Database Connection Pooling Example

## Requirements
- Openresty
- Luarocks
- pgmoon
- docker
- ab

1. Run Postgres
```
docker run --name pg -d -p 5432:5432 postgres
```

2. Set up table
```bash
docker exec -it pg psql -U postgres -c "create table test (id serial primary key, count int)"
docker exec -it pg psql -U postgres -c "insert into test (count) values (0)"
```

3. Start Openresty
```bash
openresty -c `pwd`/nginx.conf -p `pwd`
```

4. Run some tests
```bash
ab -k -l -c 1000 -n 100000 http://127.0.0.1:8080/
```

(Optional) View number of active connections in Postgres
```sql
select count(*)
from pg_stat_activity
where datname = 'postgres';
```
