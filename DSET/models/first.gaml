/**
* Name: model1
* Author: Srirama Bhamidipati
* Description: 
* Tags: Tag1, Tag2, TagN
* draw string("Off_" + int(self)) color: # white font: font('Helvetica Neue', 12, # bold + # italic);
*/
model model1
import "dset_functions_library.gaml"
import "behavior.gaml"
import "ptModel.gaml"

global
{
	
	
	
date starting_date <- date("2008-02-22 00:00:00");
float step <-1 #mn;




// THE ENVIRONMENT 
	file shape_file_streets <- file('../includes/roads/network_extended_RD.shp');
	file shape_file_bounds <- file("../includes/Boundary_study_area_rough.shp");
	file shape_buildings <- file("../includes/Buildings_Amsterdam.shp");
	geometry shape <- envelope(shape_file_bounds);

	// variables for model parameters
	float proportion_of_offices <- 0.1;
	float distance_between_homes <- 2000.0;
	float relative_work_work_distance <- 3000.0;
	int inhabitant_population <- 10;
//TODO check if this below  should be global or agent specific
	float max_travel_mode_difference <-3.0;
	
	
	
	
// GLOBAL VARIABLES FOR NEEDS CALCULATION
float inhabitant_relative_importance_existence_need <- 0.33;
float inhabitant_relative_importance_social_need <- 0.33;
float inhabitant_relative_importance_personal_need <- 0.33;

//GLOBAL VARIABLES FOR MOBILITY  page 119 mobility report amsterdam in cijfers 2016
list<int> work_pt_km <- [19,20];
list<int> work_auto_km <-[20,20];
list<int> work_bike_km <- [4,5];
list<int> work_pt_min <- [45,55];
list<int> work_auto_min <-[28,41];
list<int> work_bike_min <- [19,23];



//

	

	/** Insert the global definitions, variables and actions here */
	list<string> modes <- ["bike", "walk", "pt", "car"];
	map<string, int> mode_speed_string <- ["bike"::15, "walk"::4, "pt"::40, "car"::60];
	map<string, int> mode_value <- ["bike"::1, "walk"::2, "pt"::3, "car"::4];
	map<int, int> mode_speed_int <- [1::15, 2::4, 3::40, 4::60];
	//	list<string> maps <- mode_speed.keys;
	//geometry shape <- square(5 # km);
	init
	{
		create study_area from: shape_file_bounds;
		create roads from: shape_file_streets;
		create buildings from: shape_buildings
		{
		}

		loop i over: buildings
		{
			if flip(proportion_of_offices)
			{
				i.use <- "office";
			} else
			{
				i.use <- "residential";
			}

		}

		create inhabitants number: inhabitant_population;
		
		string aaa <- "bike";
		//write mode_value[aaa];
		//write mode_value where (each > 1);
		list<int> ia <- [1, 2];
		list<int> ib <- [1, 2];
		//write list(matrix(ia) + matrix(ib));
		map<buildings, int> bm <- [buildings[1]::4, buildings[8]::2, buildings[3]::3];
		//write bm.keys where (bm[each] > 2);
	}
}

