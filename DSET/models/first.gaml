/**
* Name: model1
* Author: Srirama Bhamidipati
* Description: 
* Tags: Tag1, Tag2, TagN
* draw string("Off_" + int(self)) color: # white font: font('Helvetica Neue', 12, # bold + # italic);
*/
model model1
//import "dset_functions_library.gaml"
import "behavior.gaml"
//import "ptModel.gaml"

global
{
	
	
	
date starting_date <- date("2018-03-20 00:00:01");
float step <-1 #mn;
bool inverse_speed <-true;
bool expected_linear <- true;



// THE ENVIRONMENT 
	file shape_file_streets <- file('../includes/roads/network_extended_RD.shp');
	file shape_file_bounds <- file("../includes/Boundary_study_area_rough.shp");
	file shape_buildings <- file("../includes/Buildings_Amsterdam.shp");
	geometry shape <- envelope(shape_buildings);

	// variables for model parameters
	float proportion_of_offices <- 0.1;
	float distance_between_homes <- 2000.0;
	float relative_work_work_distance <- 3000.0;
	int inhabitant_population <- 100;
//TODO check if this below  should be global or agent specific
	float max_travel_mode_difference <-3.0;
	
	
// THIS WILL BE THE GRAPH ON WHICH INHABITANTS WILL TRAVEL

	graph g ;
	
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
	map<string, float> mode_speed_string <- ["bike"::4.1, "walk"::1.1, "pt"::8.3, "car"::16.6]; //speeds in m/s
	
	map<int, float> mode_speed_int <- [1::4.1, 2::1.1, 3::8.3, 4::16.6];
	map<string, int> mode_value <- ["bike"::1, "walk"::2, "pt"::3, "car"::4]; // integer identifier for mode
	
	
	init
	{
		if inverse_speed {
		 mode_speed_int <- [1::1/4.1, 2::1/1.1, 3::1/8.3, 4::1/16.6];
		}
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
		
		
	
		
		
		 g <- as_edge_graph(shape_file_streets);
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
		draw shape+3 color: # gray;
	}
}

