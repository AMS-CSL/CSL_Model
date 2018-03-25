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
	
	 // function to get travel time for a given mode = expected travel time for next trip as per the model


// float get_expected_travel_time_for_a_mode (inhabitants i, int mode)
//{
//	float travel_time;
//	switch mode
//	{
//		match 1
//		{
//			travel_time <- gauss(mean(i.memory_bike_times), standard_deviation(i.memory_bike_times));
//		}
//
//		match 2
//		{
//			travel_time <- gauss(mean(i.memory_walk_times), standard_deviation(i.memory_walk_times));
//		}
//
//		match 3
//		{
//			travel_time <- gauss(mean(i.memory_pt_times), standard_deviation(i.memory_pt_times));
//		}
//
//		match 4
//		{
//			travel_time <- gauss(mean(i.memory_car_times), standard_deviation(i.memory_car_times));
//		}
//	}
//	return travel_time;
//}
	
	
//	//function to get expected time for all modes, argument = self
//map get_expected_travel_time_for_all_modes (inhabitants i)
//{
//	map<string, float> expected_travel_time_all_modes;
//	expected_travel_time_all_modes["bike"] <- gauss(mean(i.memory_bike_times), standard_deviation(i.memory_bike_times));
//	expected_travel_time_all_modes["walk"] <- gauss(mean(i.memory_walk_times), standard_deviation(i.memory_walk_times));
//	expected_travel_time_all_modes["pt"] <- gauss(mean(i.memory_pt_times), standard_deviation(i.memory_pt_times));
//	expected_travel_time_all_modes["car"] <- gauss(mean(i.memory_car_times), standard_deviation(i.memory_car_times));
//	return expected_travel_time_all_modes;
//}
	
	
	
	float get_linear_forecast(list<float> f, int mode_number){
		matrix<float> data_matrix <- 0.0 as_matrix {2,length(f)};
		loop i from: 0 to: length(f) -1 {
			
			data_matrix[0,i] <- i;
			
			data_matrix[1,i] <- f[i];
		}
		//write data_matrix;
		if mode_number = ""{
			warn "No mode defined in call to linear forecast";
		}
		regression my_regression_model  <- build(data_matrix);
		//write my_regression_model;
		float my_prediction <-  predict(my_regression_model, [length(f)]);
		write string(mode_number) + "_ " + my_prediction;
		return my_prediction;
	}
	
	init{
		list<float> ff<- [10.0,200.0,300.0,140.0];
		//write "forecast is "+ get_linear_forecast(ff,1);
		
	}
	
}



//experiment functions_library type: gui {
//
//	
//	// Define parameters here if necessary
//	// parameter "My parameter" category: "My parameters" var: one_global_attribute;
//	
//	// Define attributes, actions, a init section and behaviors if necessary
//	// init { }
//	
//	
//	output {
//	// Define inspectors, browsers and displays here
//	
//	// inspect one_or_several_agents;
//	//
//	// display "My display" { 
//	//		species one_species;
//	//		species another_species;
//	// 		grid a_grid;
//	// 		...
//	// }
//
//	}
//}