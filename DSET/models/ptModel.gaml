/**
* Name: ptModel
* Author: bhami001
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model ptModel

global {
	/** Insert the global definitions, variables and actions here */
	file shape_file_metro <- file('../includes/pt_related/metro_only.shp');
	file shape_file_tram <- file('../includes/pt_related/tram_only.shp');
	file shape_file_stops <- file('../includes/pt_related/stops.shp');
	graph tram_network;
	graph metro_network;
	
	list<string> tram_numbers <- ["01","02","03","04","05","07","09","10","12","13","14","17","24","26"];
	list<string> metro_numbers <- ["50", "51", "53","54"];
	
	
	
	date starting_date <- date("2018-02-22 15:00:00");
	float step <- 1#mn;
	
	geometry shape <- envelope(shape_file_stops);
	init{
		create metrolines from: shape_file_metro;
		create tramlines from:shape_file_tram;
		create stops from: shape_file_stops with:[modality::string(read("Modaliteit")), type::string(read("namenumber")), lijn::string(read("Lijn_selec"))]{}
		
		
		loop i over:tram_numbers{
			create tram number:1{
			
			my_lijn <- i;
			
			 my_stop <- one_of(stops where (each.type="Terminal" and each.modality="Tram" and each.lijns contains my_lijn  ));
			 my_list_of_stops <-(stops - my_stop) where(each.lijns contains my_lijn);
			 write i + "--"+ my_list_of_stops;
			 my_list_of_stops <- my_list_of_stops sort_by (distance_to(my_stop,each.location));
			  write i + "___"+ my_list_of_stops;
			// write "my lijn is " + my_lijn  + " and stop is a " + my_stop.type;
			 location <-my_stop.location;
			 my_terminal <- one_of((stops-my_stop) where (each.type="Terminal" and each.modality="Tram" and each.lijns contains my_lijn ));
		}
		}
		
		loop i over:metro_numbers{
			create metro number:1{
				my_lijn <- i;
				my_stop <- one_of(stops where (each.type="Terminal" and each.modality="Metro" and each.lijns contains my_lijn  ));
			// write "my lijn is " + my_lijn  + " and stop is a " + my_stop.type;
			 location <-my_stop.location;
			 my_terminal <- one_of((stops-my_stop) where (each.type="Terminal" and each.modality="Metro" and each.lijns contains my_lijn ));
				
			}
		}
		
		
		tram_network <- as_edge_graph(shape_file_tram);
		metro_network <- as_edge_graph(shape_file_metro);
	}
	
	
	reflex create_trams when:every(15#mn) and between(list(current_date)[3], 4,18) {
		loop i over:tram_numbers{
			create tram number:1{
			
			my_lijn <- i;
			
			 my_stop <- one_of(stops where (each.type="Terminal" and each.modality="Tram" and each.lijns contains my_lijn  ));
			 my_list_of_stops <-(stops - my_stop) where(each.lijns contains my_lijn);
			 write i + "--"+ my_list_of_stops;
			 my_list_of_stops <- my_list_of_stops sort_by (distance_to(my_stop,each.location));
			  write i + "___"+ my_list_of_stops;
			// write "my lijn is " + my_lijn  + " and stop is a " + my_stop.type;
			 location <-my_stop.location;
			 my_terminal <- one_of((stops-my_stop) where (each.type="Terminal" and each.modality="Tram" and each.lijns contains my_lijn ));
		}
		}
	}
	
	reflex create_metros when:every(15#mn) and between(list(current_date)[3], 4,18) {
		loop i over:metro_numbers{
			create metro number:1{
				my_lijn <- i;
				my_stop <- one_of(stops where (each.type="Terminal" and each.modality="Metro" and each.lijns contains my_lijn  ));
			// write "my lijn is " + my_lijn  + " and stop is a " + my_stop.type;
			 location <-my_stop.location;
			 my_terminal <- one_of((stops-my_stop) where (each.type="Terminal" and each.modality="Metro" and each.lijns contains my_lijn ));
				
			}
		}
	}
}

