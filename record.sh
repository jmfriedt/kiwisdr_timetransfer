dir=`date +%s`
killall python
cd /home/jmfriedt/sdr/250801/kiwiclient/
mkdir -p $dir
./kiwirecorder.py -d $dir  --station=G8U  --tlimit=10   -s g8ure.ddns.net  -p 8074 -f 162 -w -m iq  &
./kiwirecorder.py -d $dir  --station=G80  --tlimit=10   -s gw0kig.ddns.net -p 8073 -f 162 -w -m iq  &
./kiwirecorder.py -d $dir  --station=DG3  --tlimit=10   -s kiwi.dg3sdk.de  -p 8073 -f 162 -w -m iq  &
./kiwirecorder.py -d $dir  --station=ECH  --tlimit=10   -s echofox.fr      -p 8073 -f 162 -w -m iq  &
./kiwirecorder.py -d $dir  --station=220  --tlimit=10   -s 22048.proxy.kiwisdr.com  -p 8073 -f 100 -w -m iq  &
./kiwirecorder.py -d $dir  --station=G8U  --tlimit=10   -s g8ure.ddns.net  -p 8074 -f 100 -w -m iq  &
./kiwirecorder.py -d $dir  --station=G8U  --tlimit=10   -s g8ure.ddns.net  -p 8074 -f 77.5 -w -m iq  &
./kiwirecorder.py -d $dir  --station=ON5  --tlimit=10   -s sdr3.on5kq.be  -p 8075 -f 100 -w -m iq  &
./kiwirecorder.py -d $dir  --station=ON5  --tlimit=10   -s sdr3.on5kq.be  -p 8075 -f 162 -w -m iq  &
./kiwirecorder.py -d $dir  --station=ON5  --tlimit=10   -s sdr3.on5kq.be  -p 8075 -f 77.5 -w -m iq  &
./kiwirecorder.py -d $dir  --station=ZAP  --tlimit=10   -s wessex.zapto.org -p 8073 -f 77.5 -w -m iq  &
./kiwirecorder.py -d $dir  --station=ZAP  --tlimit=10   -s wessex.zapto.org -p 8073 -f 162 -w -m iq  &
./kiwirecorder.py -d $dir  --station=ZAP  --tlimit=10   -s wessex.zapto.org -p 8073 -f 100 -w -m iq  &
./kiwirecorder.py -d $dir  --station=FR  --tlimit=10   -s sdr.autreradioautreculture.com -p 8073 -f 100 -w -m iq  &
./kiwirecorder.py -d $dir  --station=FR  --tlimit=10   -s sdr.autreradioautreculture.com -p 8073 -f 162 -w -m iq  &
./kiwirecorder.py -d $dir  --station=FR  --tlimit=10   -s sdr.autreradioautreculture.com -p 8073 -f 77.5 -w -m iq  &
# ./kiwirecorder.py -d $dir  --station=MAN --tlimit=10   -s radio.satelliteboy.com -p 80 -f 77.5 -w -m iq  &
# ./kiwirecorder.py -d $dir  --station=MAN --tlimit=10   -s radio.satelliteboy.com -p 80 -f 100 -w -m iq  &
# ./kiwirecorder.py -d $dir  --station=MAN --tlimit=10   -s radio.satelliteboy.com -p 80 -f 162 -w -m iq  &
./kiwirecorder.py -d $dir  --station=QTR --tlimit=10   -s midskiwi.ddns.net -p 8073 -f 100 -w -m iq  &
./kiwirecorder.py -d $dir  --station=EID --tlimit=10   -s 188.213.88.46 -p 8073 -f 100 -w -m iq  &
./kiwirecorder.py -d $dir  --station=EID --tlimit=10   -s 188.213.88.46 -p 8073 -f 162 -w -m iq  &
./kiwirecorder.py -d $dir  --station=EID --tlimit=10   -s 188.213.88.46 -p 8073 -f 77.5 -w -m iq  &
