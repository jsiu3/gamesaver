#!/bin/sh

[ -d ./req ] || mkdir req

cd req

    echo "Checking for Node.js dependencies..."
    
    if (which python > /dev/null); then echo "Python ok"; else
        echo "Getting python tar..."
        curl http://www.python.org/ftp/python/2.7.2/Python-2.7.2.tgz | tar -xz
        cd Python-2.7.2
            ./configure
            make
            sudo make install
        cd ..
    fi
    
    if (which openssl > /dev/null); then echo "libssl-dev ok"; else
        echo "Getting OpenSSL (libssl-dev) tar..."
        curl http://www.openssl.org/source/openssl-1.0.0e.tar.gz | tar -xz
        cd openssl-1.0.0e
            ./config
            make
            make test
            sudo make install
        cd ..
    fi
    
    if (which node > /dev/null); then echo "node ok"; else
        echo "Getting Node tar..."
        curl http://nodejs.org/dist/node-v0.4.12.tar.gz | tar -xz
        cd node-v0.4.12
            ./configure
            make -j2 # -j sets the number of jobs to run
            sudo make install
        cd ..
    fi

cd .. #back into gamesaver dir

if (which npm > /dev/null); then echo "npm ok"; else
    echo "Getting npm tar..."
    cd req
    	curl http://npmjs.org/install.sh -o "npminstall.sh"
	sudo sh npminstall.sh
	echo "did npm install correctly?" 
	echo "If not ctrl-c, su root, sh ./req/npminstall.sh then run install again"
	echo "else press enter to continue..."
	read 
    cd ..
fi
npm install 

cd req
    echo "Checking MongoDB..."
    if [ -d ./mongodb ]; then echo "MongoDB ok"; else
	    while [[ "$os" != "linux32" && "$os" != "linux64" && "$os" != "osx32" && "$os" != "osx64" ]]
	    do
		echo "Please enter a valid OS (linux32, linux64, osx32, osx64):"
		read os
		case $os in
		    linux32)
		        curl -L http://fastdl.mongodb.org/linux/mongodb-linux-i686-2.0.1.tgz | tar -xz
		        mv mongodb-linux-i686-2.0.1/ mongodb
		        ;;
		    linux64)
		        curl -L http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.1.tgz | tar -xz
		        mv mongodb-linux-x86_64-2.0.1/ mongodb
		        ;;
		    osx32)
		        curl -L http://fastdl.mongodb.org/osx/mongodb-osx-i386-2.0.1.tgz | tar -xz
		        mv mongodb-osx-i386-2.0.1/ mongodb
		        ;;
		    osx64)
		        curl -L http://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.0.1.tgz | tar -xz
		        mv mongodb-osx-x86_64-2.0.1/ mongodb
		        ;;
		    *)  #empty to catch all other and restart the loop
		        ;;
		esac
	    done
    fi
cd ..

sudo mkdir -p /data/db #makes folder dependency for mongodb

nohup make db > dbOutput.txt 2> dbErrors.txt < /dev/null &      #runs make db command backgrounded..

echo "When you see '>' You're in mongoDB Shell please type:"
echo "use Gladius"
echo 'db.addUser("test", "test");'
echo "exit"
./req/mongodb/bin/mongo
echo "Done."
exit