species buildings
{
	string use;
	rgb my_color;
	aspect a
	{
		float building_height <- rnd(3.0, 12.0);
		if use = "office"
		{
			my_color <- rgb(# gray);
		} else
		{
			my_color <- rgb(# saddlebrown);
		}

		draw shape color: my_color depth: building_height;
		draw shape color: my_color at: { location.x, location.y, building_height };
	}

	aspect transparent_frame
	{
		float building_height <- rnd(3.0, 12.0);
		if use = "office"
		{
			my_color <- rgb(# gray, 0.2);
		} else
		{
			my_color <- rgb(# brown, 0.2);
		}
		draw shape color: my_color depth: building_height;
		draw shape color: my_color at: { location.x, location.y, building_height };
	}
}

species roads
{
	init
	{
	}

	aspect a
	{
		draw shape color: # gray;
	}
}

species study_area
{
	aspect a
	{
		draw shape color: rgb(# wheat, 0.1);
	}
}

species inhabitants schedules: shuffle(inhabitants)
{
	
// GLOBAL ATTRIBUTES FOR EACH AGENT
float ambition_level <- rnd(1.0);
float uncertainty_tolerance_level <- rnd(1.0);
int cognitive_effort <- 5;

	
// TRAVEL ATTRIBUTES
	string my_mode_preferred <- one_of(modes);
	string my_mode_actual <- one_of(modes);
	int value_mode_preferred <- mode_value[my_mode_preferred];
	int value_mode_actual <- mode_value[my_mode_actual];
	
	
	
//FIXME  these two below need to change to network characteristics, when we have a clean network
	float my_travel_distance <- rnd(1.0,10.0);
	float my_travel_time <- my_travel_distance / mode_speed_string[my_mode_actual];
	float my_aspiration <- rnd(1.0);
	
	list<inhabitants> my_peers;
	
	//buildings home;
	
	buildings my_home <- one_of(buildings where (each.use = "residential"));
	// check location below  if any error, this could be a possible error in rare cases
	point location <- my_home.location;
	buildings my_office <- one_of(buildings where (each.use = "office"));
	bool has_peers <- false;
	
	

	//ATTRIBUTES FOR NEEDS
	float my_need_social;
	float my_need_personal;
	float my_need_existence;
	float my_overall_needs_satisfaction;
	float superior_to_peers_ratio;
	float inhabitant_existence_need_satisfaction     ;
	float inhabitant_overall_need_satisfaction_aspiration_level_ratio;


	// uncertainty variables
	
	map<string, float> my_uncertainty;
	float inhabitant_uncertainty_ratio;

 list<float> memory_bike_times ;
 list<float> memory_walk_times;
 list<float> memory_pt_times ;
 list<float> memory_auto_times ;
 list<float> memory_all_modes; // list of 5
 map<string,float> my_expected_travel_time_all_modes <- ["bike"::0.0,"walk"::0.0,"pt"::0.0, "car"::0.0];
 map<string,float> my_uncertainty_travel_time_all_modes <- ["bike"::0.0,"walk"::0.0,"pt"::0.0, "car"::0.0];






	
	
	
	
	
	reflex get_inhabitant_behavior{
		//my_behavior <- get_behavior(self);
	}
	
	


//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//																																     //
//									                           PEERS  MODEL													        			     //
//																																     //
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

	
//------------------------------------------------------------GET PEERS ----------------------------------------------------------
	list<inhabitants> get_peers (list<inhabitants> possible_peers, float home_distance <- 2000, float office_office_distance <- 250)
	{
		possible_peers <- (possible_peers) - self;
		map<inhabitants, float> relative_diff_mode_preferred;
		map<inhabitants, float> relative_diff_mode_actual;
		map<inhabitants, float> relative_diff_home_office_distance;
		map<inhabitants, float> relative_diff_home_home_distance;
		map<inhabitants, float> relative_diff_office_office_distance;
		loop pp over: possible_peers // pp short for possible peer

		{

		// CRITERIA 1 - DIFFERENCES IN PREFERRED MODES
			switch abs(self.value_mode_preferred - pp.value_mode_preferred)
			{
				match 0
				{
					add pp::0 to: relative_diff_mode_preferred;
				}

				match 1
				{
					add pp::0.33 to: relative_diff_mode_preferred;
				}

				match 2
				{
					add pp::0.67 to: relative_diff_mode_preferred;
				}

				match 3
				{
					add pp::1 to: relative_diff_mode_preferred;
				}

			}

			// CRITERIA 2 - DIFFERENCES IN ACTUAL MODES
			switch abs(self.value_mode_actual - pp.value_mode_actual)
			{
				match 0
				{
					add pp::0 to: relative_diff_mode_actual;
				}

				match 1
				{
					add pp::0.33 to: relative_diff_mode_actual;
				}

				match 2
				{
					add pp::0.67 to: relative_diff_mode_actual;
				}

				match 3
				{
					add pp::1 to: relative_diff_mode_actual;
				}

			}

			// CRITERIA 3 - DISTANCE BETWEEN INHABITANT'S HOME AND PEER'S HOME 
			if distance_to(self.my_home, pp.my_home) < home_distance
			{
				float d <- distance_to(self.my_home, pp.my_home);
				//write d;
				add pp::(d / home_distance) to: relative_diff_home_home_distance;
			} else
			{
				add pp::1 to: relative_diff_home_home_distance;
			}

			// CRITERIA 4 - RELATIVE HOME-WORK DISTANCES ; if potential peer travels similar distance, I am more attached to this peer's behavior
			float my_home_office_distance <- distance_to(self.my_home, self.my_office);
			if distance_to(pp.my_home, pp.my_office) < my_home_office_distance
			{
				float d <- distance_to(pp.my_home, pp.my_office) / my_home_office_distance;
				//write d;
				add pp::(1 - d) to: relative_diff_home_office_distance;
			} else
			{
				add pp::1 to: relative_diff_home_office_distance;
			}

			// CRITERIA 5 - IF AGENTS ARE WORKING CLOSE TO EACH OTHER, SAY WITHIN 250m, they more likely to be peers.
			float my_office_peer_office_distance <- distance_to(self.my_office, pp.my_office);
			if my_office_peer_office_distance < office_office_distance
			{
				float d <- distance_to(self.my_office, pp.my_office) / office_office_distance;
				add pp::d to: relative_diff_office_office_distance;
			} else
			{
				add pp::1 to: relative_diff_office_office_distance;
			}

		}
		//		write "============================";
		// write relative_diff_home_home_distance;
		// write relative_diff_mode_preferred;
		// write relative_diff_mode_actual;
		// write relative_diff_home_office_distance;
		// write relative_diff_office_office_distance;
		// 

		// ADD ALL CRITERIA TOGETHER INTO AN INDEX final_score
		map<inhabitants, float> final_score;
		loop i over: relative_diff_home_home_distance.keys
		{
			add
			i::(relative_diff_home_home_distance[i] + relative_diff_mode_preferred[i] + relative_diff_mode_actual[i] + relative_diff_home_office_distance[i] + relative_diff_office_office_distance[i])
			to: final_score;
		}

		//write "==================FINAL SCORE ============";
		//write final_score;
		my_peers <- first(5, final_score.keys sort_by (final_score[each]));
		has_peers <- length(my_peers)>0?true:false;
		save [cycle, self.name, my_peers] to: "../output/my_peers.csv" type: "csv" rewrite: false;
		return my_peers;
	}





//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//																																     //
//									                       2.     NEEDS MODEL													        			     //
//																																     //
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------//



//------------------------------------------------------------2A CALCULATE SIMILARITY ----------------------------------------------------------


	float calculate_similarity (list<inhabitants> _peers)
	{
		
		//write self.value_actual_mode; // DEBUG STATEMENTS
		//write self.my_peers collect each.value_actual_mode; //DEBUG STATEMENTS
		list<float> difference_with_my_peers <- (_peers collect (abs(each.value_mode_actual - self.value_mode_actual))) collect (each/max_travel_mode_difference); //absolute difference
		//write difference_with_my_peers;
		if sum(difference_with_my_peers) = 0{
			superior_to_peers_ratio <-  0.0;
		} else {
			superior_to_peers_ratio<-  sum(difference_with_my_peers)/length(_peers);
		}
		return superior_to_peers_ratio;
	}
			
//------------------------------------------------------------ 2B CALCULATE SUPERIORITY ----------------------------------------------------------
//TODO check for travel speed and travel distance conflicts, currently it is all random numbers

	float calculate_superiority(list<inhabitants> _peers)
	{

		list<float> difference_with_my_peers <- _peers collect (each.my_travel_time - self.my_travel_time);
		//write difference_with_my_peers;
		if my_travel_time > mean(_peers collect (each.my_travel_time)){
			return 0.0;
		}
		else{
			return self.my_travel_time/mean(_peers collect (each.my_travel_time));
		}
	}



//------------------------------------------------------------SOCIAL NEEDS ----------------------------------------------------------



	action calculate_social_need_satisfaction
	{
		float similarity_value;
		similarity_value<- calculate_similarity(my_peers);
		float superiority_value;
		superiority_value <- calculate_superiority(my_peers);
		my_need_social <- (similarity_value + superiority_value)/2;
		//write my_need_social;
	}
	
	
	
	
	
//------------------------------------------------------------3. PERSONAL NEEDS ----------------------------------------------------------
//FIXME i have set max mode difference to 3, because modes range from [1-4]
	float calculate_personal_need_satisfaction
	{

		float relative_diff_to_current_peers_travel_mode <-value_mode_preferred - value_mode_actual = 0?0.0:(abs(value_mode_preferred-value_mode_actual)/3.0);
		my_need_personal <- relative_diff_to_current_peers_travel_mode;
		return relative_diff_to_current_peers_travel_mode;
		}




//FIXME you have to add last day travel experience to your all_mode memory;
//------------------------------------------------------------4. EXISTENCE  NEEDS ----------------------------------------------------------
// This is based on speed calculations, if I travel faster than average travel time in last 5 days, i am satisfied in existence need.
		float avg_my_last_5_days_travel_time ;
		float my_last_day_travel_time;


	action calculate_existence_need_satisfaction (inhabitants i)
	{
		write "inside existence \t"+ i.memory_all_modes;
		 avg_my_last_5_days_travel_time <- mean(i.memory_all_modes);
		 my_last_day_travel_time <- i.memory_all_modes[cognitive_effort-1];
		if my_last_day_travel_time <= avg_my_last_5_days_travel_time{
			inhabitant_existence_need_satisfaction    <- 0.0;
		} 
				else {
			inhabitant_existence_need_satisfaction     <- float(int(my_last_day_travel_time/avg_my_last_5_days_travel_time)); 
			//FIXME for now this is almost always 1, need to fix. 
		}
	}




//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//																																     //
//									                          5. TOTAL NEEDS CALCULATION &  RATIO											  	     //
//																																     //
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------//


action calculate_overall_need_satisfaction {
	my_overall_needs_satisfaction <- (inhabitant_relative_importance_existence_need * inhabitant_existence_need_satisfaction)+
									 (inhabitant_relative_importance_personal_need * my_need_personal)+
									 (inhabitant_relative_importance_social_need * my_need_social);
}

action calculate_relative_overall_need_satisfaction {
	
    if ( ( 1 - my_overall_needs_satisfaction )  >  my_aspiration) {
    	inhabitant_overall_need_satisfaction_aspiration_level_ratio   <-  0.75;
    }
        else {
        	inhabitant_overall_need_satisfaction_aspiration_level_ratio  <-  0.25;
        }
  }





//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//																																   					  //
//									                           6. UNCERTAINTY CALCULATIONS and RATIO											   		        //
//																																				        //
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------//


// Agents have uncertainty from 1) difference between their travel speed expectation and that of their peers 2) difference between their current travel mode and their peers.
//calculation factor 1
//

 

 //function to assign initial memory of travel times
 action assign_initial_cognitive_memory{
	
  memory_bike_times <-list_with(cognitive_effort,distance_between(topology(world),[my_home, my_office])/rnd(mode_speed_string["bike"]+2,mode_speed_string["bike"]-2));
  memory_walk_times <-list_with(cognitive_effort, distance_between(topology(world),[my_home, my_office])/rnd(mode_speed_string["walk"]+1,mode_speed_string["walk"]-1));
  memory_pt_times <-list_with(cognitive_effort, distance_between(topology(world),[my_home, my_office])/rnd(mode_speed_string["pt"]+15,mode_speed_string["pt"]-15));
  memory_auto_times <-list_with(cognitive_effort,distance_between(topology(world),[my_home, my_office])/rnd(mode_speed_string["car"]+10,mode_speed_string["car"]-10));
  memory_all_modes <- memory_auto_times;
  write memory_all_modes;
}
 
 // function to get travel time for a given mode = expected travel time for next trip as per the model
 float get_expected_travel_time_for_a_mode (inhabitants i, int mode)
{
	float travel_time;
	switch mode
	{
		match 1
		{
			travel_time <- gauss(mean(i.memory_bike_times), standard_deviation(i.memory_bike_times));
		}

		match 2
		{
			travel_time <- gauss(mean(i.memory_walk_times), standard_deviation(i.memory_walk_times));
		}

		match 3
		{
			travel_time <- gauss(mean(i.memory_pt_times), standard_deviation(i.memory_pt_times));
		}

		match 4
		{
			travel_time <- gauss(mean(i.memory_auto_times), standard_deviation(i.memory_auto_times));
		}
	}
	return travel_time;
}

//function to get expected time for all modes, argument = self
map get_expected_travel_time_for_all_modes (inhabitants i)
{
	map<string, float> expected_travel_time_all_modes;
	expected_travel_time_all_modes["bike"] <- gauss(mean(i.memory_bike_times), standard_deviation(i.memory_bike_times));
	expected_travel_time_all_modes["walk"] <- gauss(mean(i.memory_walk_times), standard_deviation(i.memory_walk_times));
	expected_travel_time_all_modes["pt"] <- gauss(mean(i.memory_pt_times), standard_deviation(i.memory_pt_times));
	expected_travel_time_all_modes["car"] <- gauss(mean(i.memory_auto_times), standard_deviation(i.memory_auto_times));
	return expected_travel_time_all_modes;
}

//function to get uncertainty factor for travel times for all modes, argument = self
map get_uncertainty_travel_time_for_all_modes (inhabitants i){
	map<string, float> my_uncertainty_cov;
	
	list<float> peers_and_self_travel_time_bike <-i.my_peers accumulate (each.my_expected_travel_time_all_modes["bike"]);
	add i.my_expected_travel_time_all_modes["bike"] to:peers_and_self_travel_time_bike;
	my_uncertainty_cov["bike"]<-standard_deviation(peers_and_self_travel_time_bike)/mean(peers_and_self_travel_time_bike);
	
	list<float> peers_and_self_travel_time_walk <-i.my_peers accumulate (each.my_expected_travel_time_all_modes["bike"]);
	add i.my_expected_travel_time_all_modes["bike"] to:peers_and_self_travel_time_walk;
	my_uncertainty_cov["walk"]<-standard_deviation(peers_and_self_travel_time_walk)/mean(peers_and_self_travel_time_walk);
	
	list<float> peers_and_self_travel_time_pt <-i.my_peers accumulate (each.my_expected_travel_time_all_modes["bike"]);
	add i.my_expected_travel_time_all_modes["bike"] to:peers_and_self_travel_time_pt;
	my_uncertainty_cov["pt"]<-standard_deviation(peers_and_self_travel_time_pt)/mean(peers_and_self_travel_time_pt);
	
	list<float> peers_and_self_travel_time_car <-i.my_peers accumulate (each.my_expected_travel_time_all_modes["bike"]);
	add i.my_expected_travel_time_all_modes["bike"] to:peers_and_self_travel_time_car;
	my_uncertainty_cov["car"]<-standard_deviation(peers_and_self_travel_time_car)/mean(peers_and_self_travel_time_car);
	
	return my_uncertainty_cov; //send this to my_uncertainty
}
 
 

 
 
// for this function, you need to send an argument in string , which in this case is coming from my_uncertainty
action calculate_ratio_uncertainty_uncertainty_tolerance_level (string s){
	if (my_uncertainty[s] > uncertainty_tolerance_level)
	{
		inhabitant_uncertainty_ratio <- 0.75;
	} 
	else {
		inhabitant_uncertainty_ratio <-0.25;
	}
}




//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//																																     //
//									                           7. BEHAVIOR MODEL												        			     //
//																																     //
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

// ATTRIBUTES FOR BEHAVIOR STRATEGY
	float overall_need_satisfaction_aspiration_level_ratio;
	float uncertainty_tolerance_level_ratio;
	string my_behavior;
	
	list<float> my_optimize_all_mode;
	map<int,list<float>> inquiry_per_mode;
	
	//------------------- IMITATE (parameter coming into this function = self)
	// what does it do? = adopts the mode that is most used by peers
	int imitates (inhabitants i){
		int mode;
		// what are peers doing;
		list<int> peer_modes <- i.my_peers collect (each.value_mode_actual);
		map<int, list<int>> m <- group_by(peer_modes, (each));
		list<int> counts <- m.values accumulate length(each);
		mode <- m.keys at (counts index_of max(counts)); //get the most used mode.
		return mode;
	}
	
	
	//-------------------  REPEAT  ( parameter coming into this function  = self)
	// what does it do ? = just continues with the mode from previous step 
	int repeats (inhabitants i){
		int mode <- i.value_mode_actual;
		return mode;
	}
	
	//------------------- INQUIRE ( parameter coming into this function  = self) 
	// what does it do? it first lists all the modes being used by the population, then checks what is more suitable than current choice
	 int inquires (inhabitants i){
	 	int mode;
		
		list<int> peer_modes <- (remove_duplicates(i.my_peers collect (each.value_mode_actual)))-i.my_mode_actual;// what are peers using;
//FIXME does inhabitant evaluate also own mode here or only of the peers? 		
		
		if !empty(peer_modes){
			loop ii over: peer_modes{
			list<float> my_inquiry_each_mode_used ;
			add sub_potential_PERSONAL_need_satisfaction(self, ii) to:my_inquiry_each_mode_used;
			add sub_potential_EXISTENCE_need_satisfaction(self, ii) to:my_inquiry_each_mode_used;
			add sub_potential_SOCIAL_need_satisfaction(self, ii) to:my_inquiry_each_mode_used;
			add sub_potential_OVERALL_need_satisfaction(self, ii) to:my_inquiry_each_mode_used;
			inquiry_per_mode[ii] <- my_inquiry_each_mode_used; // maps a mode to four sub-procedure results eg. 1::[1,2,3,4]
		}
		} else {
			warn "Agent " + i +  "has no peers to inspire";
		}
		
		
		return 10; //FIXME correct this return value 	
	 }
	
	
	//------------------- OPTIMIZE ( parameter coming into this function  = self) 
	// what does it do? = it collects all possible choices (used or unused) by the population, then check what is more suitable than current choice
	
	
	//FIXME 	how can we get relative_speed_per_mode if an agent never travelled using a particular mode ? In this model this is replaced by avg_my_last_5_days_travel_time
	
	
	// SUB PROCEDURES
	// input to this function is agent and mode number
	list<float> inhabitant_expected_relative_travel_speed_travel_mode;//will contain values for modes 1,2,3,4
	float inhabitant_potential_existence_need_satisfaction;
	float inhabitant_potential_social_need_satisfaction_travel;
	float inhabitant_potential_personal_need_satisfaction_travel;
	

	float sub_potential_PERSONAL_need_satisfaction (inhabitants i, int mode){
		float potential_personal_need_statisfaction;
		if (abs(mode - i.value_mode_preferred) = 0){
			 potential_personal_need_statisfaction <- 0.0;
			}
			else {
				 potential_personal_need_statisfaction <- abs( mode - i.value_mode_preferred)/3.0;
			}
			return potential_personal_need_statisfaction;
	}

	
	
	float sub_potential_SOCIAL_need_satisfaction (inhabitants i, int mode){
		float potential_similarity_with_travel_mode <- length(i.my_peers where (each.value_mode_actual = mode))/ length(i.my_peers);
		inhabitant_potential_social_need_satisfaction_travel <- (potential_similarity_with_travel_mode + i.superior_to_peers_ratio)/2.0;
		return inhabitant_potential_social_need_satisfaction_travel;
	}
	
	
	
	float sub_potential_EXISTENCE_need_satisfaction(inhabitants i, int mode){
		inhabitant_expected_relative_travel_speed_travel_mode[mode]<- world.get_linear_forecast(i.memory_all_modes, mode);
		if inhabitant_expected_relative_travel_speed_travel_mode[mode] <= avg_my_last_5_days_travel_time{
			inhabitant_potential_existence_need_satisfaction <-0.0;
		}
		else {
			inhabitant_potential_existence_need_satisfaction <- inhabitant_expected_relative_travel_speed_travel_mode[mode]/mode_speed_int[mode];
		}
		
		return inhabitant_potential_existence_need_satisfaction;
	}
	
	float sub_potential_OVERALL_need_satisfaction(inhabitants i, int mode){
		float inhabitants_potential_overall_need_satisfaction <- 
		(inhabitant_relative_importance_existence_need * inhabitant_potential_existence_need_satisfaction)
		+(inhabitant_relative_importance_social_need * inhabitant_potential_social_need_satisfaction_travel)
		+(inhabitant_relative_importance_personal_need * inhabitant_potential_personal_need_satisfaction_travel);
		return inhabitants_potential_overall_need_satisfaction;
	}


 







init
	{
	//do select_peers;
		do get_peers(list(inhabitants), distance_between_homes, relative_work_work_distance);
		do assign_initial_cognitive_memory;
		write self.memory_all_modes;
		do calculate_social_need_satisfaction ;
		my_need_personal <- calculate_personal_need_satisfaction();
		write self.memory_all_modes;
		do calculate_existence_need_satisfaction(self);
		//my_overall_needs_satisfaction <- 1.0;
		write world.get_behavior(overall_need_satisfaction_aspiration_level_ratio,uncertainty_tolerance_level_ratio);
	}





//------------------------------------------------------------ASPECTS ----------------------------------------------------------
	aspect a
	{
		if !empty(my_peers)
		{
			//draw circle(50) color: rgb(# blue, 0.2) empty: true;
//			draw circle(20) color: rgb(((modes index_of my_mode_actual) + 10) * 60, 100, 100);
draw circle(50) color:#red;
			//draw string(int(self)) color: # white font: font('Helvetica Neue', 12, # bold + # italic);
			ask my_peers
			{
				draw line([self, myself]) color: (# green) ;
			}

		} else
		{
			draw circle(50) color:#red;
			//draw circle(20) color: rgb((modes index_of (my_mode_actual)) * 60, 0, 0);
			//draw string(int(self)) color: # white font: font('Helvetica Neue', 12, # bold);
		}
	}

}




// 																EXPERIMENT SECTION
//------------------------------------------------------------------------------------------
experiment "Main Model" type: gui
{
	float seed <- 0.8484812926428652;
	parameter "Proportion of offices in landuse" var: proportion_of_offices min: 0.0 max: 1.0 step: 0.1 category: "Global Model Parameters";
	parameter "Total inhabitant population" var: inhabitant_population min: 1 max: 1000 step: 100 category: "Global Model Parameters";
	parameter "Work 2 Work distance" var: relative_work_work_distance min: 1.0 max: 20000.0 step: 100 category: "Peer Calculations";
	parameter "Distance between peer homes" var: distance_between_homes min: 1.0 max: 5000.0 step: 100 category: "Peer Calculations";
	/** Insert here the definition of the input and output of the model */
	output
	{
		display d type: opengl
		{
			species study_area aspect: a;
			species buildings aspect: a;
			species roads aspect: a;
			species inhabitants aspect: a position: { 0, 0, 0.051 };
		}

	}

}