Vagrant.configure("2") do |config|
  config.vbguest.iso_path = "#{ENV['HOME']}/vagrant/VBoxGuestAdditions_6.0.0.iso"
  config.vbguest.no_remote = true

  config.vm.box = "ubuntu/bionic64"

  config.disksize.size = '20GB'

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.name = "farm_rfam"
    vb.memory = "22096"
  end
  
  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
  
    #Firewall
    apt-get update -qq -y && apt-get install ufw -qq -y
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    echo y | ufw enable
    
    #General upgrade
    apt-get update -qq -y && apt-get upgrade -qq -y

    export FARM_RFAM_VERSION=1.0.0
    export INFERNAL_VERSION=1.0
    apt-get update -qq -y 
    apt-get upgrade -qq -y
    # required system packages
    apt-get update -qq -y && apt-get install -qq -y \
        openjdk-11-jre-headless \
        curl \
        cpanminus \
        libexpat1-dev \
        pkg-config \
        libgd-dev \
        uuid \
        wget \
        openssh-client \
        git
    
    # blast
    mkdir /tmp/blast && cd /tmp/blast
    wget -q ftp://ftp.ncbi.nlm.nih.gov/blast/executables/legacy.NOTSUPPORTED/2.2.25/blast-2.2.25-x64-linux.tar.gz
    tar xf blast-2.2.25-x64-linux.tar.gz
    mv blast-2.2.25 /opt
    rm -rf /tmp/blast

    # infernal (required by rfam_scan.pl)
    mkdir /tmp/infernal && cd /tmp/infernal
    wget -q http://eddylab.org/software/infernal/infernal-${INFERNAL_VERSION}.tar.gz
    tar xf infernal-${INFERNAL_VERSION}.tar.gz
    cd infernal-${INFERNAL_VERSION}
    ./configure --prefix /opt/infernal
    make
    #make check
    make install
    rm -rf /tmp/infernal

    # rfam
    mkdir /opt/rfam && cd /opt/rfam
    wget -q ftp://ftp.ebi.ac.uk/pub/databases/Rfam/11.0/rfam_scan/rfam_scan.pl
    chmod 755 rfam_scan.pl
    wget -q ftp://ftp.ebi.ac.uk/pub/databases/Rfam/11.0/rfam_scan/Expandednotesonrunningrfam_scan.pl.txt
    mkdir -p /data/rfam/11 && cd /data/rfam/11
    wget -q ftp://ftp.ebi.ac.uk/pub/databases/Rfam/11.0/Rfam.fasta.gz
    wget -q ftp://ftp.ebi.ac.uk/pub/databases/Rfam/11.0/Rfam.cm.gz
    gunzip Rfam.fasta.gz
    gunzip Rfam.cm.gz
    /opt/blast-2.2.25/bin/formatdb -i ./Rfam.fasta -p F

    # nextflow
    mkdir /opt/nextflow
    cd /opt/nextflow
    curl -s https://get.nextflow.io | bash
    export NXF_HOME=/opt/nextflow/.nextflow
    mkdir /opt/nextflow/.nextflow
    ./nextflow
    chmod -R 755 /opt/nextflow

    # perl modules
    cpanm --notest Getopt::Long
    cpanm --notest Bio::SeqIO
    cpanm --notest IO::File

    # vagrant specific directory structure
    ln -sfr /vagrant /opt/farm-rfam

    # cleanup
    apt-get autoremove
    apt-get clean

  SHELL

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    echo 'export PATH=/opt/blast-2.2.25/bin/:/opt/infernal/bin/:/opt/nextflow/:/opt/rfam/:/opt/farm-rfam:\$\{PATH\}' >> /home/vagrant/.profile
    echo 'export FARM_RFAM_NEXTFLOW_CONFIG=/vagrant/test_config.conf' >> /home/vagrant/.profile
  SHELL
end
