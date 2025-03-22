####### Specify the target name ######
TARGET = calc  

#-------Do Not Change below this line-------------
#Compile with g++
CC = g++ -DYYDEBUG=1

#use -g for gnu debugger and -std= for c++11 compiling
CXXFLAGS = -g -std=c++20 -L/usr/lib

OBJS:= lex.yy.o calc.tab.o

###### Tabs Matter!#########
$(TARGET): $(OBJS)
	$(CC) -o $@ $(OBJS) -lm -lstdc++

lex.yy.o: lex.yy.cpp calc.tab.h
	$(CC) -c $(CXXFLAGS) $<

lex.yy.cpp: calc.l 
	flex -I calc.l 
	mv -f lex.yy.c lex.yy.cpp
	bison -dtv calc.y 
	mv -f calc.tab.c calc.tab.cpp

calc.tab.o: calc.tab.cpp
	$(CC) -c $(CXXFLAGS) $<

calc.tab.cpp: calc.y
	bison -dtv $<
	mv -f calc.ytab.c calc.ytab.cpp

#In order to get rid of all .o files create, at the command prompt
#make clean
clean:
	rm -f $(OBJS) $(TARGET) core calc.tab.* *.cpp calc.output

