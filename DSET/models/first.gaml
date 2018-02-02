/**
* Name: model1
* Author: Ram
* Description: 
* Tags: Tag1, Tag2, TagN
* draw string("Off_" + int(self)) color: # white font: font('Helvetica Neue', 12, # bold + # italic);
*/

model model1


global
{

// THE ENVIRONMENT 
	file shape_file_streets <- file("../includes/ped_network.shp");
	file shape_file_bounds <- file("../includes/Boundary_study_area_rough.shp");
	file shape_buildings <- file("../includes/Buildings_Amsterdam.shp");
	geometry shape <- envelope(shape_file_bounds);
	
	
	// variables for model parameters
	
	float proportion_of_offices <-0.1;
	float distance_between_homes <-2000.0;
	float relative_work_work_distance <- 3000.0 ;
	int inhabitant_population <- 10;

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
		create buildings from: shape_buildings{
		
		}
		
		loop i over:buildings{
			if flip(proportion_of_offices) {
				i.use <- "office";
			} else {
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
	
	string use ;
	rgb my_color;
	

	aspect a
	{
		float building_height <- rnd(3.0, 12.0);
		if use = "office"{
			my_color <-rgb(#gray);
		} else {
			my_color <- rgb(#saddlebrown);
		}
		draw shape color: my_color depth: building_height;
		draw shape color: my_color at: { location.x, location.y, building_height };
		
	}
	
	aspect transparent_frame{
		
		float building_height <- rnd(3.0, 12.0);
		if use = "office"{
			my_color <-rgb(#gray, 0.2);
		} else {
			my_color <- rgb(#brown, 0.2);
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



species inhabitants schedules:shuffle(inhabitants)
{
//ATTRIBUTES
	string mode_preferred <- one_of(modes);
	string mode_actual <- one_of(modes);
	int value_preferred_mode <- mode_value[mode_preferred];
	int value_actual_mode <- mode_value[mode_actual];
	//buildings home;
	list<inhabitants> my_peers;
	
	
	buildings home <- one_of(buildings where (each.use = "residential"));
			point location <-home.location;
			buildings office <- one_of(buildings where (each.use = "office"));
			bool has_peers <- false;

	//NEEDS
	float need_social;
	float need_personal;
	float need_existencial;

	//DIFFERENCES
	float diff_mode;
	float diff_workplace;
	float diff_nearness;
	////
	init
	{
		//do select_peers;
		do assess_peer_differences( list(inhabitants), distance_between_homes, relative_work_work_distance );
	}

	list<inhabitants> assess_peer_differences (list<inhabitants> possible_peers, float home_distance <- 2000 , float office_office_distance <- 250)
	{
		possible_peers <- (possible_peers ) - self;
		map<inhabitants, float> relative_diff_mode_preferred;
		map<inhabitants, float> relative_diff_mode_actual;
		map<inhabitants, float> relative_diff_home_office_distance;
		map<inhabitants, float> relative_diff_home_home_distance;
		map<inhabitants, float> relative_diff_office_office_distance;
		
		loop pp over: possible_peers // pp short for possible peer

		{

			// CRITERIA 1 - DIFFERENCES IN PREFERRED MODES
			switch abs(self.value_preferred_mode - pp.value_preferred_mode)
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
			switch abs(self.value_actual_mode - pp.value_actual_mode)
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
			if distance_to(self.home, pp.home) < home_distance  
			{
				float d <- distance_to(self.home, pp.home);
				//write d;
				add pp::(d / home_distance) to: relative_diff_home_home_distance;
			} else
			{
				add pp::1 to: relative_diff_home_home_distance;
			}

			// CRITERIA 4 - RELATIVE HOME-WORK DISTANCES ; if potential peer travels similar distance, I am more attached to this peer's behavior
			float my_home_office_distance <- distance_to(self.home, self.office);
			if distance_to(pp.home, pp.office) < my_home_office_distance 
			{
				float d <- distance_to(pp.home, pp.office)/my_home_office_distance;
				//write d;
				add pp::(1-d) to: relative_diff_home_office_distance;
			} else
			{
				add pp::1 to: relative_diff_home_office_distance;
			}
			
			
			// CRITERIA 5 - IF AGENTS ARE WORKING CLOSE TO EACH OTHER, SAY WITHIN 250m, they more likely to be peers.
			
			float my_office_peer_office_distance <- distance_to(self.office, pp.office);
			if my_office_peer_office_distance < office_office_distance 
			{
				float d <- distance_to(self.office, pp.office)/office_office_distance;
				
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
 loop i over:relative_diff_home_home_distance.keys{
 	add  i::(relative_diff_home_home_distance[i] + 
 		relative_diff_mode_preferred[i] + 
 		relative_diff_mode_actual[i] +
 		relative_diff_home_office_distance[i] + 
 		relative_diff_office_office_distance[i]  
 	) to:final_score ;
 }
 
 //write "==================FINAL SCORE ============";
//write final_score;

 my_peers <-  first(5,final_score.keys sort_by(final_score[each])) ;
 save [ cycle, self.name, my_peers] to:"../output/my_peers.csv" type:"csv" rewrite:false;
 return my_peers;
 
 
	}


	action calculate_social_need
	{
	}

	action calculate_personal_need
	{
	}

	action calculate_existencial_need
	{
	}



	aspect a
	{
		if !empty(my_peers)
		{
			draw circle(50) color: rgb(# blue, 0.2) empty: true;
			draw circle(20) color: rgb(((modes index_of mode_actual) + 10) * 60, 100, 100);
			draw string(int(self)) color: # white font: font('Helvetica Neue', 12, # bold + # italic);
			ask my_peers
			{
				draw polyline([self, myself]) color: rgb(# green,0.5);
			}

		} else
		{
			draw circle(20) color: rgb((modes index_of (mode_actual)) * 60, 0, 0);
			draw string(int(self)) color: # white font: font('Helvetica Neue', 12, # bold);
		}

	}

}

experiment model1 type: gui
{
	float seed <- 0.8484812926428652;
	parameter "Proportion of offices in landuse" var:proportion_of_offices min:0.0 max:1.0 step:0.1 category:"Global Model Parameters";
	parameter "Total inhabitant population" var:inhabitant_population min:1 max:1000 step:100 category: "Global Model Parameters";
	parameter "Work 2 Work distance" var:relative_work_work_distance min:1.0 max:20000.0 step:100 category:"Peer Calculations";
	parameter "Distance between peer homes" var:distance_between_homes min:1.0 max:5000.0 step:100 category:"Peer Calculations";
	/** Insert here the definition of the input and output of the model */
	output
	{
		display d type: java2D
		{
			species study_area aspect: a;
			species buildings aspect: a;
			species roads aspect: a;
			
			species inhabitants aspect: a position:{0,0,0.051};
		}

	}

}