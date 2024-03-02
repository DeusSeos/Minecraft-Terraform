#!/bin/bash
# check to see if Minecraft is already installed and if so start it
if [ -d /home/minecraft ]; then
    echo "Minecraft is already installed"
    systemctl daemon-reload
    systemctl enable minecraft.service
    systemctl start minecraft
    systemctl status minecraft -l
    
else
    echo "Minecraft is not installed"
    # Update the system
    yum update -y
    
    # Install Amazon Corretto 17
    yum install -y java-17-amazon-corretto
    
    # Create a new user for the Minecraft server
    useradd -m -r -s /bin/bash minecraft
    
    # Change to the new user
    su - minecraft
    
    # Create a directory for the Minecraft server
    mkdir /home/minecraft
    
    # Change to the server directory
    cd /home/minecraft
    
    # Download the Minecraft server
    wget https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar
    
    # Accept the EULA
    echo "eula=true" > eula.txt
    
    # Create a start script
    echo "#!/bin/sh" > start.sh
    echo "java -Xmx5120M -Xms2048M -jar server.jar nogui" >> start.sh
    
    # Make the start script executable
    chmod +x start.sh
    
    # Change to the system directory
    cd /etc/systemd/system
    
    # Create a new service file
    echo "[Unit]" > minecraft.service
    
    # Add a description to the service file
    echo "Description=Minecraft Server" >> minecraft.service
    
    # Add a service section to the service file
    echo "[Service]" >> minecraft.service
    
    # Set the user for the service
    echo "User=minecraft" >> minecraft.service
    
    # Set the working directory for the service
    echo "WorkingDirectory=/home/minecraft" >> minecraft.service
    
    # Set the command to start the service
    echo "ExecStart=/bin/bash /home/minecraft/start.sh" >> minecraft.service
    
    echo "SuccessExitStatus=143" >> minecraft.service
    echo "TimeoutStopSec=10" >> minecraft.service
    echo "Restart=on-failure" >> minecraft.service
    echo "RestartSec=5" >> minecraft.service
    
    # Add a section to restart the service
    echo "[Install]" >> minecraft.service
    echo "WantedBy=multi-user.target" >> minecraft.service

    # start the service
    systemctl daemon-reload
    systemctl enable minecraft.service
    systemctl start minecraft
    systemctl status minecraft -l
    
fi