species study_area
{
	aspect a
	{
		draw shape color: rgb(# wheat, 0.1);
	}
}

species inhabitants schedules: shuffle(inhabitants) skills:[moving]
{
	
// GLOBAL ATTRIBUTES FOR EACH AGENT
float ambition_level <- rnd(1.0);
float uncertainty_tolerance_level <- rnd(1.0);
int cognitive_effort <- 5;
float my_aspiration <- rnd(1.0);

	
// TRAVEL ATTRIBUTES
	string my_mode_preferred <- one_of(modes);
	string my_mode_actual <- one_of(modes);
	int value_mode_preferred <- mode_value[my_mode_preferred];
	int value_mode_actual <- mode_value[my_mode_actual];
	
	
	
//FIXME  these two below need to change to network characteristics, when we have a clean network
	float my_travel_distance <- rnd(1.0,10.0);
	float my_travel_time <- my_travel_distance / mode_speed_string[my_mode_actual];
	
	
	
	
	list<inhabitants> my_peers;
	bool has_peers <- false;
	
	//buildings home;
	
	buildings my_home <- one_of(buildings where (each.use = "residential"));
	point location <- my_home.location;
	buildings my_office <- one_of(buildings where (each.use = "office"));
	
	
	
	

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


	// COGNITIVE MEMORY
	 list<float> memory_bike_times ;
	 list<float> memory_walk_times;
	 list<float> memory_pt_times ;
	 list<float> memory_car_times ;
	 map<int, list<float>> mode_specific_memory ;//<- [1::memory_bike_times, 2::memory_walk_times, 3::memory_pt_times, 4::memory_car_times];
	 list<float> memory_all_modes; // list of 5
	 map<string,float> my_expected_travel_time_all_modes <- ["bike"::0.0,"walk"::0.0,"pt"::0.0, "car"::0.0];
	 map<string,float> my_uncertainty_travel_time_all_modes <- ["bike"::0.0,"walk"::0.0,"pt"::0.0, "car"::0.0];
	string behavior;



	// TIME VARIABLES
	list<int> mhdt ; //morning home departure time , used in this format just to use a guassian function
	date my_morning_home_depart_time ;//<-my_morning_home_depart_time[0]+(my_morning_home_depart_time[1]/60)*100;
	date my_morning_office_arrive_time;
	float my_morning_travel_time;
	date my_evening_travel_time;
	
	
	date my_evening_home_arrive_time;
	date my_evening_office_depart_time;
	list<int> eodt ; //evening office departure time , used in this format just to use a guassian function
	
	
	
	
	
	

	
	


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



	float calculate_social_need_satisfaction (inhabitants i)
	{
		float similarity_value;
		similarity_value<- calculate_similarity(i.my_peers);
		float superiority_value;
		superiority_value <- calculate_superiority(i.my_peers);
		//my_need_social <- (similarity_value + superiority_value)/2;
		return (similarity_value + superiority_value)/2;
	}
	
	
	
	
	
//------------------------------------------------------------3. PERSONAL NEEDS ----------------------------------------------------------
//FIXME i have set max mode difference to 3, because modes range from [1-4]
	float calculate_personal_need_satisfaction(inhabitants i)
	{

		float relative_diff_to_current_peers_travel_mode <-i.value_mode_preferred - i.value_mode_actual = 0?0.0:(abs(i.value_mode_preferred-i.value_mode_actual)/3.0);
		my_need_personal <- relative_diff_to_current_peers_travel_mode;
		return relative_diff_to_current_peers_travel_mode;
		}





//FIXME i am bit skeptical on this code  flow for existence flow
//------------------------------------------------------------4. EXISTENCE  NEEDS ----------------------------------------------------------
// This is based on speed calculations, if I travel faster than average travel time in last 5 days, i am satisfied in existence need.
		float avg_my_last_5_days_travel_time ;
		float my_last_day_travel_time;
		float avg_my_last_5_days_travel_time_mode_spefiic;

	float calculate_existence_need_satisfaction (inhabitants i)
	{
		//write "inside existence \t"+ i.memory_all_modes;
		 avg_my_last_5_days_travel_time_mode_spefiic <- mean(i.mode_specific_memory[i.value_mode_actual]);
		 // get last value in the list of mode specific travel time list 
		 my_last_day_travel_time <- i.mode_specific_memory[i.value_mode_actual][cognitive_effort-1];
		if my_last_day_travel_time <= avg_my_last_5_days_travel_time_mode_spefiic{
			inhabitant_existence_need_satisfaction    <- 0.0;
		} 
				else {
			inhabitant_existence_need_satisfaction     <- float(int(my_last_day_travel_time/avg_my_last_5_days_travel_time_mode_spefiic)); 
			//FIXME for now this is almost always 1, need to fix. 
		}
		
		return inhabitant_existence_need_satisfaction;
	}




//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//																																     //
//									                          5. TOTAL NEEDS CALCULATION &  RATIO											  	     //
//																																     //
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------//


float calculate_overall_need_satisfaction {
	float a <- (inhabitant_relative_importance_existence_need * inhabitant_existence_need_satisfaction)+
									 (inhabitant_relative_importance_personal_need * my_need_personal)+
									 (inhabitant_relative_importance_social_need * my_need_social);
									 
									 return a;
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
  memory_car_times <-list_with(cognitive_effort,distance_between(topology(world),[my_home, my_office])/rnd(mode_speed_string["car"]+10,mode_speed_string["car"]-10));
  
  
  mode_specific_memory <- [1::memory_bike_times, 2::memory_walk_times, 3::memory_pt_times, 4::memory_car_times];
  //write mode_specific_memory;
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
		write "imitates inhabitant" + i;
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
		write "repeats inhabitant" + i;
		int mode <- i.value_mode_actual;
		return mode;
	}
	
	//------------------- INQUIRE ( parameter coming into this function  = self) 
	// what does it do? it first lists all the modes being used by the population, then checks what is more suitable than current choice
	 int inquires (inhabitants i){
	 	int mode;
		write "inquiring inhabitant" + i;
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
		
		
		return (inquiry_per_mode.pairs with_max_of(each.value[3])).key; //FIXME correct this return value 	
	 }
	
	
	//------------------- OPTIMIZE ( parameter coming into this function  = self) 
	// what does it do? = it collects all possible choices (used or unused) by the population, then check what is more suitable than current choice
	
	 int optimizes (inhabitants i){
	 	int mode;
		write "optimizes inhabitant" + i;
		list<int> peer_modes <- [1,2,3,4];// what are peers using;
//FIXME does inhabitant evaluate also own mode here or only of the peers? 		
		
		if !empty(peer_modes){
			loop ii over: peer_modes{
			list<float> my_inquiry_each_mode_used  ;// <-[];
			add sub_potential_PERSONAL_need_satisfaction(i, ii) to:my_inquiry_each_mode_used;
			write my_inquiry_each_mode_used;
			add sub_potential_EXISTENCE_need_satisfaction(i, ii) to:my_inquiry_each_mode_used;
			write my_inquiry_each_mode_used;
			add sub_potential_SOCIAL_need_satisfaction(i, ii) to:my_inquiry_each_mode_used;
			write my_inquiry_each_mode_used;
			add sub_potential_OVERALL_need_satisfaction(i, ii) to:my_inquiry_each_mode_used;
			write my_inquiry_each_mode_used;
			inquiry_per_mode[ii] <- my_inquiry_each_mode_used; // maps a mode to four sub-procedure results eg. 1::[1,2,3,4]
			
		}write inquiry_per_mode;
		} else {
			warn "Agent " + i +  "has no peers to optimize";
		}
		
		
		return (inquiry_per_mode.pairs with_max_of(each.value[3])).key; //FIXME correct this return value 	
	 }
	
	// SUB PROCEDURES
	// input to this function is agent and mode number
	list<float> inhabitant_expected_relative_travel_speed_travel_mode<-[0,0,0,0.0];//will contain values for modes 1,2,3,4
	float inhabitant_potential_existence_need_satisfaction;
	float inhabitant_potential_social_need_satisfaction_travel;
	float inhabitant_potential_personal_need_satisfaction_travel;
	

	float sub_potential_PERSONAL_need_satisfaction (inhabitants i, int mode){
		write "i entered personal need " + i +" with mode "+mode;
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
		write "i entered social need  " + i +" with mode "+mode;
		float potential_similarity_with_travel_mode <- length(i.my_peers where (each.value_mode_actual = mode))/ length(i.my_peers);
		inhabitant_potential_social_need_satisfaction_travel <- (potential_similarity_with_travel_mode + i.superior_to_peers_ratio)/2.0;
		return inhabitant_potential_social_need_satisfaction_travel;
	}
	
	

	float sub_potential_EXISTENCE_need_satisfaction(inhabitants i, int mode){
		//inhabitant_expected_relative_travel_speed_travel_mode[mode]<- get_linear_forecast(i.mode_specific_memory[mode], mode);
		write "i entered sub existence need " + i +" with mode "+mode;
		if expected_linear{
			inhabitant_expected_relative_travel_speed_travel_mode[mode-1]<- get_linear_forecast(i.mode_specific_memory[mode], mode);
		} 
		else{
			inhabitant_expected_relative_travel_speed_travel_mode[mode-1]<- get_new_expected_value(i.mode_specific_memory[mode], mode);
		}
		
		write "prediction --->" + inhabitant_expected_relative_travel_speed_travel_mode[mode-1];
		if inhabitant_expected_relative_travel_speed_travel_mode[mode-1] <= avg_my_last_5_days_travel_time_mode_spefiic{
			inhabitant_potential_existence_need_satisfaction <-0.0;
		}
		else {
			inhabitant_potential_existence_need_satisfaction <- inhabitant_expected_relative_travel_speed_travel_mode[mode-1]/mode_speed_int[mode];
		}
		
		return inhabitant_potential_existence_need_satisfaction;
	}
	
	float sub_potential_OVERALL_need_satisfaction(inhabitants i, int mode){
		write "i entered overall need " + i + " with mode "+mode;
		float inhabitants_potential_overall_need_satisfaction <- 
		(inhabitant_relative_importance_existence_need * inhabitant_potential_existence_need_satisfaction)
		+(inhabitant_relative_importance_social_need * inhabitant_potential_social_need_satisfaction_travel)
		+(inhabitant_relative_importance_personal_need * inhabitant_potential_personal_need_satisfaction_travel);
		return inhabitants_potential_overall_need_satisfaction;
	}

	float get_linear_forecast(list<float> f, int mode_number){
		
		matrix<float> data_matrix <- 0.0 as_matrix {2,length(f)};
		loop i from: 0 to: length(f) -1 {
			
			data_matrix[1,i] <- i;
			
			data_matrix[0,i] <- f[i];
		}
		//write data_matrix;
		if mode_number = ""{
			warn "No mode defined in call to linear forecast";
		}
		regression my_regression_model  <- build(data_matrix);
		//write my_regression_model;
		float my_prediction <-  predict(my_regression_model, [length(f)]);
		write "i am inhabitant"+ int(self)+ " using mode " + string(mode_number) + "_ " + my_prediction;
		return my_prediction;
	}
	
	
	
	float get_new_expected_value(list<float> f, int mode_number){
		float my_pred;
		my_pred <- gauss(mean(f), standard_deviation(f));
		write "inside function to get expected value " + my_pred;
		
		return my_pred;
	}
 

	list<int> get_morning_departure_time{
	
	int morning_hour <-int(gauss(8,0.5));
	int morning_minute <- int(rnd(0,60));
	return [morning_hour, morning_minute];
	}


	list<int> get_evening_departure_time{
	
	int evening_hour <-int(gauss(17,1));
	int evening_minute <- int(rnd(0,60));
	return [evening_hour, evening_minute];
	}




init
	{
	//do select_peers;
		
		do assign_initial_cognitive_memory;
		write "initial memory assigned for agent " +int(self);
		
	}


	action execute_a_behavior (string this_behavior){
		
		switch this_behavior{
			match "repeat"{
				value_mode_actual<- repeats(self);
			}
			
			
			match "imitate"{
				value_mode_actual <- imitates(self);
			}
			
			match "inquire"{
				value_mode_actual <- inquires(self);
			}
			
			match "optimize"{
				value_mode_actual <- optimizes(self);
			}
		}
	}



	reflex every_day when:every(#day){
	
	
	
	if current_date.day_of_week <6{ 
		// inside if is weekday behavior
		mhdt <- get_morning_departure_time();
		//mdt <-mdt[0]+(mdt[1]/60)*100;
		eodt <- get_evening_departure_time();
		
	}
	
	else {
		// inside else  is weekend behavior;
	}
	
	
	
		//GET PEERS
		do get_peers(list(inhabitants), distance_between_homes, relative_work_work_distance);
		
		//NEED CALCULATIONS
		my_need_social <- calculate_social_need_satisfaction(self) ;
		my_need_personal <- calculate_personal_need_satisfaction(self);
		my_need_existence <- calculate_existence_need_satisfaction(self);
		my_overall_needs_satisfaction <- calculate_overall_need_satisfaction();
		
		//UNCERTAINTY
		
		
		// BEHAVIOR
		 behavior <- world.choose_behavior(overall_need_satisfaction_aspiration_level_ratio,uncertainty_tolerance_level_ratio);
		write "behavior = " + behavior;
		do execute_a_behavior(behavior);
		
		
		
	}


	reflex every_morning when:current_date.hour = mhdt[0] and current_date.minute = mhdt[1] and !(my_office covers location) and current_date.day_of_week <6
	{
		
		my_morning_home_depart_time <-current_date;
		do morning_movement;
		
	}
	
	
	reflex every_evening when:current_date.hour = my_evening_office_depart_time[0] and current_date.minute = my_evening_office_depart_time[1] and !(my_home covers location) and current_date.day_of_week <6
	{
		do evening_movement;
	}
	
	action morning_movement {
	float my_speed <- mode_speed_int[self.value_mode_actual] #km/#h;
	do goto target:my_office on:g speed:my_speed;
	if location = my_office.location{
		my_morning_office_arrive_time <- current_date;
		my_morning_travel_time <- my_morning_office_arrive_time - my_morning_home_depart_time;
	}
	}

	action evening_movement {
	float my_speed <- mode_speed_int[self.value_mode_actual] #km/#h;
	do goto target:my_home on:g speed:my_speed;
	if location = my_home.location{
		my_evening_home_arrive_time <- current_date;
	}
	}




//------------------------------------------------------------ASPECTS ----------------------------------------------------------
	aspect a
	{
		if !empty(my_peers)
		{
			//draw circle(50) color: rgb(# blue, 0.2) empty: true;
//			draw circle(20) color: rgb(((modes index_of my_mode_actual) + 10) * 60, 100, 100);
	draw circle(mode_speed_int[self.value_mode_actual]*5) color:#red;
			//draw string(int(self)) color: # white font: font('Helvetica Neue', 12, # bold + # italic);
			ask my_peers
			{
				//draw line([self, myself]) color: (# green) ;
			}

		} else
		{
			draw circle(mode_speed_int[self.value_mode_actual]*4) color:#cyan;
			
			//draw circle(20) color: rgb((modes index_of (my_mode_actual)) * 60, 0, 0);
			//draw string(int(self)) color: # white font: font('Helvetica Neue', 12, # bold);
		}
	}
	
	aspect b{
		draw link(self, my_office) color:#red size:10;
	}

}




// 																EXPERIMENT SECTION
//------------------------------------------------------------------------------------------
experiment "Main Model" type: gui
{
	float seed <- 0.8484812926428652;
	parameter "Proportion of offices in landuse" var: proportion_of_offices min: 0.0 max: 1.0 step: 0.1 category: "Global Model Parameters";
	parameter "Inverse speed" var:inverse_speed category: "Clarify";
	parameter "Linear Forecast" var:expected_linear category: "Clarify";
	parameter "Total inhabitant population" var: inhabitant_population min: 1 max: 1000 step: 100 category: "Global Model Parameters";
	parameter "Work 2 Work distance" var: relative_work_work_distance min: 1.0 max: 20000.0 step: 100 category: "Peer Calculations";
	parameter "Distance between peer homes" var: distance_between_homes min: 1.0 max: 5000.0 step: 100 category: "Peer Calculations";
	/** Insert here the definition of the input and output of the model */
	

	output
	{
		monitor "bike" value: inhabitants count (each.value_mode_actual = 1) ;
		monitor "walk" value: inhabitants count (each.value_mode_actual = 2) ;
		monitor "pt" value: inhabitants count (each.value_mode_actual = 3) ;
		monitor "car" value: inhabitants count (each.value_mode_actual = 4) ;
		display d type: java2D
		{
			species study_area aspect: a;
			species buildings aspect: a refresh:false;
			species roads aspect: a;
			species inhabitants aspect: a ;
			species inhabitants aspect: b;
			graphics "Info Text" refresh:true {
				draw string(current_date, "dd-MM-yyyy HH:mm:ss")  at:{0,4000} color: # black font: font('Helvetica Neue', 32,   # italic) ;
				
				}
		}
		
//		display "modal share" type:java2D refresh: every(#day) {
//			chart "mode share" type:series 
//			y_range:{0,1000}
//			{
//				data "bike" value:(inhabitants count (each.value_mode_actual = 1)) color:#blue style:spline thickness:2 marker:false;
//				data "walk" value:(inhabitants count (each.value_mode_actual = 2)) color:#red style:spline thickness:2 marker:false;
//				data "pt" value:(inhabitants count (each.value_mode_actual = 3)) color:#green style:spline thickness:2 marker:false;
//				data "car" value:(inhabitants count (each.value_mode_actual = 4)) color:#maroon style:spline thickness:2 marker:false;
//			}
//			
//		}// shall i run the model?
		
		display "modal share" type:java2D refresh: every(1#day) {
			chart "mode share" type:series 
			//style:spline
			//y_range:{0,1000}
			{
				data "bike" value:length(list(inhabitants) where (each.value_mode_actual = 1)) color:#blue  thickness:2 marker:false;
				data "walk" value:length(list(inhabitants) where (each.value_mode_actual = 2)) color:#red  thickness:2 marker:false;
				data "pt" value:length(list(inhabitants) where (each.value_mode_actual = 3)) color:#green  thickness:2 marker:false;
				data "car" value:length(list(inhabitants) where (each.value_mode_actual = 4)) color:#maroon  thickness:2 marker:false;
			}
			
		}
		
		display "decisions" type:java2D {
			chart "decision made" type:histogram
			
			
			
			{
				data "repeat" value:(inhabitants count (each.behavior = "repeat")) 	 color:#blue style:spline thickness:3;
				data "imitate" value:(inhabitants count (each.behavior = "imitate")) 	color:#red style:spline;
				data "inquire" value:(inhabitants count (each.behavior = "inquire")) 	color:#green style:spline;
				data "optimize" value:(inhabitants count (each.behavior = "optimize")) 	 color:#orange style:spline;
			}
			
		}
		
		

	}

}