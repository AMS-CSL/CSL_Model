model obj_drawing   
//import "googlebackground.gaml"

global {
	string s <- "1|2|3";
	init { 
		list<string> ls<- split_with(s,"|");
		bool a<- ls contains '1' ;
		write a;
		create object number: 1;
	}  
} 

species object skills: [moving]{
	point target <- any_location_in(world);
	reflex move  {
		do goto target: target ;
		if (target = location) {
			target <- any_location_in(world);
		}
	}
	aspect obj {
		//draw obj_file("../includes/pt_related/tram.obj", 90::{-1,0,0}) at: location + {0,0,2.0} size: 30.0 color: rgb(#blue,0.5) rotate: heading;
		
	}
}	

experiment Display  type: gui {
	output {
		display ComplexObject type: opengl{
			species object aspect:obj;		
			graphics "g" {
				draw obj_file("../includes/landmarks/station/edited_station.obj", 90::{-1,0,0}) at: {50,50,0}  size: 20.0 color: rgb(#blue,0.5) ;
			}		
		}
	}
}