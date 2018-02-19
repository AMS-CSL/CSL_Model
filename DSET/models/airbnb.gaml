/**
* Name: airbnb
* Author: bhami001
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model airbnb

/* Insert your model definition here */

global {
	
	file airbnb_extent <- file('../includes/airbnb_related/airbnb3extent.shp');
	file airbnb_data <- file('../includes/airbnb_related/airbnb3.shp');
	file road_ring <- file('../includes/roads/nwb.shp');
	file shape_file_streets <- file("../includes/ped_network.shp");
	file shape_file_bounds <- file("../includes/Boundary_study_area_rough.shp");
	file shape_buildings <- file("../includes/Buildings_Amsterdam.shp");
	
	date starting_date <- date("2008-02-22 00:00:00");
	float step <- 10#day;
	
	geometry shape <- envelope(airbnb_extent);
	
	init {
		//create iris agents from the CSV file (use of the header of the CSV file), the attributes of the agents are initialized from the CSV files: 
		//we set the header facet to true to directly read the values corresponding to the right column. If the header was set to false, we could use the index of the columns to initialize the agent attributes
		
		//file my_csv_file <- csv_file("../includes/airbnb_related/airbnb3.csv",",");
		
		create airbnb from:airbnb_data with:[dates::string(read("dates")),month::string(read("month")),years::string(read("years"))]{
			since_date <- date([years,month, dates]);
		}
		ask airbnb{
			//write since_date;
			//write current_date;
		}
	}
	
	reflex stop_when when:current_date > #now{
		do pause;
	}
	
	
}

species airbnb {
	string dates;
	string month;
	string years;
	float latitude;
	float longitude;
	date since_date;
	bool visible <-false;
	init {
		
	}
	
	reflex show_airbnb when:current_date < #now{
		
			if since_date < current_date{
				visible <-true;
			}
			
			
		
	}
	
	
	
	aspect default {
		if visible{
//			draw circle(150) color: rgb(#yellow,0.01) ; 
//			draw circle(100) color: rgb(#orange,0.05) ; 
			draw circle(50) color: rgb(#red,0.1) ; 
		}
		
	}
}


experiment name type: gui {

	
	// Define parameters here if necessary
	// parameter "My parameter" category: "My parameters" var: one_global_attribute;
	
	// Define attributes, actions, a init section and behaviors if necessary
	// init { }
	
	
	output {
	// Define inspectors, browsers and displays here
	
	// inspect one_or_several_agents;
	//
	 display "My display"  type:opengl{ 
			
			graphics "roads"{
			//	draw shape_file_streets color:#black;
				draw shape_buildings color:rgb(#green, 0.3);
				draw road_ring color:rgb(#gray,0.1);
			}
			species airbnb ;
	 		 }

	}
}