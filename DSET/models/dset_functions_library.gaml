/**
* Name: dsetlibrary
* Author: bhami001
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model dsetlibrary

/* Insert your model definition here */

global{
	
	
	list<float> add_to_memory(list<float> a_list, float new_addition, int previous <-5 ){
		//int latest <- previous  min:0 max:3;
		//float energy <- 1000 min: 0 max: 2000 ;
		add new_addition to:a_list;
		return last(previous,a_list);
	}
	
	list<string> get_names(list<agent> gn){
		list<string> gnn <- gn accumulate (each.name);
		return gnn;
	}
	
}