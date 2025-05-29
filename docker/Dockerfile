# Use Ubuntu based server
FROM ubuntu:24.04

# Download java dependency and wget
RUN apt update && \ 
    apt install -y openjdk-21-jdk-headless wget

# Create a minecraft folder and set as pwd
WORKDIR /home/ubuntu/minecraft

# Download Minecraft Server
RUN wget https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar -O minecraft_server.jar

# Accept the EULA
RUN echo "eula=true" > eula.txt

# Run the server when the container starts
CMD ["java", "-Xmx1024M", "-Xms1024M", "-jar", "minecraft_server.jar", "nogui"]
