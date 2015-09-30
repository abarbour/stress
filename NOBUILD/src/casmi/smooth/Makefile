SHELL=/bin/sh

smooth: smooth.o smoothfu.o sortfunc.o hmsmooth.o smoothwr.o smpred.o traject.o renumber.o
	g++  -o smooth smooth.o smoothfu.o sortfunc.o hmsmooth.o smoothwr.o smpred.o traject.o renumber.o -lm

smpred.o: smooth.h smpred.cpp
	g++   -c smpred.cpp  
	
traject.o: smooth.h traject.cpp
	g++   -c traject.cpp  
	
hmsmooth.o: smooth.h hmsmooth.cpp
	g++   -c hmsmooth.cpp  

smoothwr.o: smooth.h smoothwr.cpp
	g++   -c smoothwr.cpp  

smooth.o: smooth.h smooth.cpp
	g++   -c smooth.cpp  

smoothfu.o: smooth.h smoothfu.cpp 
	g++   -c smoothfu.cpp  

sortfunc.o: smooth.h sortfunc.cpp
	g++   -c sortfunc.cpp  

renumber.o: smooth.h renumber.cpp
	g++   -c renumber.cpp  


install: smooth
	mv smooth /usr/local/bin
	
	
clean:
	rm -f smooth.o smoothfu.o sortfunc.o hmsmooth.o smoothwr.o smpred.o traject.o renumber.o


print:  
	a2ps -c smooth.h smooth.cpp smoothfu.cpp sortfunc.cpp hmsmooth.cpp smoothwr.cpp smpred.cpp traject.cpp renumber.cpp > smooth.ps

