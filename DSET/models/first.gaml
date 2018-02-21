/**
* Name: model1
* Author: Srirama Bhamidipati
* Description: 
* Tags: Tag1, Tag2, TagN
* draw string("Off_" + int(self)) color: # white font: font('Helvetica Neue', 12, # bold + # italic);
*/
model model1
import "../includes/dset_library.gaml"

global
{

// THE ENVIRONMENT 
	file shape_file_streets <- file("../includes/ped_network.shp");
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

	/** Insert the global definitions, variables and actions here */
	list<string> modes <- ["bike", "walk", "publictransport", "car"];
	map<string, int> mode_speed <- ["bike"::15, "walk"::4, "publictransport"::40, "car"::60];
	map<string, int> mode_value <- ["bike"::1, "walk"::2, "publictransport"::3, "car"::4];
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

		create inhabitants number: inhabitant_population
		{

		//do assess_peer_differences( list(inhabitants), distance_between_homes, relative_home_work_distance );
		}

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
// TRAVEL ATTRIBUTES
	string my_mode_preferred <- one_of(modes);
	string my_mode_actual <- one_of(modes);
	int value_mode_preferred <- mode_value[my_mode_preferred];
	int value_mode_actual <- mode_value[my_mode_actual];
//FIXME  these two below need to change to network characteristics, when we have a clean network
	float my_travel_distance <- rnd(1.0,10.0);
	float my_travel_time <- my_travel_distance / mode_speed[my_mode_actual];
	float my_aspiration;
	
	list<inhabitants> my_peers;
	
	//buildings home;
	
	buildings my_home <- one_of(buildings where (each.use = "residential"));
	// check location below  if any error, this could be a possible error in rare cases
	point location <- my_home.location;
	buildings my_office <- one_of(buildings where (each.use = "office"));
	bool has_peers <- false;
	
	

	//NEEDS
	float my_need_social;
	float my_need_personal;
	float my_need_existence;
	float my_overall_needs_satisfaction;


	// BEHAVIOR STRATEGY
	
	//------------------- IMITATE
	
	int imitates{
		list<inhabitants> peers_to_learn;
		int mode;
		// what are peers doing;
		list<int> peer_modes <- my_peers collect (each.value_mode_actual);
		
		
		return mode;
	}
	
	
	//-------------------  REPEAT
	int repeats{
		int mode <- value_mode_actual;
		return mode;
		
	}
	
	//------------------- INQUIRE
	
	//------------------- OPTIMIZE
	
	
	init
	{
	//do select_peers;
		do assess_peer_differences(list(inhabitants), distance_between_homes, relative_work_work_distance);
		do calculate_social_need;
		my_need_personal <- calculate_personal_need();
		do calculate_existence_need;
		my_overall_needs_satisfaction <- 1.0;
	}
	
	
// FUNCTION TO GET PEERS
	list<inhabitants> assess_peer_differences (list<inhabitants> possible_peers, float home_distance <- 2000, float office_office_distance <- 250)
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

	float calculate_superiority(list<inhabitants> _peers)
	{
//TODO check for travel speed and travel distance conflicts, currently it is all random numbers
		list<float> difference_with_my_peers <- _peers collect (each.my_travel_time - self.my_travel_time);
		//write difference_with_my_peers;
		if my_travel_time > mean(_peers collect (each.my_travel_time)){
			return 0.0;
		}
		else{
			return self.my_travel_time/mean(_peers collect (each.my_travel_time));
		}
		
	}

	float calculate_similarity (list<inhabitants> _peers)
	{
		
		//write self.value_actual_mode; // DEBUG STATEMENTS
		//write self.my_peers collect each.value_actual_mode; //DEBUG STATEMENTS
		list<float> difference_with_my_peers <- (_peers collect (abs(each.value_mode_actual - self.value_mode_actual))) collect (each/max_travel_mode_difference); //absolute difference
		//write difference_with_my_peers;
		if sum(difference_with_my_peers) = 0{
			return  0.0;
		} else {
			return  sum(difference_with_my_peers)/length(_peers);
		}
		
	}

	action calculate_social_need
	{
		float similarity_value;
		similarity_value<- calculate_similarity(my_peers);
		float superiority_value;
		superiority_value <- calculate_superiority(my_peers);
		my_need_social <- (similarity_value + superiority_value)/2;
		write my_need_social;
	}
	
	

	float calculate_personal_need
	{
		float relative_diff_to_current_peers <-value_mode_preferred - value_mode_actual = 0?0.0:(abs(value_mode_preferred-value_mode_actual)/3.0);
		return relative_diff_to_current_peers;
	}

	action calculate_existence_need
	{
	}

	aspect a
	{
		if !empty(my_peers)
		{
			draw circle(50) color: rgb(# blue, 0.2) empty: true;
			draw circle(20) color: rgb(((modes index_of my_mode_actual) + 10) * 60, 100, 100);
			draw string(int(self)) color: # white font: font('Helvetica Neue', 12, # bold + # italic);
			ask my_peers
			{
				draw polyline([self, myself]) color: rgb(# green, 0.5);
			}

		} else
		{
			draw circle(20) color: rgb((modes index_of (my_mode_actual)) * 60, 0, 0);
			draw string(int(self)) color: # white font: font('Helvetica Neue', 12, # bold);
		}

	}

}

experiment model1 type: gui
{
	float seed <- 0.8484812926428652;
	parameter "Proportion of offices in landuse" var: proportion_of_offices min: 0.0 max: 1.0 step: 0.1 category: "Global Model Parameters";
	parameter "Total inhabitant population" var: inhabitant_population min: 1 max: 1000 step: 100 category: "Global Model Parameters";
	parameter "Work 2 Work distance" var: relative_work_work_distance min: 1.0 max: 20000.0 step: 100 category: "Peer Calculations";
	parameter "Distance between peer homes" var: distance_between_homes min: 1.0 max: 5000.0 step: 100 category: "Peer Calculations";
	/** Insert here the definition of the input and output of the model */
	output
	{
		display d type: java2D
		{
			species study_area aspect: a;
			species buildings aspect: a;
			species roads aspect: a;
			species inhabitants aspect: a position: { 0, 0, 0.051 };
		}

	}

}