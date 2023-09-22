#----------------------------------------------------------------------
#----------------------------------------------------------------------
# File:			Makefile
# Programmers:		Steve Oudot, Primoz Skraba
# Description:		Example makefile
# Last modified:	August 10, 2009 (Version 0.1)
#----------------------------------------------------------------------
#  Copyright (c) 2009 Steve Oudot, Primoz Skraba.  All Rights Reserved.
#-----------------------------------------------------------------------
#
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#
#
#-----------------------------------------------------------------------
#----------------------------------------------------------------------
# History:
#	Revision 0.1  August 10, 2009
#		Initial release
#----------------------------------------------------------------------
#----------------------------------------------------------------------

CXX = g++

ANNLIB = /usr/local/ann_1.1.2

CXXFLAGS = \
	   -Iinclude \
	   -I$(ANNLIB)/include \
	   -O3


LIBPATH = \
	  -L$(ANNLIB)/lib


LDFLAGS = \
	  -lANN  # use -lann instead under Debian/Ubuntu



#OBJECTS =


#---------------------------------------------------------------------#
#                    target entries
#---------------------------------------------------------------------#

all: main main_w_density

main:  main.cpp 
	$(CXX) $(LIBPATH) -o main main.cpp $(CXXFLAGS) $(LDFLAGS) 

main_w_density:  main_w_density.cpp
	$(CXX) $(LIBPATH) -o main_w_density main_w_density.cpp $(CXXFLAGS) $(LDFLAGS) 

clean: 
	rm main main_w_density


