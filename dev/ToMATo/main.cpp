//----------------------------------------------------------------------
//----------------------------------------------------------------------
// File:	        main.cpp
// Programmers:		Steve Oudot, Primoz Skraba
// Description:		Example persistence clustering pipeline
// Last modified:	Sept. 8, 2009 (Version 0.2)
//----------------------------------------------------------------------
//  Copyright (c) 2009 Steve Oudot, Primoz Skraba.  All Rights Reserved.
//-----------------------------------------------------------------------
//
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//
//-----------------------------------------------------------------------
//----------------------------------------------------------------------
// History:
//	Revision 0.1  August 10, 2009
//		Initial release
//----------------------------------------------------------------------
//----------------------------------------------------------------------



#include <iostream>
#include <sstream>
#include <cassert>

#include <algorithm>


#include "Vertex.h"
#include "Distance_ANN.h"
#include "Core.h"
#include "Cluster_Basic.h"
#include "Point.h"
#include "Density.h"


using namespace std;


//rename for brevity
typedef Vertex<ANNPoint,Cluster_Info > Point;

// comparison function object for vector indices
template<class V> class Less_Than {
  protected:
  V& v;
  public:
  Less_Than (V& v_): v(v_){}
  bool operator()(const int a, const int  b) const 
  {return Point::Less_Than()(v[a], v[b]);}
};


// main function
int main(int argc, char *argv[]){
  
  if(argc!=4){
    cout<<"Usage:"<<endl<<argv[0]<<" <input filename> <Rips radius> <prominence threshold>"<<endl;
    exit(0);
  }


  int com=1;
  vector< Point > point_cloud;

  //read in data points with density values
  string input_file_name = argv[com++];
  ifstream input;
  input.open(input_file_name.c_str());
  assert(input.good());

  int dim = -1;
  int nb_points = 0;
  string lineData;
  while(getline(input, lineData))
    {
      // read next point's coordinates
      double d;
      vector<double> row;
      stringstream lineStream(lineData);
      while (lineStream >> d)
	row.push_back(d);

      // set up dim if not already done
      if (dim < 0) {
	dim = row.size() - 1; // reserve last coordinate for function value
	cout << "Dimension: " << dim << endl;
      }
      // else check that dimension is preserved
      else if (dim != row.size() - 1) {
	cerr << "Error: mismatched dimension in " 
	     << input_file_name << " at line " << (nb_points+1) << endl;
	return -1;
      }
	  
      // create new point and corresponding vertex
      ANNPoint p(dim);
      p.coord = new double[dim];
      for (int i=0; i<dim; i++)
	p.coord[i] = row[i];
      Point v(p);
      v.set_func(row[dim]);
      v.data.boundary_flag=false;
      point_cloud.push_back(v);
      nb_points++;
    }
  input.close();
  cout << "Number of input points: " << nb_points << endl;


  // sort point cloud and retrieve permutation (for pretty output)
  vector<int> perm;
  perm.reserve(nb_points);
  for(int i=0; i < nb_points; i++)
    perm.push_back(i);
  std::sort(perm.begin(), perm.end(), Less_Than<vector<Point> >(point_cloud));
  // store inverse permutation as array of iterators on initial point cloud
  vector< vector<Point>::iterator> pperm;
  pperm.reserve(nb_points);
  for (int i=0; i<nb_points; i++)
    pperm.push_back(point_cloud.begin());
  for (int i=0; i<nb_points; i++)
    pperm[perm[i]] = (point_cloud.begin() + i);
  // operate permutation on initial point cloud 
  vector<Point> pc;
  pc.reserve(nb_points);
  for (int i=0; i<nb_points; i++)
    pc.push_back(point_cloud[i]);
  for (int i=0; i<nb_points; i++)
    point_cloud[i] = pc[perm[i]];

  // create distance structure
  Distance_ANN< vector< Point >::iterator > metric_information;

  metric_information.initialize(point_cloud.begin(),
				point_cloud.end(),
				dim);
  //set rips parameter
  double r = atof(argv[com++]);
  metric_information.mu = r*r;
  


  //create cluster data structure
  Cluster< vector< Point >::iterator > output_clusters;
  //set threshold
  output_clusters.tau = atof(argv[com++]);

  // perform clustering
  compute_persistence(point_cloud.begin(),point_cloud.end(),
  	      metric_information,output_clusters);


  // compress data structure:
  // attach each data point to its cluster's root directly
  // to speed up output processing
  attach_to_clusterheads(point_cloud.begin(),point_cloud.end());

  // output clusters (use permutation to preserve original point order)
  ofstream out;
  out.open("clusters.txt");
  output_clusters.output_clusters(out, pperm.begin(), pperm.end());
  out.close();

  //output barcode
  out.open("diagram.txt");
  output_clusters.output_intervals(out);
  out.close();
  
  //output colored clusters to COFF file (first 3 dimensions are selected)
  out.open("clusters_3d.coff");
  output_clusters.output_clusters_coff(out,point_cloud.begin(),point_cloud.end());
  out.close();


}