species tram skills:[moving]{
	string my_lijn ;//<- one_of([])
	stops my_stop ;
	stops my_terminal ;
	list<stops> my_list_of_stops ;
	
	init{
		
	}
	
	reflex gotravel{
		//write my_list_of_stops;
		point my_target;
		if  !empty(my_list_of_stops){
			my_target <- any_location_in(my_list_of_stops[0]); 
		}
		
		//write my_target;
		do goto target:my_target speed:4.0#m/#s on:tram_network;
		if (my_list_of_stops[0] covers self) and length(my_list_of_stops)>1 {
			my_list_of_stops <- my_list_of_stops - first(my_list_of_stops);
			write "i am at the stop";
		
		}
		
		if my_terminal covers self{
			do die;
		}
		//write my_list_of_stops;
		//do goto target:stops closest_to self speed:4.0 on:tram_network;
	}
	
	
	aspect a
	{
		if between(list(current_date)[3], 12,20)
		{
			draw circle(30) color: #white;
			draw arc(550, heading, 45, true) color:rgb(#yellow,0.7);
//			loop i from:100 to:190 step:20{
//				draw arc(i, heading, 45, true) color:rgb(#yellow,0.5);
//			}
		} else
		{
			draw circle(150) color: # blue;
			//draw obj_file("../includes/pt_related/small_tram.obj", 90::{-1,0,0}) at: location + {0,0,30.0} size: 130.0  rotate: heading;
			//draw rectangle(150,20) color:#red    rotate: heading;
			draw link(self.location, my_terminal.location) color: # black size: 50;
			draw my_lijn color: # white size: 50;
			
		}

	}
}


species metro skills:[moving]{
	stops my_stop ;//<- one_of(stops where (each.type="Terminal" and each.modality="Metro"));
	stops my_terminal;// <- one_of(stops where (each.type="Terminal" and each.modality="Metro"));
	string my_lijn ;
	
	reflex gotravel{
		do goto target:my_terminal speed:14.0#m/#s on:metro_network;
	}
	
	
	aspect a
	{
		if between(list(current_date)[3], 12, 18)
		{
			draw rectangle(250,75) color: rgb(# yellow) rotate:heading ;
			draw arc(50,50,50) color:rgb(#yellow,0.4) rotate:heading;
		} else
		{
			draw rectangle(250, 75) color: # red depth: 10 rotate: heading;
			//draw obj_file("../includes/pt_related/turn_amsmetro_sweden.obj", 90::{-1,0,0})  at: location + {0,0,-30.0} size: 420.0  rotate: heading;
			//draw obj_file("../includes/pt_related/ams_metro.obj", 90::{-1,0,0})  at: location + {0,0,-30.0} size: 20.0 color: rgb(#blue,0.5) rotate: heading;
			draw link(self.location, my_terminal.location) color: # red size: 50;
		}

	}
}
species stops{
	string type;
	string lijn;
	rgb colors;
	list<string> lijns;
	string modality;
	tram closest_tram ;//update: tram closest_to self;
	geometry shape <- type="Terminal"?circle(35):square(35);
	string infor  ;
	 
	 
	init{
		lijns <- split_with(lijn, "|");
	}
	
	reflex update_info when:!empty(tram){
		closest_tram <- tram closest_to self;
		infor <- closest_tram.my_lijn;
		//write infor;
	}
		aspect a{
		colors<- type="Terminal"? #red:#green;
		draw cylinder(20,50) color:colors ;
		draw string(int(self)) color:#black  font: font('Helvetica Neue', 12, # bold + # italic);
		//draw lijn color:#black size:50;
		//draw string(lijns) color:#black at: location+ {0,0,50}  perspective:false ;
		
		//draw ("Next Tram: " + infor + " minutes " + closest_tram) color:#red at: location+ {0,0,55}  perspective:false  font: font('Helvetica Neue', 12, # bold + # italic);
	}
}
species tramlines{
	aspect a{
		draw shape+9 color:#blue;
	}
}

species metrolines{
	aspect a{
		draw shape+15 color:#green;
		
	}
}


experiment ptModel type: gui {
	/** Insert here the definition of the input and output of the model */
	float minimum_cycle_duration <-0.4;
	output {
		display "2d" type:java2D background:between(list(current_date)[3], 12,20)?rgb(#black):rgb(#white){
			
			species metro aspect:a;
			species metrolines aspect:a refresh:false ;
			species tramlines aspect:a refresh:false;
			species stops aspect:a refresh:false;
			species tram aspect:a ;
			
			
//			graphics "g" {
//				draw obj_file("../includes/landmarks/station/edited_station.obj", 90::{-1,0,0}) size:1500 at: {4850,1650,0}+ {0,0,61.0}   ;
//			}	
		}
	}
}
