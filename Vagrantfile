#Vagrantfile for launching the TM351 Virtual Machine


# MOUNTING A SHARED DROPBOX OR GOOGLE DRIVE FOLDER

# You can use a Dropbox or Google Drive folder as the shared VM folder
# For example, the path might be: "PATH/TO/YOUR FOLDER"
# Or perhaps: "~/Dropbox/testvagrant"
# The default path is the current directory containing this Vagrantfile: "."

# Change the path in the SHARED_FOLDER_PATH setting below (default: "."):
SHARED_FOLDER_PATH = "."




# IMPROVING PERFORMANCE

# You can improve the performance of the VM in two ways:

# 1. Increase the memory allocation in MB (default: 1024):
VIRTUALBOX_MEMORY = 1024

# 2. Increase the allocation of CPU cores (default: 1):
VIRTUALBOX_CORES = 1


# TO GET STARTED:
#   run the following commands (uncommented) on the command line in the
#   directory containing this Vagrantfile

#vagrant box remove tm351_18J_testbuild
#vagrant box add tm351_18J_testbuild
#vagrant up

#------------ YOU SHOULD NOT NEED TO CHANGE ANY SETTINGS BELOW HERE -----------------




Vagrant.configure("2") do |config|
	
#------------------------- PROVIDER: VIRTUALBOX (BUILD) ------------------------------

    config.vm.provider :virtualbox do |virtualbox|

        #Path for custom synced folder - examples
        # Shared folder: set user options as per tm351 userid to simplify permissions
        # The fact that the user has not been created is okay if we use the uid:
        #   eg as per https://github.com/hashicorp/vagrant/issues/936
        config.vm.synced_folder SHARED_FOLDER_PATH, "/vagrant", mount_options: ["uid=1351", "gid=100"]



        #Make sure that any required directories are created
        config.vm.provision :shell, :inline => <<-SH
            mkdir -p /vagrant/notebooks
            mkdir -p /vagrant/openrefine_projects
            mkdir -p /vagrant/logs
            mkdir -p /vagrant/data
            mkdir -p /vagrant/utilities
            mkdir -p /vagrant/backups
            mkdir -p /vagrant/backups/postgres-backup/
            mkdir -p /vagrant/backups/mongo-backup/	
        SH
  
        #Stick with the default key
        config.ssh.insert_key=false
    
        #For local testing:
        config.vm.box = "tm351_18J_testbuild"
        #Rather than vagrant add, we can back src in with one of following styles
        #config.vm.box_url = ""
        config.vm.box_url = "tm351_18j.box"
    
        #Path for downloading box from vagrantcloud
        #config.vm.box = "ouseful/tm351_18J"


        config.vm.hostname = "tm351-18J-test-student"

        virtualbox.name = "tm351_18J_test_vb-student"
        #We need the memory to install scipy and build indexes on seeded mongodb
        #After the build it can be reduced back down to 1024
        virtualbox.memory = VIRTUALBOX_MEMORY
        virtualbox.cpus = VIRTUALBOX_CORES
        # virtualbox.gui = true

        #---- START PORT FORWARDING ----
        #Registered ports: https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
        #ipython notebook
        config.vm.network :forwarded_port, guest: 8888, host: 35180, auto_correct: true
        #openrefine
        config.vm.network :forwarded_port, guest: 3334, host: 35181, auto_correct: true
            #webserver
        config.vm.network :forwarded_port, guest: 80, host: 35100, auto_correct: true
        config.vm.network :forwarded_port, guest: 5432, host: 35182, auto_correct: true

        #TH custom- nbdime
        config.vm.network :forwarded_port, guest: 8899, host: 35199, auto_correct: true
        #---- END PORT FORWARDING ----
        
    end
    
#------------------------- END PROVIDER: VIRTUALBOX (BUILD) ------------------------------


  
end
