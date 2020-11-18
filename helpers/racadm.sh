USER="jimi"
PASSWORD="hendrix"
SERVER="192.168.122.253"
ISO_URL="http://192.168.1.1:8080/cnf10-worker.iso"
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD remoteimage -s &&\
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD remoteimage -d &&\
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD remoteimage -c -l $ISO_URL &&\
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD set iDRAC.VirtualMedia.BootOnce 1 &&\
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD set iDRAC.ServerBoot.FirstBootDevice VCD-DVD &&\
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD serveraction powercycle
