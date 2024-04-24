docker exec -it mysql mysqldump --default-character-set=utf8mb4 --single-transaction -uroot -pens_search2022 --all-databases > /data/docker/mysql-back/backups/alldatabases.sql
cd /data/docker/mysql-back/backups
git add alldatabases.sql
git commit -m "数据库备份"
git push -u origin "master"