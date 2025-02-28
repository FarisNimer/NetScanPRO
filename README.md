docker build -t my-flask-image .

docker run -d --name netscan-flask -p 7681:7681 -p 4040:4040 -p 80:80 my-f
lask-image



docker build -t cli-sandmap-image .


docker run -d --name cli-sandmap -p 4041:4041 -p 8081:8081 cli-sandmap-image
