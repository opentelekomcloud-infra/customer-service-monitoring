wget https://github.com/bugwhine/lookbusy/archive/1.4.tar.gz
tar -xzf 1.4.tar.gz
cd lookbusy-1.4
./configure
make
sudo make install
cd ../
rm -rf lookbusy-1.4*
echo "Done"
