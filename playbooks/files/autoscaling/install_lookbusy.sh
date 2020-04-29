wget http://www.devin.com/lookbusy/download/lookbusy-1.4.tar.gz
tar -xzf lookbusy-1.4.tar.gz
cd lookbusy-1.4
./configure
make
sudo make install
cd ../
rm -rf lookbusy-1.4*
echo "Done"
